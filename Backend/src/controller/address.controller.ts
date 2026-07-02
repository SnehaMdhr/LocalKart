import { Request, Response } from "express";
import {
  CreateAddressDTO,
  UpdateAddressDTO,
} from "../dtos/address.dtos";
import { AddressService } from "../services/address.service";

const addressService = new AddressService();

export class AddressController {
  async createAddress(req: Request, res: Response) {
    try {
      const userId = req.user!._id.toString();

      const validatedData = CreateAddressDTO.parse(req.body);

      const address = await addressService.createAddress(
        userId,
        validatedData
      );

      return res.status(201).json({
        success: true,
        message: "Address created successfully",
        data: address,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async getAddresses(req: Request, res: Response) {
    try {
      const addresses = await addressService.getAddresses(
        req.user!._id.toString()
      );

      return res.status(200).json({
        success: true,
        data: addresses,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async getAddressById(req: Request, res: Response) {
    try {
      const address = await addressService.getAddressById(
        req.user!._id.toString(),
        req.params.id.toString()
      );

      return res.status(200).json({
        success: true,
        data: address,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async updateAddress(req: Request, res: Response) {
    try {
      const validatedData = UpdateAddressDTO.parse(req.body);

      const address = await addressService.updateAddress(
        req.user!._id.toString(),
        req.params.id.toString(),
        validatedData
      );

      return res.status(200).json({
        success: true,
        message: "Address updated successfully",
        data: address,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async deleteAddress(req: Request, res: Response) {
    try {
      await addressService.deleteAddress(
        req.user!._id.toString(),
        req.params.id.toString()
      );

      return res.status(200).json({
        success: true,
        message: "Address deleted successfully",
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

}