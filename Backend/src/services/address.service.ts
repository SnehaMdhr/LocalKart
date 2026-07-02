import mongoose from "mongoose";
import {
  CreateAddressDTO,
  UpdateAddressDTO,
} from "../dtos/address.dtos";
import { HttpError } from "../errors/https-error";
import { IAddress } from "../model/address.model";
import { AddressRepository } from "../repositories/address.repository";

const addressRepository = new AddressRepository();

export class AddressService {
  async createAddress(
    userId: string,
    data: CreateAddressDTO
  ): Promise<IAddress> {
    return await addressRepository.createAddress({
      ...data,
      userId: new mongoose.Types.ObjectId(userId),
    });
  }

  async getAddresses(userId: string): Promise<IAddress[]> {
    return await addressRepository.getAddressesByUserId(userId);
  }

  async getAddressById(
    userId: string,
    addressId: string
  ): Promise<IAddress> {
    const address = await addressRepository.getAddressById(addressId);

    if (!address) {
      throw new HttpError(404, "Address not found");
    }

    const ownerId =
      typeof address.userId === "object" &&
      address.userId !== null &&
      "_id" in address.userId
        ? address.userId._id.toString()
        : address.userId;

    if (ownerId !== userId) {
      throw new HttpError(403, "Unauthorized");
    }

    return address;
  }

  async updateAddress(
    userId: string,
    addressId: string,
    data: UpdateAddressDTO
  ): Promise<IAddress> {
    const address = await addressRepository.getAddressById(addressId);

    if (!address) {
      throw new HttpError(404, "Address not found");
    }

    const ownerId =
      typeof address.userId === "object" &&
      address.userId !== null &&
      "_id" in address.userId
        ? address.userId._id.toString()
        : address.userId;

    if (ownerId !== userId) {
      throw new HttpError(403, "Unauthorized");
    }

    const updated = await addressRepository.updateAddress(addressId, data);

    if (!updated) {
      throw new HttpError(404, "Address not found");
    }

    return updated;
  }

  async deleteAddress(
    userId: string,
    addressId: string
  ): Promise<void> {
    const address = await addressRepository.getAddressById(addressId);

    if (!address) {
      throw new HttpError(404, "Address not found");
    }

    const ownerId =
      typeof address.userId === "object" &&
      address.userId !== null &&
      "_id" in address.userId
        ? address.userId._id.toString()
        : address.userId;

    if (ownerId !== userId) {
      throw new HttpError(403, "Unauthorized");
    }

    const deleted = await addressRepository.deleteAddress(addressId);

    if (!deleted) {
      throw new HttpError(404, "Address not found");
    }
  }
}