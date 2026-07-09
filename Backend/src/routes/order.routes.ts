import { Router } from "express";
import { OrderController } from "../controller/order.controller";
import {
  adminOnlyMiddleware,
  authorizedMiddleware,
  customerOnlyMiddleware,
  shopkeeperOnlyMiddleware,
} from "../middlewares/authorized.middleware";

const router = Router();
const orderController = new OrderController();


router.post(
  "/",
  authorizedMiddleware,
  customerOnlyMiddleware,
  orderController.createOrder
);

router.get(
  "/my-orders",
  authorizedMiddleware,
  customerOnlyMiddleware,
  orderController.getCustomerOrders
);

router.get(
  "/:id",
  authorizedMiddleware,
  orderController.getOrderById
);

router.get(
  "/:id/etd",
  authorizedMiddleware,
  orderController.getEtd
);

router.get(
  "/shop/pending",
  authorizedMiddleware,
  shopkeeperOnlyMiddleware,
  orderController.getPendingOrders
);

router.get(
  "/shop/orders",
  authorizedMiddleware,
  shopkeeperOnlyMiddleware,
  orderController.getShopOrders
);

router.patch(
  "/:id/accept",
  authorizedMiddleware,
  shopkeeperOnlyMiddleware,
  orderController.acceptOrder
);

router.patch(
  "/:id/reject",
  authorizedMiddleware,
  shopkeeperOnlyMiddleware,
  orderController.rejectOrder
);

router.patch(
  "/:id/status",
  authorizedMiddleware,
  shopkeeperOnlyMiddleware,
  orderController.updateStatus
);

router.patch(
  "/:orderId/mark-paid",
  authorizedMiddleware,
  shopkeeperOnlyMiddleware,
  orderController.markOrderPaid
);

router.delete(
  "/:id",
  authorizedMiddleware,
  adminOnlyMiddleware,
  orderController.deleteOrder
);

export default router;