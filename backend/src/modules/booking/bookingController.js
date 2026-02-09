import bookingService from "./bookingService.js";
import { asyncHandler, ApiError } from "../../utils/errors.js";

export const createBooking = asyncHandler(async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { chargerId, startTime, duration, totalAmount } = req.body;

    if (!chargerId || !startTime || !duration || !totalAmount) {
      return next(new ApiError(400, "Missing required fields"));
    }

    const booking = await bookingService.createBooking(userId, req.body);

    res.status(201).json({
      success: true,
      data: booking,
      message: "Booking created successfully",
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const getBooking = asyncHandler(async (req, res, next) => {
  try {
    const bookingId = req.params.id;
    const booking = await bookingService.getBooking(bookingId);

    if (!booking) {
      return next(new ApiError(404, "Booking not found"));
    }

    res.status(200).json({
      success: true,
      data: booking,
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});

export const getBookings = asyncHandler(async (req, res, next) => {
  try {
    const userId = req.user.id;
    const bookings = await bookingService.getBookings(userId, req.query);

    res.status(200).json({
      success: true,
      data: bookings,
      count: bookings.length,
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});

export const confirmBooking = asyncHandler(async (req, res, next) => {
  try {
    const bookingId = req.params.id;
    const booking = await bookingService.confirmBooking(bookingId);

    if (!booking) {
      return next(new ApiError(404, "Booking not found or already confirmed"));
    }

    res.status(200).json({
      success: true,
      data: booking,
      message: "Booking confirmed",
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const cancelBooking = asyncHandler(async (req, res, next) => {
  try {
    const bookingId = req.params.id;
    const { reason } = req.body;

    const booking = await bookingService.cancelBooking(bookingId, reason);

    if (!booking) {
      return next(new ApiError(404, "Booking not found"));
    }

    res.status(200).json({
      success: true,
      data: booking,
      message: "Booking cancelled",
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const completeBooking = asyncHandler(async (req, res, next) => {
  try {
    const bookingId = req.params.id;
    const booking = await bookingService.completeBooking(bookingId);

    if (!booking) {
      return next(new ApiError(404, "Booking not found"));
    }

    res.status(200).json({
      success: true,
      data: booking,
      message: "Booking completed",
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const getBookingHistory = asyncHandler(async (req, res, next) => {
  try {
    const userId = req.user.id;
    const limit = parseInt(req.query.limit) || 20;
    const offset = parseInt(req.query.offset) || 0;

    const bookings = await bookingService.getBookingHistory(
      userId,
      limit,
      offset,
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
