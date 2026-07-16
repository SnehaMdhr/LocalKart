import { Types } from "mongoose";
import { HttpError } from "../errors/https-error";
import { INotification } from "../model/notification.model";
import { NotificationRepository } from "../repositories/notification.repository";
import { getIO } from "../socket";
import {
  NotificationTypeEnumType,
  ReceiverRoleType,
} from "../types/notification.type";

const notificationRepository = new NotificationRepository();

export class NotificationService {
  /**
   * Send a notification:
   * 1. Saves notification in MongoDB
   * 2. Emits via Socket.IO to the appropriate room
   */
  async sendNotification(data: {
    receiverId: string;
    receiverRole: ReceiverRoleType;
    title: string;
    message: string;
    type: NotificationTypeEnumType;
    orderId?: string | null;
    shopId?: string | null;
    orderNumber?: string | null;
    shopName?: string | null;
  }): Promise<INotification> {
    // ── Validate receiverId is a valid MongoDB ObjectId string ──
    if (!Types.ObjectId.isValid(data.receiverId)) {
      const invalidValue =
        typeof data.receiverId === "string" && data.receiverId.length > 50
          ? data.receiverId.substring(0, 50) + "..."
          : JSON.stringify(data.receiverId);

      console.error(
        `[Notification] Invalid receiverId: ${invalidValue}. ` +
          `Expected a valid 24-character hex string. ` +
          `type=${data.type}, receiverRole=${data.receiverRole}`
      );

      throw new Error(
        `Cannot send ${data.type} notification: Invalid receiverId. ` +
          `Expected a valid MongoDB ObjectId string, got typeof=${typeof data.receiverId}.`
      );
    }

    const notification = await notificationRepository.create({
      receiverId: data.receiverId as any,
      receiverRole: data.receiverRole,
      title: data.title,
      message: data.message,
      type: data.type,
      orderId: data.orderId || undefined,
      shopId: data.shopId || undefined,
      orderNumber: data.orderNumber || undefined,
      shopName: data.shopName || undefined,
      isRead: false,
    });

    // Emit via Socket.IO to the correct room
    const io = getIO();
    if (io) {
      const roomName =
        data.receiverRole === "Customer"
          ? `customer_${data.receiverId}`
          : `vendor_${data.receiverId}`;

      const notificationPayload = {
        _id: notification._id.toString(),
        receiverId: data.receiverId,
        receiverRole: data.receiverRole,
        title: data.title,
        message: data.message,
        type: data.type,
        orderId: data.orderId,
        shopId: data.shopId,
        orderNumber: data.orderNumber || null,
        shopName: data.shopName || null,
        isRead: false,
        createdAt: notification.createdAt?.toISOString(),
        updatedAt: notification.updatedAt?.toISOString(),
      };

      io.to(roomName).emit("new_notification", notificationPayload);

      // Also emit updated unread count
      const unreadCount = await notificationRepository.getUnreadCount(
        data.receiverId
      );
      io.to(roomName).emit("unread_count", unreadCount);
    }

    return notification;
  }

  async getNotifications(
    receiverId: string,
    page: number = 1,
    limit: number = 20
  ) {
    const { notifications, total } =
      await notificationRepository.getNotificationsByReceiver(
        receiverId,
        page,
        limit
      );

    const formatted = notifications.map((n: any) => ({
      _id: n._id.toString(),
      receiverId: n.receiverId.toString(),
      receiverRole: n.receiverRole,
      title: n.title,
      message: n.message,
      type: n.type,
      orderId: n.orderId ?? null,
      shopId: n.shopId ?? null,
      orderNumber: n.orderNumber ?? null,
      shopName: n.shopName ?? null,
      isRead: n.isRead,
      createdAt: n.createdAt,
      updatedAt: n.updatedAt,
    }));

    return {
      data: formatted,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getUnreadCount(receiverId: string) {
    const count = await notificationRepository.getUnreadCount(receiverId);
    return { count };
  }

  async markAsRead(notificationId: string, userId: string) {
    // First verify ownership without mutating
    const existing = await notificationRepository.findById(notificationId);
    if (!existing) {
      throw new HttpError(404, "Notification not found");
    }
    if (existing.receiverId.toString() !== userId) {
      throw new HttpError(403, "Forbidden: Not your notification");
    }

    // Now mark as read
    const notification = await notificationRepository.markAsRead(
      notificationId
    );

    if (!notification) {
      throw new HttpError(404, "Notification not found");
    }

    return notification;
  }

  async markAllAsRead(userId: string) {
    await notificationRepository.markAllAsRead(userId);
  }

  async deleteNotification(notificationId: string, userId: string) {
    // Verify ownership first (read-only)
    const existing = await notificationRepository.findById(notificationId);
    if (!existing) {
      throw new HttpError(404, "Notification not found");
    }
    if (existing.receiverId.toString() !== userId) {
      throw new HttpError(403, "Forbidden: Not your notification");
    }

    const deleted = await notificationRepository.deleteNotification(
      notificationId
    );

    if (!deleted) {
      throw new HttpError(404, "Notification not found");
    }
  }
}
