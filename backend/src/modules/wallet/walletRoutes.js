import express from "express";
import authMiddleware from "../../middleware/authMiddleware.js";
import {
  getWallet,
  addBalance,
  deductBalance,
  getTransactions,
  transferBalance,
} from "./walletController.js";

const router = express.Router();

router.use(authMiddleware);

router.get("/", getWallet);
router.post("/add-balance", addBalance);
router.post("/deduct-balance", deductBalance);
router.get("/transactions", getTransactions);
router.post("/transfer", transferBalance);

export default router;
