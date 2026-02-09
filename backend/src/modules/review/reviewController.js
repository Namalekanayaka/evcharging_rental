import reviewService from "./reviewService.js";
import { asyncHandler, ApiError } from "../../utils/errors.js";

export const createReview = asyncHandler(async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { chargerId, rating, comment, bookingId } = req.body;

    if (!chargerId || !rating || !bookingId) {
      return next(new ApiError(400, "Missing required fields"));
    }

    const review = await reviewService.createReview(userId, req.body);

    res.status(201).json({
      success: true,
      data: review,
      message: "Review created successfully",
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const getChargerReviews = asyncHandler(async (req, res, next) => {
  try {
    const chargerId = req.params.id;
    const limit = parseInt(req.query.limit) || 20;
    const offset = parseInt(req.query.offset) || 0;

    const reviews = await reviewService.getChargerReviews(
      chargerId,
      limit,
      offset,
    );

    res.status(200).json({
      success: true,
      data: reviews,
      count: reviews.length,
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});

export const getUserReviews = asyncHandler(async (req, res, next) => {
  try {
    const userId = req.user.id;
    const limit = parseInt(req.query.limit) || 20;
    const offset = parseInt(req.query.offset) || 0;

    const reviews = await reviewService.getUserReviews(userId, limit, offset);

    res.status(200).json({
      success: true,
      data: reviews,
      count: reviews.length,
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});

export const getChargerReviewStats = asyncHandler(async (req, res, next) => {
  try {
    const chargerId = req.params.id;
    const stats = await reviewService.getChargerReviewStats(chargerId);

    res.status(200).json({
      success: true,
      data: stats,
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});

export const updateReview = asyncHandler(async (req, res, next) => {
  try {
    const reviewId = req.params.id;
    const userId = req.user.id;

    const review = await reviewService.updateReview(reviewId, userId, req.body);

    res.status(200).json({
      success: true,
      data: review,
      message: "Review updated successfully",
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const deleteReview = asyncHandler(async (req, res, next) => {
  try {
    const reviewId = req.params.id;
    const userId = req.user.id;

    const result = await reviewService.deleteReview(reviewId, userId);

    res.status(200).json({
      success: true,
      message: result.message,
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});
