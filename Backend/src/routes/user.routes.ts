import { Router } from "express";
import { AuthController } from "../controller/user.controller";
import { authorizedMiddleware } from "../middlewares/authorized.middleware";
import { uploads } from "../middlewares/upload.middleware";


let authController = new AuthController();
const router = Router();

router.post("/register", authController.register)
router.post("/login",authController.login)
router.get("/view-my-profile", authorizedMiddleware, authController.getUserById);
router.put("/update-profile", authorizedMiddleware,uploads.single("imageUrl"),authController.updateUser);

export default router;