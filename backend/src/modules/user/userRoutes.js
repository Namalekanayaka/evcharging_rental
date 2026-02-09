import express from "express";
import authMiddleware from "../../middleware/authMiddleware.js";
import {
  getUserProfile,
  updateUserProfile,
  getUserStats,
  changePassword,
  getUserBookings,
  searchUsers,
} from "./userController.js";
import { roleMiddleware } from "../../middleware/roleMiddleware.js";

const router = express.Router();

router.use(authMiddleware);

router.get("/profile", getUserProfile);
router.put("/profile", updateUserProfile);
router.get("/stats", getUserStats);
router.put("/change-password", changePassword);
router.get("/bookings", getUserBookings);
router.get("/search", roleMiddleware(["admin"]), searchUsers);

export default router;
