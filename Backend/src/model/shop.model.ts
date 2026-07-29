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

    latitude: {
      type: Number,
      required: false,
    },

    longitude: {
      type: Number,
      required: false,
    },

    categories: {
      type: [String],
      enum: [
        "Fruits & Vegetables",
        "Dairy & Eggs",
        "Meat & Seafood",
        "Bakery",
        "Beverages",
        "Snacks & Confectionery",
        "Frozen Foods",
        "Organic & Health Foods",
        "Pantry Staples",
        "Baby & Pet",
      ],
      required: true,
      validate: {
        validator: (v: string[]) => v.length > 0,
        message: "At least one category is required",
      },
    },

    status: {
      type: String,
      enum: ["pending", "approved", "rejected", "suspended"],
      default: "pending",
    },

    averageRating: {
      type: Number,
      default: 0,
      min: 0,
      max: 5,
    },

    totalRatings: {
      type: Number,
      default: 0,
      min: 0,
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