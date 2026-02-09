import adminService from "./adminService.js";
import { asyncHandler, ApiError } from "../../utils/errors.js";

export const getDashboardStats = asyncHandler(async (req, res, next) => {
  try {
    const stats = await adminService.getDashboardStats();

    res.status(200).json({
      success: true,
      data: stats,
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});

export const getAllUsers = asyncHandler(async (req, res, next) => {
  try {
    const limit = parseInt(req.query.limit) || 50;
    const offset = parseInt(req.query.offset) || 0;

    const users = await adminService.getAllUsers(limit, offset);

    res.status(200).json({
      success: true,
      data: users,
      count: users.length,
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});

export const getAllChargers = asyncHandler(async (req, res, next) => {
  try {
    const limit = parseInt(req.query.limit) || 50;
    const offset = parseInt(req.query.offset) || 0;

    const chargers = await adminService.getAllChargers(limit, offset);

    res.status(200).json({
      success: true,
      data: chargers,
      count: chargers.length,
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});

export const getAllBookings = asyncHandler(async (req, res, next) => {
  try {
    const limit = parseInt(req.query.limit) || 50;
    const offset = parseInt(req.query.offset) || 0;

    const bookings = await adminService.getAllBookings(
      limit,
      offset,
      req.query,
    );

    res.status(200).json({
      success: true,
      data: bookings,
      count: bookings.length,
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});

export const suspendUser = asyncHandler(async (req, res, next) => {
  try {
    const userId = req.params.id;
    const { reason } = req.body;

    if (!reason) {
      return next(new ApiError(400, "Reason is required"));
    }

    const user = await adminService.suspendUser(userId, reason);

    res.status(200).json({
      success: true,
      data: user,
      message: "User suspended successfully",
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const activateUser = asyncHandler(async (req, res, next) => {
  try {
    const userId = req.params.id;
    const user = await adminService.activateUser(userId);

    res.status(200).json({
      success: true,
      data: user,
      message: "User activated successfully",
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const disableCharger = asyncHandler(async (req, res, next) => {
  try {
    const chargerId = req.params.id;
    const { reason } = req.body;

    if (!reason) {
      return next(new ApiError(400, "Reason is required"));
    }

    const charger = await adminService.disableCharger(chargerId, reason);

    res.status(200).json({
      success: true,
      data: charger,
      message: "Charger disabled successfully",
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const enableCharger = asyncHandler(async (req, res, next) => {
  try {
    const chargerId = req.params.id;
    const charger = await adminService.enableCharger(chargerId);

    res.status(200).json({
      success: true,
      data: charger,
      message: "Charger enabled successfully",
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const getRevenueTimeline = asyncHandler(async (req, res, next) => {
  try {
    const days = parseInt(req.query.days) || 30;
    const revenue = await adminService.getRevenueTimeline(days);

    res.status(200).json({
      success: true,
      data: revenue,
      count: revenue.length,
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});

export const getReports = asyncHandler(async (req, res, next) => {
  try {
    const reports = await adminService.getReports();

    res.status(200).json({
      success: true,
      data: reports,
      count: reports.length,
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});
