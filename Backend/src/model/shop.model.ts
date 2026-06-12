import mongoose, { Document, Schema } from "mongoose";
import { ShopType } from "../types/shop.type";

const ShopSchema: Schema = new Schema<ShopType>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true,
      unique: true, 
    },

    shopName: {
      type: String,
      required: true,
      minlength: 3,
    },

    address: {
      type: String,
      required: true,
    },

    description: {
      type: String,
      required: true,
      minlength: 10,
    },
    imageUrl: {
      type: String,
      required: false,
    },

    category: {
      type: String,
      enum: [
        "Grocery",
        "Electronics",
        "Clothing",
        "Restaurant",
        "Pharmacy",
        "Stationery",
        "Hardware",
        "Other",
      ],
      required: true,
    },

    status: {
      type: String,
      enum: ["pending", "approved", "rejected", "suspended"],
      default: "pending",
    },
  },
  { timestamps: true }
);

export interface IShop extends ShopType, Document {
  _id: mongoose.Types.ObjectId;
  userId: mongoose.Types.ObjectId;
  createdAt: Date;
  updatedAt: Date;
}

export const ShopModel = mongoose.model<IShop>("Shop", ShopSchema);