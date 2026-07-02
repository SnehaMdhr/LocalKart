import mongoose, { Schema } from "mongoose";
import { AddressType } from "../types/address.type";

const addressSchema = new Schema(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    label: {
      type: String,
      enum: ["Home", "Work", "Other"],
      default: "Home",
    },

    fullAddress: {
      type: String,
      required: true,
      trim: true,
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
  {
    timestamps: true,
  }
);

export interface IAddress extends AddressType, mongoose.Document {
  _id: mongoose.Types.ObjectId;
  createdAt: Date;
  updatedAt: Date;
}

export const AddressModel = mongoose.model<IAddress>(
  "Address",
  addressSchema
);