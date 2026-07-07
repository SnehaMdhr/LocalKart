import z from "zod";
import { orderSchema } from "../types/order.type";

export const CreateOrderDto = orderSchema.omit({
  customerId: true,
  shopId: true,
  items: true,
  totalAmount: true,
  paymentStatus: true,
  status: true,
});

export type CreateOrderDto = z.infer<typeof CreateOrderDto>;

export const UpdateOrderStatusDto = z.object({
  status: z.enum([
    "Pending",
    "Accepted",
    "Rejected",
    "Preparing",
    "Out for Delivery",
    "Delivered",
    "Cancelled",
  ]),
});

export type UpdateOrderStatusDto = z.infer<typeof UpdateOrderStatusDto>;