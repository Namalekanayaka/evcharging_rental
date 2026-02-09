import express from "express";
import authMiddleware from "../../middleware/authMiddleware.js";
import { roleMiddleware } from "../../middleware/roleMiddleware.js";
import {
  getDashboardStats,
  getAllUsers,
  getAllChargers,
  getAllBookings,
  suspendUser,
  activateUser,
  disableCharger,
  enableCharger,
  getRevenueTimeline,
  getReports,
} from "./adminController.js";

const router = express.Router();

router.use(authMiddleware);
router.use(roleMiddleware(["admin"]));

router.get("/dashboard/stats", getDashboardStats);
router.get("/users", getAllUsers);
router.get("/chargers", getAllChargers);
router.get("/bookings", getAllBookings);
router.get("/revenue/timeline", getRevenueTimeline);
router.get("/reports", getReports);

router.patch("/users/:id/suspend", suspendUser);
router.patch("/users/:id/activate", activateUser);
router.patch("/chargers/:id/disable", disableCharger);
router.patch("/chargers/:id/enable", enableCharger);

export default router;
