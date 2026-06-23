import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/services/hive/hive.service.dart';
import 'package:localkart/feature/cart/data/datasource/cart_datasource.dart';
import 'package:localkart/feature/cart/data/models/cart_hive_model.dart';

final cartLocalDatasourceProvider = Provider<ICartLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return CartLocalDatasource(hiveService: hiveService);
});

class CartLocalDatasource implements ICartLocalDatasource {
  final HiveService _hiveService;

  CartLocalDatasource({required HiveService hiveService})
      : _hiveService = hiveService;

  @override
  Future<CartHiveModel?> getCart() async {
    try {
      return await _hiveService.getCart();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheCart(CartHiveModel? cart) async {
    try {
      await _hiveService.cacheCart(cart);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await _hiveService.clearCartLocally();
    } catch (e) {
      rethrow;
    }
  }
}
