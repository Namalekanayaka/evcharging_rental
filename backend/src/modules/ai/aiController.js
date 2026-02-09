import AIService from "./aiService.js";

const aiService = new AIService();

export const predictBatteryRange = async (req, res) => {
  try {
    const { carModel, currentBattery, weather } = req.body;

    if (!carModel || currentBattery === undefined) {
      return res
        .status(400)
        .json({ error: "carModel and currentBattery are required" });
    }

    const result = await aiService.predictBatteryRange(
      carModel,
      currentBattery,
      weather,
    );
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const findNearestChargers = async (req, res) => {
  try {
    const { latitude, longitude, currentBattery, carModel, weather } = req.body;

    if (!latitude || !longitude || !currentBattery || !carModel) {
      return res.status(400).json({
        error: "latitude, longitude, currentBattery, and carModel are required",
      });
    }

    const chargers = await aiService.findNearestChargerWithinRange(
      latitude,
      longitude,
      currentBattery,
      carModel,
      weather,
    );
    res.json(chargers);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const predictDemandPricing = async (req, res) => {
  try {
    const { chargerId } = req.params;
    const { dateTime } = req.query;

    if (!chargerId) {
      return res.status(400).json({ error: "chargerId is required" });
    }

    const pricing = await aiService.predictDemandBasedPricing(
      parseInt(chargerId),
      dateTime,
    );
    res.json(pricing);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const optimizeRoute = async (req, res) => {
  try {
    const { locations, carModel, currentBattery, weather } = req.body;

    if (
      !locations ||
      !Array.isArray(locations) ||
      !carModel ||
      currentBattery === undefined
    ) {
      return res.status(400).json({
        error: "locations (array), carModel, and currentBattery are required",
      });
    }

    const route = await aiService.optimizeChargingRoute(
      locations,
      carModel,
      currentBattery,
      weather,
    );
    res.json(route);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const getRecommendations = async (req, res) => {
  try {
    const userId = req.user?.id;

    if (!userId) {
      return res.status(401).json({ error: "User not authenticated" });
    }

    const recommendations = await aiService.getRecommendationsBatch(userId);
    res.json(recommendations);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
