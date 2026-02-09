import walletService from "./walletService.js";
import { asyncHandler, ApiError } from "../../utils/errors.js";

export const getWallet = asyncHandler(async (req, res, next) => {
  try {
    const userId = req.user.id;
    const wallet = await walletService.getWallet(userId);

    res.status(200).json({
      success: true,
      data: wallet,
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});

export const addBalance = asyncHandler(async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { amount, transactionType = "credit" } = req.body;

    if (!amount || amount <= 0) {
      return next(new ApiError(400, "Invalid amount"));
    }

    const result = await walletService.addBalance(
      userId,
      amount,
      transactionType,
    );

    res.status(200).json({
      success: true,
      data: result,
      message: "Balance added successfully",
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const deductBalance = asyncHandler(async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { amount } = req.body;

    if (!amount || amount <= 0) {
      return next(new ApiError(400, "Invalid amount"));
    }

    const result = await walletService.deductBalance(userId, amount);

    res.status(200).json({
      success: true,
      data: result,
      message: "Balance deducted successfully",
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

export const getTransactions = asyncHandler(async (req, res, next) => {
  try {
    const userId = req.user.id;
    const limit = parseInt(req.query.limit) || 20;
    const offset = parseInt(req.query.offset) || 0;

    const transactions = await walletService.getTransactions(
      userId,
      limit,
      offset,
    );

    res.status(200).json({
      success: true,
      data: transactions,
      count: transactions.length,
    });
  } catch (error) {
    next(new ApiError(500, error.message));
  }
});

export const transferBalance = asyncHandler(async (req, res, next) => {
  try {
    const fromUserId = req.user.id;
    const { toUserId, amount } = req.body;

    if (!toUserId || !amount || amount <= 0) {
      return next(new ApiError(400, "Invalid data"));
    }

    const result = await walletService.transferBalance(
      fromUserId,
      toUserId,
      amount,
    );

    res.status(200).json({
      success: true,
      data: result,
      message: "Balance transferred successfully",
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});
