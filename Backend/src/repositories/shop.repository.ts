import {QueryFilter, Types } from "mongoose";
import { IShop, ShopModel } from "../model/shop.model";

export interface IShopRepository{
    createShop(shopData: Partial<IShop>): Promise<IShop>;
    getShopById(id: string): Promise<IShop | null>;
    getAllShops(): Promise<IShop[]>;
    updateShop(id: string, updateData: Partial<IShop>): Promise<IShop|null>;
    deleteShop(id:string): Promise<boolean>;
     getAllPaginated(page: number, size: number, search?: string)
        :Promise <{shops: IShop[]; total:number}>;
    getShopByUserId(userId: string): Promise<IShop | null>;
}


export class ShopRepository implements IShopRepository{
    getShopByUserId(userId: string): Promise<IShop | null> {
        return ShopModel.findOne({ userId: new Types.ObjectId(userId) });
    }
    async createShop(shopData: Partial<IShop>): Promise<IShop> {
        const shop = new ShopModel(shopData);
        return await shop.save();
    }
    async getShopById(id: string): Promise<IShop | null> {
        const shop = await ShopModel.findOne({"_id":id});
        return shop;
    }
    async getAllShops(): Promise<IShop[]> {
        const shops = await ShopModel.find();
        return shops;
    }
    async updateShop(id: string, updateData: Partial<IShop>): Promise<IShop | null> {
        const updatedShop = await ShopModel.findByIdAndUpdate(
            id, updateData, {new:true}
        );
        return updatedShop;
    }
    async deleteShop(id: string): Promise<boolean> {
        const result = await ShopModel.findByIdAndDelete(id);
        return result ? true : false;
    }
    async getAllPaginated(page: number, size: number, search?: string) {
        const query: QueryFilter<IShop> = {};
    
        if (search) {
            query.$or = [
                { name: { $regex: search, $options: 'i' } },
                { email: { $regex: search, $options: 'i' } }
            ];
        }
        const total = await ShopModel.countDocuments(query);
        const shops = await ShopModel.find(query)
                .skip((page - 1) * size)
                .limit(size)
                .select('name email role createdAt imageUrl') 
                .sort({ createdAt: -1 });
        
                return { shops, total };
    }

}