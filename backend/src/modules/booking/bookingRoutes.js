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
  createEmergencyBooking,
  rescheduleBooking,
  checkSlotAvailability,
  autoCompleteExpiredBookings,
  autoExpireUnconfirmedBookings,
} from "./bookingController.js";

const router = express.Router();

router.use(authMiddleware);

// Standard booking endpoints
router.post("/", createBooking);
router.get("/", getBookings);
router.get("/history", getBookingHistory);
router.get("/:id", getBooking);
router.patch("/:id/confirm", confirmBooking);
router.patch("/:id/cancel", cancelBooking);
router.patch("/:id/complete", completeBooking);

// Enhanced booking endpoints
router.post("/emergency", createEmergencyBooking);
router.patch("/:id/reschedule", rescheduleBooking);
router.post("/availability/check", checkSlotAvailability);

// Admin endpoints (auto-operations)
router.post("/admin/auto-complete", autoCompleteExpiredBookings);
router.post("/admin/auto-expire", autoExpireUnconfirmedBookings);

export default router;
