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
