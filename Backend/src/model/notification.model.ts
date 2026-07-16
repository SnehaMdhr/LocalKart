import mongoose, { Schema } from "mongoose";
import { NotificationType } from "../types/notification.type";

const notificationSchema = new Schema(
  {
    receiverId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },

    receiverRole: {
      type: String,
      enum: ["Customer", "Vendor"],
      required: true,
    },

    title: {
      type: String,
      required: true,
      maxlength: 200,
    },

    message: {
      type: String,
      required: true,
      maxlength: 1000,
    },

    type: {
      type: String,
      enum: [
        "ORDER_PLACED",
        "ORDER_ACCEPTED",
        "ORDER_REJECTED",
        "ORDER_PREPARING",
        "OUT_FOR_DELIVERY",
        "DELIVERED",
        "ORDER_CANCELLED",
        "SHOP_APPROVED",
        "SHOP_REJECTED",
        "SYSTEM",
      ],
      required: true,
    },

    orderId: {
      type: String,
      default: null,
    },

    shopId: {
      type: String,
      default: null,
    },

    orderNumber: {
      type: String,
      default: null,
    },

    shopName: {
      type: String,
      default: null,
    },

    isRead: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

// Index for efficient querying
notificationSchema.index({ receiverId: 1, createdAt: -1 });
notificationSchema.index({ receiverId: 1, isRead: 1 });

export interface INotification extends NotificationType, mongoose.Document {
  _id: mongoose.Types.ObjectId;
  createdAt: Date;
  updatedAt: Date;
}

export const NotificationModel = mongoose.model<INotification>(
  "Notification",
  notificationSchema
);
