import { Types } from "mongoose";
import {
  INotification,
  NotificationModel,
} from "../model/notification.model";

export interface INotificationRepository {
  findById(
    notificationId: string
  ): Promise<INotification | null>;

  create(
    notificationData: Partial<INotification>
  ): Promise<INotification>;

  getNotificationsByReceiver(
    receiverId: string,
    page: number,
    limit: number
  ): Promise<{ notifications: INotification[]; total: number }>;

  getUnreadCount(receiverId: string): Promise<number>;

  markAsRead(notificationId: string): Promise<INotification | null>;

  markAllAsRead(receiverId: string): Promise<void>;

  deleteNotification(notificationId: string): Promise<boolean>;
}

export class NotificationRepository implements INotificationRepository {
  async findById(
    notificationId: string
  ): Promise<INotification | null> {
    return NotificationModel.findById(notificationId);
  }

  async create(
    notificationData: Partial<INotification>
  ): Promise<INotification> {
    const notification = new NotificationModel(notificationData);
    return await notification.save();
  }

  async getNotificationsByReceiver(
    receiverId: string,
    page: number,
    limit: number
  ): Promise<{ notifications: INotification[]; total: number }> {
    const query = {
      receiverId: new Types.ObjectId(receiverId),
    };

    const total = await NotificationModel.countDocuments(query);

    const notifications = await NotificationModel.find(query)
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(limit)
      .lean();

    return { notifications, total };
  }

  async getUnreadCount(receiverId: string): Promise<number> {
    return NotificationModel.countDocuments({
      receiverId: new Types.ObjectId(receiverId),
      isRead: false,
    });
  }

  async markAsRead(notificationId: string): Promise<INotification | null> {
    return NotificationModel.findByIdAndUpdate(
      notificationId,
      { isRead: true },
      { returnDocument: 'after' }
    );
  }

  async markAllAsRead(receiverId: string): Promise<void> {
    await NotificationModel.updateMany(
      { receiverId: new Types.ObjectId(receiverId), isRead: false },
      { isRead: true }
    );
  }

  async deleteNotification(notificationId: string): Promise<boolean> {
    const result = await NotificationModel.findByIdAndDelete(notificationId);
    return result ? true : false;
  }
}
