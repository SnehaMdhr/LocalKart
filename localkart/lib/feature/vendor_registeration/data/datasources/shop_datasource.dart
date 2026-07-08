import 'package:localkart/feature/vendor_registeration/data/models/shop_api_model.dart';
import 'package:localkart/feature/vendor_registeration/data/models/shop_hive_model.dart';

abstract interface class IShopLocalDatasource {
  Future<bool> registerShop(ShopHiveModel model);
}

abstract interface class IShopRemoteDatasource {
  Future<ShopApiModel?> registerShop(ShopApiModel model);
  Future<ShopApiModel?> getMyShop();
  Future<ShopApiModel?> updateShop(ShopApiModel model);
}
