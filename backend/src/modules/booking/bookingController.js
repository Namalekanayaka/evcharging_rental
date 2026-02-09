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
// New endpoints for enhanced booking features

export const createEmergencyBooking = asyncHandler(async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { chargerId } = req.body;

    if (!chargerId) {
      return next(new ApiError(400, "Charger ID is required"));
    }

    const booking = await bookingService.createEmergencyBooking(userId, chargerId);

    res.status(201).json({
      success: true,
      data: booking,
      message: "Emergency booking created successfully",
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const rescheduleBooking = asyncHandler(async (req, res, next) => {
  try {
    const bookingId = req.params.id;
    const { newStartTime, newEndTime } = req.body;

    if (!newStartTime || !newEndTime) {
      return next(new ApiError(400, "New start and end times are required"));
    }

    const booking = await bookingService.rescheduleBooking(bookingId, {
      newStartTime,
      newEndTime,
    });

    res.status(200).json({
      success: true,
      data: booking,
      message: "Booking rescheduled successfully",
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const checkSlotAvailability = asyncHandler(async (req, res, next) => {
  try {
    const { chargerId, startTime, endTime } = req.body;

    if (!chargerId || !startTime || !endTime) {
      return next(new ApiError(400, "Charger ID and time range are required"));
    }

    const availability = await bookingService.checkSlotAvailability(
      chargerId,
      startTime,
      endTime,
    );

    res.status(200).json({
      success: true,
      data: availability,
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const autoCompleteExpiredBookings = asyncHandler(async (req, res, next) => {
  try {
    const result = await bookingService.autoCompleteExpiredBookings();

    res.status(200).json({
      success: true,
      data: result,
      message: "Expired bookings auto-completed",
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});

export const autoExpireUnconfirmedBookings = asyncHandler(async (req, res, next) => {
  try {
    const result = await bookingService.autoExpireUnconfirmedBookings();

    res.status(200).json({
      success: true,
      data: result,
      message: "Unconfirmed bookings auto-expired",
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});