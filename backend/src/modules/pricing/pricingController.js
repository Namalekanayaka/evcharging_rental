import pricingService from "./pricingService.js";
import { asyncHandler, ApiError } from "../../utils/errors.js";

export const getPricingPackages = asyncHandler(async (req, res, next) => {
  try {
    const packages = await pricingService.getPricingPackages();

    res.status(200).json({
      success: true,
      data: packages,
      count: packages.length,
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});

export const getPackageById = asyncHandler(async (req, res, next) => {
  try {
    const packageId = req.params.id;
    const pkg = await pricingService.getPackageById(packageId);

    if (!pkg) {
      return next(new ApiError(404, "Package not found"));
    }

    res.status(200).json({
      success: true,
      data: pkg,
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});

export const createPackage = asyncHandler(async (req, res, next) => {
  try {
    const { name, description, basePrice, hourlyRate, benefits } = req.body;

    if (!name || !basePrice || !hourlyRate) {
      return next(new ApiError(400, "Missing required fields"));
    }

    const pkg = await pricingService.createPackage(req.body);

    res.status(201).json({
      success: true,
      data: pkg,
      message: "Package created successfully",
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const updatePackage = asyncHandler(async (req, res, next) => {
  try {
    const packageId = req.params.id;
    const pkg = await pricingService.updatePackage(packageId, req.body);

    res.status(200).json({
      success: true,
      data: pkg,
      message: "Package updated successfully",
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const calculateBookingPrice = asyncHandler(async (req, res, next) => {
  try {
    const { chargerId, duration, discount = 0 } = req.body;

    if (!chargerId || !duration) {
      return next(new ApiError(400, "Charger ID and duration are required"));
    }

    const pricing = await pricingService.calculateBookingPrice(
      chargerId,
      duration,
      discount,
    );

    res.status(200).json({
      success: true,
      data: pricing,
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const getPricingStats = asyncHandler(async (req, res, next) => {
  try {
    const stats = await pricingService.getPricingStats();

    res.status(200).json({
      success: true,
      data: stats,
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});
