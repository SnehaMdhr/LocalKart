import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/services/hive/hive.service.dart';
import '../../models/shop_hive_model.dart';
import '../shop_datasource.dart';

final shopLocalDatasourceProvider = Provider<ShopLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return ShopLocalDatasource(hiveService: hiveService);
});

class ShopLocalDatasource implements IShopLocalDatasource {
  final HiveService _hiveService;

  ShopLocalDatasource({required HiveService hiveService})
      : _hiveService = hiveService;

  @override
  Future<bool> registerShop(ShopHiveModel model) async {
    try {
      await _hiveService.registerShop(model);
      return true;
    } catch (e) {
      return false;
    }
  }
}
