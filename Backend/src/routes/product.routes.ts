import { Router } from "express";
import { ProductController } from "../controller/product.controller";
import { adminOnlyMiddleware, authorizedMiddleware } from "../middlewares/authorized.middleware";
import { uploads } from "../middlewares/upload.middleware";

const router = Router();
const productController = new ProductController();

router.post("/create-product", authorizedMiddleware, adminOnlyMiddleware, uploads.single("imageUrl"), productController.createProduct);

router.get("/admin/paginated",authorizedMiddleware, adminOnlyMiddleware, productController.getAllPaginatedForAdmin);

router.get("/admin",authorizedMiddleware, adminOnlyMiddleware, productController.getAllProductsForAdmin);

router.get("/admin/:id",authorizedMiddleware, adminOnlyMiddleware, productController.getProductsByIdAdmin);

router.get("/paginated",productController.getPaginatedProducts);

router.get("/", productController.getAllProducts);

router.get("/:id",productController.getProductById);

router.put("/:id",authorizedMiddleware, adminOnlyMiddleware, uploads.single("imageUrl"), productController.updateProduct);

router.delete("/:id", authorizedMiddleware, adminOnlyMiddleware,productController.deleteProduct);

router.patch("/:id/activate",authorizedMiddleware, adminOnlyMiddleware, productController.activateProduct);

router.patch("/:id/deactivate",authorizedMiddleware, adminOnlyMiddleware,productController.deactivateProduct);

export default router;