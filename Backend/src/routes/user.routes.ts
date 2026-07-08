import { Router } from "express";
import { AuthController } from "../controller/user.controller";
import { adminOnlyMiddleware, authorizedMiddleware } from "../middlewares/authorized.middleware";
import { uploads } from "../middlewares/upload.middleware";


let authController = new AuthController();
const router = Router();

router.post("/register", authController.register)
router.post("/login",authController.login)
router.get("/view-my-profile", authorizedMiddleware, authController.getUserById);
router.put("/update-profile", authorizedMiddleware,uploads.single("imageUrl"),authController.updateUser);
router.delete("/delete-profile",authorizedMiddleware, authController.deleteUser);
router.post("/change-password",authorizedMiddleware,authController.changePassword);
router.post("/request-password-reset", authController.requestPasswordResetOTP);
router.post("/reset-password", authController.resetPasswordOTP);
router.post("/google-login", authController.googleLogin);


router.get("/", authorizedMiddleware, adminOnlyMiddleware, authController.getAllUsers);
router.get("/:id", authorizedMiddleware, adminOnlyMiddleware, authController.getOneUser);
router.delete('/:id', authorizedMiddleware, adminOnlyMiddleware, authController.deleteUser);
router.put("/:id",authorizedMiddleware, adminOnlyMiddleware,uploads.single("imageUrl"), authController.updateUser);

export default router;