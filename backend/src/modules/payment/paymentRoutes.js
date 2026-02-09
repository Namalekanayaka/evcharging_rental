import express from "express";
import authMiddleware from "../../middleware/authMiddleware.js";
import {
  processPayment,
  getPayment,
  getUserPayments,
  refundPayment,
} from "./paymentController.js";

const router = express.Router();

router.use(authMiddleware);

router.post("/", processPayment);
router.get("/", getUserPayments);
router.get("/:id", getPayment);
router.post("/:id/refund", refundPayment);

export default router;
