import { Router } from "express";
import { OrderController } from "../controller/order.controller";
import {
  authorizedMiddleware,
  customerOnlyMiddleware,
  shopkeeperOnlyMiddleware,
  adminOnlyMiddleware,
} from "../middlewares/authorized.middleware";

const router = Router();
const orderController = new OrderController();

// ───── Customer-facing order routes ─────

// Place an order
router.post(
  "/",
  authorizedMiddleware,
  customerOnlyMiddleware,
  orderController.createOrder
);

// View my orders (customer)
router.get(
  "/",
  authorizedMiddleware,
  customerOnlyMiddleware,
  orderController.getMyOrders
);

// ───── Shared route (both customers & shopkeepers) ─────

// View single order (authorization enforced in service layer)
router.get(
  "/:id",
  authorizedMiddleware,
  orderController.getOrderById
);

// ───── Vendor-facing order routes ─────

// Accept an order (assign to shop & mark as Accepted)
router.patch(
  "/:id/accept",
  authorizedMiddleware,
  shopkeeperOnlyMiddleware,
  orderController.acceptOrder
);

// Reject an order
router.patch(
  "/:id/reject",
  authorizedMiddleware,
  shopkeeperOnlyMiddleware,
  orderController.rejectOrder
);

// Update order status
router.patch(
  "/:id/status",
  authorizedMiddleware,
  shopkeeperOnlyMiddleware,
  orderController.updateOrderStatus
);

// ───── Admin-only route ─────

// Delete an order
router.delete(
  "/:id",
  authorizedMiddleware,
  adminOnlyMiddleware,
  orderController.deleteOrder
);

export default router;