import express from "express";
import authMiddleware from "../../middleware/authMiddleware.js";
import {
  createBooking,
  getBooking,
  getBookings,
  confirmBooking,
  cancelBooking,
  completeBooking,
  getBookingHistory,
} from "./bookingController.js";

const router = express.Router();

router.use(authMiddleware);

router.post("/", createBooking);
router.get("/", getBookings);
router.get("/history", getBookingHistory);
router.get("/:id", getBooking);
router.patch("/:id/confirm", confirmBooking);
router.patch("/:id/cancel", cancelBooking);
router.patch("/:id/complete", completeBooking);

export default router;
