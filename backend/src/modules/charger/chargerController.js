import chargerService from "./chargerService.js";
import { asyncHandler, ApiError } from "../../utils/errors.js";

export const createCharger = asyncHandler(async (req, res, next) => {
  try {
    const ownerId = req.user.id;

    if (req.user.userType !== "charger_owner") {
      return next(new ApiError(403, "Only charger owners can create chargers"));
    }

    const {
      name,
      description,
      type,
      address,
      latitude,
      longitude,
      pricePerHour,
      connectorTypes,
      maxWattage,
      availability,
    } = req.body;

    if (
      !name ||
      !type ||
      !address ||
      !latitude ||
      !longitude ||
      !pricePerHour
    ) {
      return next(new ApiError(400, "Missing required fields"));
    }

    const charger = await chargerService.createCharger(ownerId, req.body);

    res.status(201).json({
      success: true,
      data: charger,
      message: "Charger created successfully",
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const updateCharger = asyncHandler(async (req, res, next) => {
  try {
    const chargerId = req.params.id;
    const ownerId = req.user.id;

    const charger = await chargerService.updateCharger(
      chargerId,
      ownerId,
      req.body,
    );

    res.status(200).json({
      success: true,
      data: charger,
      message: "Charger updated successfully",
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const getChargerById = asyncHandler(async (req, res, next) => {
  try {
    const chargerId = req.params.id;
    const charger = await chargerService.getChargerById(chargerId);

    if (!charger) {
      return next(new ApiError(404, "Charger not found"));
    }

    res.status(200).json({
      success: true,
      data: charger,
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});

export const searchChargers = asyncHandler(async (req, res, next) => {
  try {
    const chargers = await chargerService.searchChargers(req.query);

    res.status(200).json({
      success: true,
      data: chargers,
      count: chargers.length,
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const getOwnerChargers = asyncHandler(async (req, res, next) => {
  try {
    const ownerId = req.user.id;
    const limit = parseInt(req.query.limit) || 20;
    const offset = parseInt(req.query.offset) || 0;

    const chargers = await chargerService.getOwnerChargers(
      ownerId,
      limit,
      offset,
    );

    res.status(200).json({
      success: true,
      data: chargers,
      count: chargers.length,
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});

export const deleteCharger = asyncHandler(async (req, res, next) => {
  try {
    const chargerId = req.params.id;
    const ownerId = req.user.id;

    const result = await chargerService.deleteCharger(chargerId, ownerId);

    res.status(200).json({
      success: true,
      message: result.message,
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const getChargerAvailability = asyncHandler(async (req, res, next) => {
  try {
    const chargerId = req.params.id;
    const { date } = req.query;

    if (!date) {
      return next(new ApiError(400, "Date is required"));
    }

    const availability = await chargerService.getChargerAvailability(
      chargerId,
      date,
    );

    res.status(200).json({
      success: true,
      data: availability,
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

// ========================= Advanced Charger Features =========================

export const setAvailability = asyncHandler(async (req, res, next) => {
  try {
    const chargerId = req.params.id;
    const { dayOfWeek, startTime, endTime, isAvailable } = req.body;

    if (dayOfWeek === undefined || !startTime || !endTime) {
      return next(new ApiError(400, "Missing required fields"));
    }

    const availability = await chargerService.setAvailability(
      chargerId,
      dayOfWeek,
      startTime,
      endTime,
      isAvailable,
    );

    res.status(200).json({
      success: true,
      message: "Availability set successfully",
      data: availability,
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const getUsageHistory = asyncHandler(async (req, res, next) => {
  try {
    const chargerId = req.params.id;
    const { limit = 50, offset = 0 } = req.query;

    const history = await chargerService.getUsageHistory(
      chargerId,
      Math.min(parseInt(limit), 100),
      parseInt(offset),
    );

    res.status(200).json({
      success: true,
      data: history,
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});

export const startChargingSession = asyncHandler(async (req, res, next) => {
  try {
    const chargerId = req.params.id;
    const userId = req.user.id;
    const { bookingId } = req.body;

    const session = await chargerService.startChargingSession(
      chargerId,
      userId,
      bookingId,
    );

    res.status(201).json({
      success: true,
      message: "Charging session started",
      data: session,
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const endChargingSession = asyncHandler(async (req, res, next) => {
  try {
    const { sessionId } = req.params;
    const { energyConsumed, cost } = req.body;

    if (energyConsumed === undefined || cost === undefined) {
      return next(new ApiError(400, "Missing required fields"));
    }

    const session = await chargerService.endChargingSession(
      sessionId,
      energyConsumed,
      cost,
    );

    res.status(200).json({
      success: true,
      message: "Charging session ended",
      data: session,
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const addChargerReview = asyncHandler(async (req, res, next) => {
  try {
    const chargerId = req.params.id;
    const reviewerId = req.user.id;
    const {
      bookingId,
      rating,
      reviewTitle,
      reviewText,
      cleanlinessRating,
      functionalityRating,
      locationRating,
    } = req.body;

    if (!rating || rating < 1 || rating > 5) {
      return next(new ApiError(400, "Rating must be between 1 and 5"));
    }

    const review = await chargerService.addReview({
      chargerId,
      reviewerId,
      bookingId,
      rating,
      reviewTitle,
      reviewText,
      cleanlinessRating,
      functionalityRating,
      locationRating,
    });

    res.status(201).json({
      success: true,
      message: "Review added successfully",
      data: review,
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const getChargerReviews = asyncHandler(async (req, res, next) => {
  try {
    const chargerId = req.params.id;
    const { limit = 20, offset = 0 } = req.query;

    const reviews = await chargerService.getChargerReviews(
      chargerId,
      Math.min(parseInt(limit), 100),
      parseInt(offset),
    );

    res.status(200).json({
      success: true,
      data: reviews,
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});

export const getNearbyChargers = asyncHandler(async (req, res, next) => {
  try {
    const { latitude, longitude, radius = 50, limit = 20 } = req.query;

    if (!latitude || !longitude) {
      return next(
        new ApiError(400, "Latitude and longitude are required")
      );
    }

    const chargers = await chargerService.getNearbyChargers(
      parseFloat(latitude),
      parseFloat(longitude),
      parseFloat(radius),
      parseInt(limit),
    );

    res.status(200).json({
      success: true,
      data: chargers,
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});

export const getChargerStats = asyncHandler(async (req, res, next) => {
  try {
    const chargerId = req.params.id;

    const stats = await chargerService.getChargerStats(chargerId);

    if (!stats) {
      return next(new ApiError(404, "Charger not found"));
    }

    res.status(200).json({
      success: true,
      data: stats,
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});

export const uploadChargerPhoto = asyncHandler(async (req, res, next) => {
  try {
    const chargerId = req.params.id;
    const { photoUrl, displayOrder = 0, isPrimary = false } = req.body;

    if (!photoUrl) {
      return next(new ApiError(400, "Photo URL is required"));
    }

    const photo = await chargerService.uploadPhoto(
      chargerId,
      photoUrl,
      displayOrder,
      isPrimary,
    );

    res.status(201).json({
      success: true,
      message: "Photo uploaded successfully",
      data: photo,
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});
