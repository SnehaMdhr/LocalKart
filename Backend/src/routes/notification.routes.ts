import { Router } from "express";
import { NotificationController } from "../controller/notification.controller";
import { authorizedMiddleware } from "../middlewares/authorized.middleware";

const router = Router();
const notificationController = new NotificationController();

// All notification routes require authentication
router.use(authorizedMiddleware);

// GET /notification — list notifications for logged-in user
router.get("/", notificationController.getNotifications);

// GET /notification/unread-count — unread count
router.get("/unread-count", notificationController.getUnreadCount);

// PATCH /notification/read-all — mark all as read
router.patch("/read-all", notificationController.markAllAsRead);

// PATCH /notification/:id/read — mark single as read
router.patch("/:id/read", notificationController.markAsRead);

// DELETE /notification/:id — delete a notification
router.delete("/:id", notificationController.deleteNotification);

export default router;
