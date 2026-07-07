import { Router } from "express";
import { AddressController } from "../controller/address.controller";
import {
  authorizedMiddleware,
  customerOnlyMiddleware,
} from "../middlewares/authorized.middleware";

const router = Router();
const addressController = new AddressController();

router.post(
  "/",
  authorizedMiddleware,
  customerOnlyMiddleware,
  addressController.createAddress
);

router.get(
  "/",
  authorizedMiddleware,
  customerOnlyMiddleware,
  addressController.getAddresses
);

router.get(
  "/:id",
  authorizedMiddleware,
  customerOnlyMiddleware,
  addressController.getAddressById
);

router.put(
  "/:id",
  authorizedMiddleware,
  customerOnlyMiddleware,
  addressController.updateAddress
);

router.delete(
  "/:id",
  authorizedMiddleware,
  customerOnlyMiddleware,
  addressController.deleteAddress
);


export default router;