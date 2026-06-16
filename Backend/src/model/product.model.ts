import mongoose, { Schema, model } from "mongoose";
import { ProductType } from "../types/product.type";

const productSchema = new Schema<IProduct>(
  {
    productName: {
      type: String,
      required: true,
      minlength: 2,
      maxlength: 100,
    },

    description: {
      type: String,
      maxlength: 256,
    },

    categoryName: {
      type: String,
      required: true,
      enum: [
        "Fruits",
        "Vegetables",
        "Dairy & Eggs",
        "Rice, Flour & Grains",
        "Pulses & Lentils",
        "Cooking Oil & Ghee",
        "Spices & Masala",
        "Tea, Coffee & Beverages",
        "Snacks & Biscuits",
        "Bakery & Bread",
        "Frozen Foods",
        "Personal Care",
        "Household Essentials",
        "Baby Care",
      ],
    },

    imageUrl: {
      type: String,
      required: false,
    },

    unit: {
      type: String,
      required: true,
    },

    isActive: {
      type: Boolean,
      required: false,
    },
  },
  {
    timestamps: true,
  }
);

export interface IProduct extends ProductType, mongoose.Document {
  _id: mongoose.Types.ObjectId;
  createdAt: Date;
  updatedAt: Date;
}

export const ProductModel = mongoose.model<IProduct>("Product",productSchema);