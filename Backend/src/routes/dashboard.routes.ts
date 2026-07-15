import { Router } from "express";
import { DashboardController } from "../controller/dashboard.controller";
import { authorizedMiddleware, adminOnlyMiddleware } from "../middlewares/authorized.middleware";

const router = Router();
const dashboardController = new DashboardController();

router.get(
  "/",
  authorizedMiddleware,
  adminOnlyMiddleware,
  dashboardController.getDashboard
);

export default router;
