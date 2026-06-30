import mongoose, { Schema } from "mongoose";
import { OrderType } from "../types/order.type";

const orderSchema = new Schema(
  {
    customerId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    shopId: {
      type: Schema.Types.ObjectId,
      ref: "Shop",
      default: null,
    },

    items: [
      {
        productId: {
          type: Schema.Types.ObjectId,
          ref: "Product",
          required: true,
        },

        quantity: {
          type: Number,
          required: true,
          min: 1,
        },
      },
    ],

    totalAmount: {
      type: Number,
      required: true,
      min: 0,
    },

    deliveryAddress: {
      type: String,
      required: true,
      trim: true,
    },

    paymentMethod: {
      type: String,
      required: true,
      enum: ["Cash on Delivery", "eSewa"],
    },

    paymentStatus: {
      type: String,
      required: true,
      enum: ["Pending", "Paid"],
      default: "Pending",
    },

    status: {
      type: String,
      required: true,
      enum: [
        "Pending",
        "Accepted",
        "Rejected",
        "Preparing",
        "Out for Delivery",
        "Delivered",
        "Cancelled",
      ],
      default: "Pending",
    },
  },
  {
    timestamps: true,
  }
);

export interface IOrder extends OrderType, mongoose.Document {
  _id: mongoose.Types.ObjectId;
  createdAt: Date;
  updatedAt: Date;
}

export const OrderModel = mongoose.model<IOrder>("Order", orderSchema);