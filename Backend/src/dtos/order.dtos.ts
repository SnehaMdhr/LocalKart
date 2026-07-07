import z from "zod";
import { orderSchema } from "../types/order.type";

// Customer places an order
export const CreateOrderDTO = orderSchema.pick({
  deliveryAddress: true,
  paymentMethod: true,
  customerNote: true,
});

export type CreateOrderDTO = z.infer<typeof CreateOrderDTO>;

// Shopkeeper accepts an order
export const AcceptOrderDTO = z.object({
  estimatedDeliveryTime: z.number().int().positive().optional(),
});

export type AcceptOrderDTO = z.infer<typeof AcceptOrderDTO>;

// Shopkeeper updates order status
export const UpdateOrderStatusDTO = z.object({
  status: z.enum([
    "Preparing",
    "Out for Delivery",
    "Delivered",
    "Cancelled",
  ]),
});

export type UpdateOrderStatusDTO = z.infer<
  typeof UpdateOrderStatusDTO
>;

// Reject order (currently no request body needed)
export const RejectOrderDTO = z.object({});

export type RejectOrderDTO = z.infer<typeof RejectOrderDTO>;