import userService from "./userService.js";
import { asyncHandler, ApiError } from "../../utils/errors.js";

export const getUserProfile = asyncHandler(async (req, res, next) => {
  try {
    const userId = req.user.id;
    const user = await userService.getUserProfile(userId);

    if (!user) {
      return next(new ApiError(404, "User not found"));
    }

    res.status(200).json({
      success: true,
      data: user,
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});

export const updateUserProfile = asyncHandler(async (req, res, next) => {
  try {
    const userId = req.user.id;
    const user = await userService.updateUserProfile(userId, req.body);

    res.status(200).json({
      success: true,
      data: user,
      message: "Profile updated successfully",
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const getUserStats = asyncHandler(async (req, res, next) => {
  try {
    const userId = req.user.id;
    const stats = await userService.getUserStats(userId);

    res.status(200).json({
      success: true,
      data: stats,
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});

export const searchUsers = asyncHandler(async (req, res, next) => {
  try {
    const users = await userService.searchUsers(req.query);

    res.status(200).json({
      success: true,
      data: users,
      count: users.length,
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const changePassword = asyncHandler(async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { oldPassword, newPassword, confirmPassword } = req.body;

    if (!oldPassword || !newPassword || !confirmPassword) {
      return next(new ApiError(400, "All password fields are required"));
    }

    if (newPassword !== confirmPassword) {
      return next(new ApiError(400, "New passwords do not match"));
    }

    const result = await userService.changePassword(
      userId,
      oldPassword,
      newPassword,
    );

    res.status(200).json({
      success: true,
      message: result.message,
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const getUserBookings = asyncHandler(async (req, res, next) => {
  try {
    const userId = req.user.id;
    const limit = parseInt(req.query.limit) || 20;
    const offset = parseInt(req.query.offset) || 0;

    const bookings = await userService.getUserBookings(userId, limit, offset);

    res.status(200).json({
      success: true,
      data: bookings,
      count: bookings.length,
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});
