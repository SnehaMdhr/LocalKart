
import mongoose from "mongoose";
import { CreateShopDto, UpdateShopDto } from "../dtos/shop.dtos";
import { HttpError } from "../errors/https-error";
import { IShop } from "../model/shop.model";
import { ShopRepository } from "../repositories/shop.repository";
import { UserRepository } from "../repositories/user.repository";
import { deleteUploadIfExists } from "../middlewares/upload.middleware";

const shopRepository = new ShopRepository();
const userRepository = new UserRepository();

export class ShopService {

  async createShop(
  userId: string,
  data: CreateShopDto
): Promise<IShop> {

  const existingShop =
    await shopRepository.getShopByUserId(userId);

  if (existingShop) {
    throw new HttpError(
      400,
      "You have already registered a shop"
    );
  }

  return await shopRepository.createShop({
    ...data,
    userId: new mongoose.Types.ObjectId(userId),
    status: "pending",
  });
}

  async getShopById(id: string): Promise<IShop> {

    const shop =
      await shopRepository.getShopById(id);

    if (!shop) {
      throw new HttpError(
        404,
        "Shop not found"
      );
    }

    return shop;
  }

  async getAllShops(): Promise<IShop[]> {
    return await shopRepository.getAllShops();
  }

  async getPaginatedShops(
    page: number,
    size: number,
    search?: string
  ) {
    return await shopRepository.getAllPaginated(
      page,
      size,
      search
    );
  }

 async updateShop(
  userId: string,
  updateData: UpdateShopDto
): Promise<IShop> {

  const shop = await shopRepository.getShopByUserId(userId);

  if (!shop) {
    throw new HttpError(
      404,
      "Shop not found"
    );
  }

  if (
    updateData.imageUrl &&
    shop.imageUrl &&
    shop.imageUrl !== updateData.imageUrl
  ) {
    try {
      deleteUploadIfExists(shop.imageUrl);
    } catch (error) {
      console.error("Error deleting old image:", error);
    }
  }

  const updatedShop = await shopRepository.updateShop(
    shop._id.toString(),
    updateData as Partial<IShop>
  );

  if (!updatedShop) {
    throw new HttpError(
      404,
      "Shop not found"
    );
  }

  return updatedShop;
}
 async deleteShop(id: string): Promise<boolean> {

  const shop = await shopRepository.getShopById(id);

  if (!shop) {
    throw new HttpError(
      404,
      "Shop not found"
    );
  }

  if (shop.imageUrl) {
    deleteUploadIfExists(shop.imageUrl);
  }

  await shopRepository.deleteShop(id);

  return true;
}

  async approveShop(id: string): Promise<IShop> {

    const shop =
      await shopRepository.getShopById(id);

    if (!shop) {
      throw new HttpError(
        404,
        "Shop not found"
      );
    }

    const updatedShop =
      await shopRepository.updateShop(
        id,
        {
          status: "approved"
        }
      );

    await userRepository.updateUser(
      shop.userId.toString(),
      {
        role: "Shopkeeper"
      }
    );

    return updatedShop!;
  }

  async rejectShop(id: string): Promise<IShop> {

    const shop =
      await shopRepository.updateShop(
        id,
        {
          status: "rejected"
        }
      );

    if (!shop) {
      throw new HttpError(
        404,
        "Shop not found"
      );
    }

    return shop;
  }

  async suspendShop(id: string): Promise<IShop> {

    const shop =
      await shopRepository.updateShop(
        id,
        {
          status: "suspended"
        }
      );

    if (!shop) {
      throw new HttpError(
        404,
        "Shop not found"
      );
    }

    await userRepository.updateUser(
      shop.userId.toString(),
      {
        role: "Customer"
      }
    );

    return shop;
  }

  async getMyShop(
    userId: string
  ): Promise<IShop> {

    const shop =
      await shopRepository.getShopByUserId(
        userId
      );

    if (!shop) {
      throw new HttpError(
        404,
        "Shop not found"
      );
    }

    return shop;
  }
}