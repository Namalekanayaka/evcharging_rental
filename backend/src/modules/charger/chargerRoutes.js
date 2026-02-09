import express from "express";
import authMiddleware from "../../middleware/authMiddleware.js";
import {
  createCharger,
  updateCharger,
  getChargerById,
  searchChargers,
  getOwnerChargers,
  deleteCharger,
  getChargerAvailability,
} from "./chargerController.js";

const router = express.Router();

router.get("/search", searchChargers);
router.get("/:id", getChargerById);
router.get("/:id/availability", getChargerAvailability);

router.use(authMiddleware);

router.post("/", createCharger);
router.get("/", getOwnerChargers);
router.put("/:id", updateCharger);
router.delete("/:id", deleteCharger);

export default router;
