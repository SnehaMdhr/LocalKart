import { Router } from "express";
import { CartController } from "../controller/cart.controller";
import {
  authorizedMiddleware,
  customerOnlyMiddleware,
} from "../middlewares/authorized.middleware";

const router = Router();
const cartController = new CartController();

// ───── Customer-facing cart routes ─────

router.post(
  "/add",
  authorizedMiddleware,
  customerOnlyMiddleware,
  cartController.addToCart
);

router.get(
  "/",
  authorizedMiddleware,
  customerOnlyMiddleware,
  cartController.getCart
);

router.put(
  "/update",
  authorizedMiddleware,
  customerOnlyMiddleware,
  cartController.updateQuantity
);

router.delete(
  "/remove/:productId",
  authorizedMiddleware,
  customerOnlyMiddleware,
  cartController.removeFromCart
);

router.delete(
  "/clear",
  authorizedMiddleware,
  customerOnlyMiddleware,
  cartController.clearCart
);

export default router;