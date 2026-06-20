import mongoose, { Schema, model } from "mongoose";
import { CollectionType } from "../types/collection.type";

const collectionSchema = new Schema(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true,
      unique: true,
    },

    collectionName: {
      type: String,
      required: true,
      minlength: 1,
      maxlength: 100,
    },

    productIds: {
      type: [Schema.Types.ObjectId],
      ref: "Product",
      default: [],
    },
  },
  {
    timestamps: true,
  }
);

export interface ICollection extends CollectionType, mongoose.Document {
  _id: mongoose.Types.ObjectId;
  createdAt: Date;
  updatedAt: Date;
}

export const CollectionModel = mongoose.model<ICollection>(
  "Collection",
  collectionSchema
);
