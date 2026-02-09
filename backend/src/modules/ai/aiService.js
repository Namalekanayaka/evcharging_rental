import db from "../../config/database.js";

export default class AIService {
  // Battery range prediction based on car model, current battery, and weather
  async predictBatteryRange(carModel, currentBattery, weather = "normal") {
    try {
      // Car efficiency ratings (km per %)
      const carEfficiency = {
        sedan: 1.2,
        suv: 0.9,
        hatchback: 1.4,
        van: 0.8,
        truck: 0.7,
      };

      // Weather impact (0.85 = 15% reduction in range)
      const weatherFactors = {
        rainy: 0.85,
        snowy: 0.8,
        normal: 1.0,
        sunny: 1.05,
      };

      const efficiency = carEfficiency[carModel.toLowerCase()] || 1.0;
      const weatherFactor = weatherFactors[weather.toLowerCase()] || 1.0;

      // Full charge range based on typical EV battery (60 kWh avg)
      const fullChargeRange = 300;
      const predictedRange = Math.round(
        currentBattery * efficiency * weatherFactor,
      );

      return {
        predictedRange,
        currentBattery,
        fullChargeRange,
        weatherFactor: weather,
        efficiency: efficiency.toFixed(2),
      };
    } catch (error) {
      throw error;
    }
  }

  // Find nearest chargers within predicted range with scoring
  async findNearestChargerWithinRange(
    latitude,
    longitude,
    currentBattery,
    carModel,
    weather = "normal",
  ) {
    try {
      const range = await this.predictBatteryRange(
        carModel,
        currentBattery,
        weather,
      );
      const maxDistanceKm = range.predictedRange;

      const result = await db.query(
        `SELECT 
          c.id, c.name, c.location, c.latitude, c.longitude, 
          c.price_per_kwh, c.charger_type, c.is_available,
          AVG(r.rating) as avg_rating, COUNT(r.id) as review_count,
          COUNT(b.id) as active_bookings,
          (3959 * 2 * ASIN(SQRT(POWER(SIN(RADIANS((c.latitude - ?) / 2)), 2) + 
          COS(RADIANS(?)) * COS(RADIANS(c.latitude)) * POWER(SIN(RADIANS((c.longitude - ?) / 2)), 2)))) as distance_km
        FROM chargers c
        LEFT JOIN reviews r ON c.id = r.charger_id
        LEFT JOIN bookings b ON c.id = b.charger_id AND b.status = 'ongoing'
        WHERE c.is_active = true
        GROUP BY c.id
        HAVING distance_km <= ?
        ORDER BY distance_km ASC
        LIMIT 10`,
        [latitude, latitude, longitude, maxDistanceKm],
      );

      // Score chargers: distance (30%), availability (20%), rating (25%), price (15%), occupancy (10%)
      const chargers = result.rows.map((charger) => {
        const distanceScore = Math.max(0, 100 - charger.distance_km * 5);
        const availabilityScore = charger.is_available ? 100 : 0;
        const ratingScore = (charger.avg_rating || 4) * 20;
        const priceScore = Math.max(0, 100 - charger.price_per_kwh * 10);
        const occupancyScore = Math.max(0, 100 - charger.active_bookings * 10);

        const score = Math.round(
          distanceScore * 0.3 +
            availabilityScore * 0.2 +
            ratingScore * 0.25 +
            priceScore * 0.15 +
            occupancyScore * 0.1,
        );

        return {
          ...charger,
          score,
          willReachWithBuffer: charger.distance_km < maxDistanceKm * 0.8, // 20% buffer
        };
      });

      return chargers;
    } catch (error) {
      throw error;
    }
  }

  // Predict demand-based pricing for a specific charger
  async predictDemandBasedPricing(chargerId, dateTime = new Date()) {
    try {
      const date = new Date(dateTime);
      const hour = date.getHours();
      const dayOfWeek = date.getDay();

      // Fetch historical booking data for this charger
      const historyResult = await db.query(
        `SELECT COUNT(*) as booking_count, EXTRACT(HOUR FROM created_at) as hour
        FROM bookings
        WHERE charger_id = ? AND DATE(created_at) = DATE(?)
        GROUP BY hour`,
        [chargerId, date],
      );

      // Get current price
      const priceResult = await db.query(
        `SELECT price_per_kwh FROM chargers WHERE id = ?`,
        [chargerId],
      );

      const currentPrice = priceResult.rows[0]?.price_per_kwh || 20;

      // Calculate demand multiplier based on booking frequency
      const bookingCount = historyResult.rows.length;
      let demandMultiplier = 1.0;

      if (bookingCount > 100)
        demandMultiplier = 1.5; // Peak demand
      else if (bookingCount > 50) demandMultiplier = 1.3;
      else if (bookingCount > 20) demandMultiplier = 1.15;
      else if (bookingCount < 5) demandMultiplier = 0.8; // Low demand discount

      const predictedPrice =
        Math.round(currentPrice * demandMultiplier * 100) / 100;

      // Estimate occupancy for next hour
      const occupancyResult = await db.query(
        `SELECT COUNT(*) as current_occupancy FROM bookings 
        WHERE charger_id = ? AND status = 'ongoing'`,
        [chargerId],
      );

      return {
        currentPrice,
        predictedPrice,
        demandMultiplier: demandMultiplier.toFixed(2),
        demandLevel:
          demandMultiplier > 1.25
            ? "high"
            : demandMultiplier > 1.0
              ? "medium"
              : "low",
        hour,
        dayOfWeek,
        forecastedOccupancy: occupancyResult.rows[0]?.current_occupancy || 0,
      };
    } catch (error) {
      throw error;
    }
  }

