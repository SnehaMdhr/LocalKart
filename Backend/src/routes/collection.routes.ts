import { Router } from "express";
import { CollectionController } from "../controller/collection.controller";
import {
  adminOnlyMiddleware,
  authorizedMiddleware,
  customerOnlyMiddleware,
} from "../middlewares/authorized.middleware";

const router = Router();
const collectionController = new CollectionController();

// ───── Customer-facing collection routes ─────

router.post(
  "/add-collection",
  authorizedMiddleware,
  customerOnlyMiddleware,
  collectionController.createCollection
);

router.get(
  "/my",
  authorizedMiddleware,
  collectionController.getMyCollections
);

router.get(
  "/:id",
  authorizedMiddleware,
  collectionController.getCollectionById
);

router.put(
  "/:id",
  authorizedMiddleware,
  collectionController.updateCollection
);

router.delete(
  "/:id",
  authorizedMiddleware,
  collectionController.deleteCollection
);

router.post(
    "/:id/add-product",
    authorizedMiddleware,
    customerOnlyMiddleware,
    collectionController.addProduct
);
router.delete(
  "/:id/remove-product",
  authorizedMiddleware,
  customerOnlyMiddleware,
  collectionController.removeProduct
);
export default router;
