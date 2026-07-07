import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/api/api_client.dart';
import 'package:localkart/core/api/api_endpoints.dart';
import 'package:localkart/feature/order/data/datasource/order_datasource.dart';
import 'package:localkart/feature/order/data/models/order_api_model.dart';

final orderRemoteDatasourceProvider = Provider<IOrderRemoteDatasource>((ref) {
  return OrderRemoteDatasource(apiclient: ref.read(apiClientProvider));
});

class OrderRemoteDatasource implements IOrderRemoteDatasource {
  final ApiClient _apiClient;

  OrderRemoteDatasource({required ApiClient apiclient})
      : _apiClient = apiclient;

  @override
  Future<OrderApiModel?> placeOrder({
    required String deliveryAddress,
    required double latitude,
    required double longitude,
    required String paymentMethod,
    String? customerNote,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.createOrder,
        data: {
          'deliveryAddress': {
            'fullAddress': deliveryAddress,
            'latitude': latitude,
            'longitude': longitude,
          },
          'paymentMethod': paymentMethod,
          if (customerNote != null && customerNote.isNotEmpty)
            'customerNote': customerNote,
        },
      );

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) return null;

      return OrderApiModel.fromJsonWithData(responseData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<OrderApiModel>> getMyOrders() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getMyOrders);

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) return [];

      // Handle both { success: true, data: [...] } and direct list responses
      final data = responseData['data'];
      if (data is List) {
        return data
            .map((e) => OrderApiModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<OrderApiModel>> getShopOrders() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getShopOrders);

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) return [];

      final data = responseData['data'];
      if (data is List) {
        return data
            .map((e) => OrderApiModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<OrderApiModel>> getPendingOrders() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getPendingOrders);

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) return [];

      final data = responseData['data'];
      if (data is List) {
        return data
            .map((e) => OrderApiModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<OrderApiModel?> getOrderById(String orderId) async {
    try {
      final path = '${ApiEndpoints.getOrderById}$orderId';
      final response = await _apiClient.get(path);

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) return null;

      return OrderApiModel.fromJsonWithData(responseData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<OrderApiModel?> acceptOrder({
    required String orderId,
    int? estimatedDeliveryTime,
  }) async {
    try {
      final path = '${ApiEndpoints.acceptOrder}$orderId/accept';
      final response = await _apiClient.patch(
        path,
        data: {
          if (estimatedDeliveryTime != null)
            'estimatedDeliveryTime': estimatedDeliveryTime,
        },
      );

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) return null;

      return OrderApiModel.fromJsonWithData(responseData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<OrderApiModel?> rejectOrder(String orderId) async {
    try {
      final path = '${ApiEndpoints.rejectOrder}$orderId/reject';
      final response = await _apiClient.patch(path);

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) return null;

      return OrderApiModel.fromJsonWithData(responseData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<OrderApiModel?> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      final path = '${ApiEndpoints.updateOrderStatus}$orderId/status';
      final response = await _apiClient.patch(
        path,
        data: {
          'status': status,
        },
      );

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) return null;

      return OrderApiModel.fromJsonWithData(responseData);
    } catch (e) {
      rethrow;
    }
  }
}
