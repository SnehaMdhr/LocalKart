import { Router } from "express";
import { ShopController } from "../controller/shop.controller";
import { adminOnlyMiddleware, authorizedMiddleware, shopkeeperOnlyMiddleware } from "../middlewares/authorized.middleware";
import { uploads } from "../middlewares/upload.middleware";

let shopController = new ShopController();

const router = Router();

router.post("/register-shop", authorizedMiddleware, shopController.createShop)
router.get("/my-shop", authorizedMiddleware,shopController.getMyShop)
router.get("/:id", authorizedMiddleware, shopController.getShopById)
router.put("/update-shop",authorizedMiddleware,shopkeeperOnlyMiddleware,uploads.single("imageUrl"),shopController.updateShop);
router.delete("/delete-shop/:id",authorizedMiddleware,adminOnlyMiddleware,shopController.deleteShop);
router.get("/",authorizedMiddleware,adminOnlyMiddleware,shopController.getAllShops);
router.patch("/admin/:id/approve",authorizedMiddleware,adminOnlyMiddleware,shopController.approveShop);
router.patch("/admin/:id/reject",authorizedMiddleware,adminOnlyMiddleware,shopController.rejectShop);
router.patch("/admin/:id/suspend",authorizedMiddleware,adminOnlyMiddleware,shopController.suspendShop);

export default router;