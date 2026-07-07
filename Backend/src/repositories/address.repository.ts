import mongoose, { Types } from "mongoose";
import { AddressModel, IAddress } from "../model/address.model";

export interface IAddressRepository {
  createAddress(addressData: Partial<IAddress>): Promise<IAddress>;

  getAddressById(id: string): Promise<IAddress | null>;

  getAddressesByUserId(userId: string): Promise<IAddress[]>;

  updateAddress(
    id: string,
    updateData: Partial<IAddress>
  ): Promise<IAddress | null>;

  deleteAddress(id: string): Promise<boolean>;
}

export class AddressRepository implements IAddressRepository {
  async createAddress(addressData: Partial<IAddress>): Promise<IAddress> {
    const address = new AddressModel(addressData);
    return await address.save();
  }

  async getAddressById(id: string): Promise<IAddress | null> {
    return AddressModel.findById(id).populate("userId");
  }

  async getAddressesByUserId(userId: string): Promise<IAddress[]> {
    return AddressModel.find({
      userId: new Types.ObjectId(userId),
    }).populate("userId");
  }

  async updateAddress(
    id: string,
    updateData: Partial<IAddress>
  ): Promise<IAddress | null> {
    return AddressModel.findByIdAndUpdate(id, updateData, {
      new: true,
      runValidators: true,
    }).populate("userId");
  }

  async deleteAddress(id: string): Promise<boolean> {
    const result = await AddressModel.findByIdAndDelete(id);
    return result ? true : false;
  }
}