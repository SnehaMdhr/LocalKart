import mongoose from "mongoose";
import z from "zod";

export const NotificationTypeEnum = z.enum([
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
]);

export const ReceiverRoleEnum = z.enum(["Customer", "Vendor"]);

export const notificationSchema = z.object({
  receiverId: z.instanceof(mongoose.Types.ObjectId),
  receiverRole: ReceiverRoleEnum,
  title: z.string().min(1).max(200),
  message: z.string().min(1).max(1000),
  type: NotificationTypeEnum,
  orderId: z.string().nullable().optional(),
  shopId: z.string().nullable().optional(),
  orderNumber: z.string().optional(),
  shopName: z.string().optional(),
  isRead: z.boolean().default(false),
});

export type NotificationType = z.infer<typeof notificationSchema>;

export type NotificationTypeEnumType = z.infer<typeof NotificationTypeEnum>;

export type ReceiverRoleType = z.infer<typeof ReceiverRoleEnum>;