  // Optimize route for multi-stop charging (TSP-like algorithm)
  async optimizeChargingRoute(
    locations,
    carModel,
    currentBattery,
    weather = "normal",
  ) {
    try {
      const range = await this.predictBatteryRange(
        carModel,
        currentBattery,
        weather,
      );
      const maxRange = range.predictedRange;

      // Greedy nearest neighbor approach
      const stops = [];
      let currentLocation = locations[0];
      let remainingBattery = currentBattery;
      let totalTime = 0;
      const visited = new Set([0]);

      while (visited.size < locations.length && remainingBattery > 10) {
        // Find nearest unvisited charger within range
        let nearestIdx = -1;
        let minDistance = Infinity;

        for (let i = 1; i < locations.length; i++) {
          if (!visited.has(i)) {
            const distance = this._calculateDistance(
              currentLocation,
              locations[i],
            );
            if (distance <= maxRange && distance < minDistance) {
              minDistance = distance;
              nearestIdx = i;
            }
          }
        }

        if (nearestIdx === -1) break;

        visited.add(nearestIdx);
        const charger = locations[nearestIdx];
        const distance = this._calculateDistance(currentLocation, charger);

        // Calculate charging time needed (30 min per 20% battery)
        const batteryNeeded = Math.min(80 - remainingBattery, 60);
        const chargingTime = Math.round((batteryNeeded / 20) * 30);

        stops.push({
          type: nearestIdx === locations.length - 1 ? "destination" : "charger",
          charger: charger.name || `Charger ${nearestIdx}`,
          chargingTimeMinutes: chargingTime,
          arrivalBattery: Math.round(remainingBattery),
        });

        totalTime += (distance / 80) * 60 + chargingTime; // 80 km/h average speed
        remainingBattery = 100; // Assume full charge after stop
        currentLocation = charger;
      }

      return {
        optimizedRoute: stops,
        totalTimeMinutes: Math.round(totalTime),
        waypoints: stops.length,
        efficiency:
          stops.length <= 2
            ? "optimal"
            : stops.length <= 4
              ? "good"
              : "moderate",
      };
    } catch (error) {
      throw error;
    }
  }

  // Get AI recommendations based on user patterns
  async getRecommendationsBatch(userId) {
    try {
      const recommendations = [];

      // Check battery level patterns
      const userData = await db.query(
        `SELECT AVG(current_battery) as avg_battery FROM user_sessions WHERE user_id = ?`,
        [userId],
      );

      if (userData.rows[0]?.avg_battery < 20) {
        recommendations.push({
          type: "low_battery_warning",
          message: "Your battery is consistently low. Plan charging ahead.",
          priority: "high",
        });
      }

      // Check peak hour patterns
      const peakResult = await db.query(
        `SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as bookings
        FROM bookings WHERE user_id = ? GROUP BY hour ORDER BY bookings DESC LIMIT 3`,
        [userId],
      );

      const peakHours = peakResult.rows.map((r) => r.hour);
      if (peakHours.length > 0) {
        recommendations.push({
          type: "peak_hour_alert",
          message: `You usually charge during ${peakHours.join(", ")}. Try off-peak hours to save money.`,
          priority: "medium",
        });
      }

      // Check usage frequency
      const frequencyResult = await db.query(
        `SELECT COUNT(*) as booking_count FROM bookings WHERE user_id = ? AND DATE(created_at) >= DATE_TRUNC('month', NOW())`,
        [userId],
      );

      if (frequencyResult.rows[0]?.booking_count > 20) {
        recommendations.push({
          type: "frequent_charger",
          message: "Consider a monthly subscription plan for better rates.",
          priority: "medium",
        });
      }

      return recommendations.length > 0
        ? recommendations
        : [
            {
              type: "general",
              message: "Browse available chargers to plan your next trip.",
              priority: "low",
            },
          ];
    } catch (error) {
      throw error;
    }
  }

  _calculateDistance(from, to) {
    // Haversine formula for distance between two coordinates
    const R = 6371; // Earth radius in km
    const dLat = ((to.latitude || 0) - (from.latitude || 0)) * (Math.PI / 180);
    const dLon =
      ((to.longitude || 0) - (from.longitude || 0)) * (Math.PI / 180);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos((from.latitude || 0) * (Math.PI / 180)) *
        Math.cos((to.latitude || 0) * (Math.PI / 180)) *
        Math.sin(dLon / 2) *
        Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }
}
