import mongoose, { Schema } from "mongoose";
import { RatingType } from "../types/rating.type";

const ratingSchema = new Schema(
  {
    orderId: {
      type: Schema.Types.ObjectId,
      ref: "Order",
      required: true,
      unique: true,
    },

    customerId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    vendorId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    shopId: {
      type: Schema.Types.ObjectId,
      ref: "Shop",
      required: true,
    },

    rating: {
      type: Number,
      required: true,
      min: 1,
      max: 5,
    },

    comment: {
      type: String,
      default: "",
      maxlength: 300,
    },
  },
  {
    timestamps: true,
  }
);

// Index for efficient vendor rating queries
ratingSchema.index({ shopId: 1, createdAt: -1 });
// orderId has unique: true on the field definition above (no duplicate index needed)

export interface IRating extends RatingType, mongoose.Document {
  _id: mongoose.Types.ObjectId;
  createdAt: Date;
  updatedAt: Date;
}

export const RatingModel = mongoose.model<IRating>("Rating", ratingSchema);
