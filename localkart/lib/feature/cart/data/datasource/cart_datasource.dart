import 'package:localkart/feature/cart/data/models/cart_api_model.dart';
import 'package:localkart/feature/cart/data/models/cart_hive_model.dart';

abstract interface class ICartLocalDatasource {
  Future<CartHiveModel?> getCart();
  Future<void> cacheCart(CartHiveModel? cart);
  Future<void> clearCart();
}

abstract interface class ICartRemoteDatasource {
  Future<CartApiModel?> addToCart({
    required String productId,
    required int quantity,
  });
  Future<CartApiModel?> getCart();
  Future<CartApiModel?> updateQuantity({
    required String productId,
    required int quantity,
  });
  Future<CartApiModel?> removeFromCart(String productId);
  Future<void> clearCart();
}
