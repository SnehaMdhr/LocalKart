import { Request, Response } from "express";
import { NotificationService } from "../services/notification.service";

const notificationService = new NotificationService();

export class NotificationController {
  /**
   * GET /notification
   * Return paginated notifications for the logged-in user.
   */
  async getNotifications(req: Request, res: Response) {
    try {
      const userId = req.user!._id.toString();
      const page = Number(req.query.page) || 1;
      const limit = Number(req.query.limit) || 20;

      const result = await notificationService.getNotifications(
        userId,
        page,
        limit
      );

      return res.status(200).json({
        success: true,
        ...result,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  /**
   * GET /notification/unread-count
   * Return the unread notification count for the logged-in user.
   */
  async getUnreadCount(req: Request, res: Response) {
    try {
      const userId = req.user!._id.toString();

      const result = await notificationService.getUnreadCount(userId);

      return res.status(200).json({
        success: true,
        data: result,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  /**
   * PATCH /notification/:id/read
   * Mark a single notification as read.
   */
  async markAsRead(req: Request, res: Response) {
    try {
      const userId = req.user!._id.toString();
      const notificationId = String(req.params.id);

      await notificationService.markAsRead(notificationId, userId);

      return res.status(200).json({
        success: true,
        message: "Notification marked as read",
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  /**
   * PATCH /notification/read-all
   * Mark all notifications as read for the logged-in user.
   */
  async markAllAsRead(req: Request, res: Response) {
    try {
      const userId = req.user!._id.toString();

      await notificationService.markAllAsRead(userId);

      return res.status(200).json({
        success: true,
        message: "All notifications marked as read",
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  /**
   * DELETE /notification/:id
   * Delete a notification.
   */
  async deleteNotification(req: Request, res: Response) {
    try {
      const userId = req.user!._id.toString();
      const notificationId = String(req.params.id);

      await notificationService.deleteNotification(notificationId, userId);

      return res.status(200).json({
        success: true,
        message: "Notification deleted successfully",
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }
}
