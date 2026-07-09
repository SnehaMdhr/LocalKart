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
      ref: "User",
      default: null,
    },

    orderNumber: {
      type: String,
      required: true,
      unique: true,
    },

    items: [
      {
        productId: {
          type: Schema.Types.ObjectId,
          ref: "Product",
          required: true,
        },

        productName: {
          type: String,
          required: true,
        },

        price: {
          type: Number,
          required: true,
          min: 0,
        },

        quantity: {
          type: Number,
          required: true,
          min: 1,
        },
      },
    ],

    deliveryAddress: {
      fullAddress: {
        type: String,
        required: true,
      },

      latitude: {
        type: Number,
        required: true,
      },

      longitude: {
        type: Number,
        required: true,
      },
    },

    totalAmount: {
      type: Number,
      required: true,
      min: 0,
    },

    paymentMethod: {
      type: String,
      enum: ["Cash on Delivery", "eSewa(Pay on Delivery)", "Khalti(Pay on Delivery)"],
      required: true,
    },

    paymentStatus: {
      type: String,
      enum: ["Pending", "Paid", "Failed"],
      default: "Pending",
    },

    status: {
      type: String,
      enum: [
        "Pending",
        "Accepted",
        "Preparing",
        "Out for Delivery",
        "Delivered",
        "Cancelled",
        "Rejected",
      ],
      default: "Pending",
    },

    rejectedBy: [
      {
        type: Schema.Types.ObjectId,
        ref: "User",
      },
    ],

    customerNote: {
      type: String,
      default: "",
    },

    estimatedDeliveryTime: {
      type: Number,
      default: null,
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