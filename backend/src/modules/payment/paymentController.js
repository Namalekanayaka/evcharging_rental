import paymentService from "./paymentService.js";
import { asyncHandler, ApiError } from "../../utils/errors.js";

export const processPayment = asyncHandler(async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { amount, bookingId, paymentMethod } = req.body;

    if (!amount || !bookingId || !paymentMethod) {
      return next(new ApiError(400, "Missing required fields"));
    }

    const payment = await paymentService.processPayment(userId, req.body);

    res.status(201).json({
      success: true,
      data: payment,
      message: "Payment processed successfully",
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const getPayment = asyncHandler(async (req, res, next) => {
  try {
    const paymentId = req.params.id;
    const payment = await paymentService.getPayment(paymentId);

    if (!payment) {
      return next(new ApiError(404, "Payment not found"));
    }

    res.status(200).json({
      success: true,
      data: payment,
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});

export const getUserPayments = asyncHandler(async (req, res, next) => {
  try {
    const userId = req.user.id;
    const limit = parseInt(req.query.limit) || 20;
    const offset = parseInt(req.query.offset) || 0;

    const payments = await paymentService.getUserPayments(
      userId,
      limit,
      offset,
    );

    res.status(200).json({
      success: true,
      data: payments,
      count: payments.length,
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});

export const refundPayment = asyncHandler(async (req, res, next) => {
  try {
    const paymentId = req.params.id;
    const payment = await paymentService.refundPayment(paymentId);

    res.status(200).json({
      success: true,
      data: payment,
      message: "Payment refunded successfully",
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});
