import { Types } from "mongoose";
import { IRating, RatingModel } from "../model/rating.model";

export interface IRatingRepository {
  create(data: Partial<IRating>): Promise<IRating>;
  findById(id: string): Promise<IRating | null>;
  findByOrderId(orderId: string): Promise<IRating | null>;
  findByVendorId(vendorId: string): Promise<IRating[]>;
  findByShopId(shopId: string): Promise<IRating[]>;
  update(id: string, data: Partial<IRating>): Promise<IRating | null>;
  delete(id: string): Promise<boolean>;
  getStatsByShopId(shopId: string): Promise<{
    averageRating: number;
    totalRatings: number;
    distribution: { [key: number]: number };
  }>;
}

export class RatingRepository implements IRatingRepository {
  async create(data: Partial<IRating>): Promise<IRating> {
    const rating = new RatingModel(data);
    return await rating.save();
  }

  async findById(id: string): Promise<IRating | null> {
    return RatingModel.findById(id)
      .populate("customerId", "name email imageUrl")
      .populate("orderId", "orderNumber");
  }

  async findByOrderId(orderId: string): Promise<IRating | null> {
    return RatingModel.findOne({ orderId: new Types.ObjectId(orderId) })
      .populate("customerId", "name email imageUrl");
  }

  async findByVendorId(vendorId: string): Promise<IRating[]> {
    return RatingModel.find({ vendorId: new Types.ObjectId(vendorId) })
      .populate("customerId", "name email imageUrl")
      .populate("orderId", "orderNumber")
      .sort({ createdAt: -1 });
  }

  async findByShopId(shopId: string): Promise<IRating[]> {
    return RatingModel.find({ shopId: new Types.ObjectId(shopId) })
      .populate("customerId", "name email imageUrl")
      .populate("orderId", "orderNumber")
      .sort({ createdAt: -1 });
  }

  async update(id: string, data: Partial<IRating>): Promise<IRating | null> {
    return RatingModel.findByIdAndUpdate(id, data, {
      returnDocument: "after",
      runValidators: true,
    })
      .populate("customerId", "name email imageUrl")
      .populate("orderId", "orderNumber");
  }

  async delete(id: string): Promise<boolean> {
    const result = await RatingModel.findByIdAndDelete(id);
    return result ? true : false;
  }

  async getStatsByShopId(shopId: string): Promise<{
    averageRating: number;
    totalRatings: number;
    distribution: { [key: number]: number };
  }> {
    const ratings = await RatingModel.find({
      shopId: new Types.ObjectId(shopId),
    });

    const totalRatings = ratings.length;
    if (totalRatings === 0) {
      return {
        averageRating: 0,
        totalRatings: 0,
        distribution: { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 },
      };
    }

    const sum = ratings.reduce((acc, r) => acc + r.rating, 0);
    const averageRating = parseFloat((sum / totalRatings).toFixed(1));

    const distribution: { [key: number]: number } = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 };
    for (const r of ratings) {
      distribution[r.rating] = (distribution[r.rating] || 0) + 1;
    }

    return { averageRating, totalRatings, distribution };
  }
}
