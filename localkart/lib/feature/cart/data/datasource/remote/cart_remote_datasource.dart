import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/api/api_client.dart';
import 'package:localkart/core/api/api_endpoints.dart';
import 'package:localkart/feature/cart/data/datasource/cart_datasource.dart';
import 'package:localkart/feature/cart/data/models/cart_api_model.dart';

final cartRemoteDatasourceProvider = Provider<ICartRemoteDatasource>((ref) {
  return CartRemoteDatasource(apiclient: ref.read(apiClientProvider));
});

class CartRemoteDatasource implements ICartRemoteDatasource {
  final ApiClient _apiClient;

  CartRemoteDatasource({required ApiClient apiclient})
      : _apiClient = apiclient;

  @override
  Future<CartApiModel?> addToCart({
    required String productId,
    required int quantity,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.addToCart,
        data: {
          'productId': productId,
          'quantity': quantity,
        },
      );

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) return null;

      return CartApiModel.fromJsonWithData(responseData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CartApiModel?> getCart() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getCart);

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) return null;

      return CartApiModel.fromJsonWithData(responseData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CartApiModel?> updateQuantity({
    required String productId,
    required int quantity,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.updateCartQuantity,
        data: {
          'productId': productId,
          'quantity': quantity,
        },
      );

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) return null;

      return CartApiModel.fromJsonWithData(responseData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CartApiModel?> removeFromCart(String productId) async {
    try {
      final path = '${ApiEndpoints.removeFromCart}$productId';
      final response = await _apiClient.delete(path);

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) return null;

      return CartApiModel.fromJsonWithData(responseData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await _apiClient.delete(ApiEndpoints.clearCart);
    } catch (e) {
      rethrow;
    }
  }
}
