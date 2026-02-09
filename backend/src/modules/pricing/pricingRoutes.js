import express from "express";
import authMiddleware from "../../middleware/authMiddleware.js";
import { roleMiddleware } from "../../middleware/roleMiddleware.js";
import {
  getPricingPackages,
  getPackageById,
  createPackage,
  updatePackage,
  calculateBookingPrice,
  getPricingStats,
} from "./pricingController.js";

const router = express.Router();

router.get("/", getPricingPackages);
router.get("/:id", getPackageById);
router.post("/calculate", calculateBookingPrice);
router.get("/admin/stats", getPricingStats);

router.use(authMiddleware);
router.use(roleMiddleware(["admin"]));

router.post("/", createPackage);
router.put("/:id", updatePackage);

export default router;
