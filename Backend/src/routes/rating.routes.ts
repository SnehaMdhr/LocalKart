import { Router } from "express";
import { RatingController } from "../controller/rating.controller";
import { authorizedMiddleware } from "../middlewares/authorized.middleware";

const router = Router();
const ratingController = new RatingController();

// All rating routes require authentication
router.use(authorizedMiddleware);

// POST /api/rating — Create a new rating
router.post("/", ratingController.createRating);

// GET /api/rating/vendor/:vendorId — Get vendor ratings
router.get("/vendor/:vendorId", ratingController.getVendorRatings);

// GET /api/rating/order/:orderId — Get order rating
router.get("/order/:orderId", ratingController.getOrderRating);

// PATCH /api/rating/:id — Update a rating
router.patch("/:id", ratingController.updateRating);

// DELETE /api/rating/:id — Delete a rating
router.delete("/:id", ratingController.deleteRating);

export default router;
