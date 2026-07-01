import 'package:localkart/feature/order/data/models/order_api_model.dart';
import 'package:localkart/feature/order/data/models/order_hive_model.dart';

abstract interface class IOrderLocalDatasource {
  Future<List<OrderHiveModel>> getOrders();
  Future<void> cacheOrders(List<OrderHiveModel> orders);
  Future<void> clearOrders();
}

abstract interface class IOrderRemoteDatasource {
  Future<OrderApiModel?> placeOrder({
    required String deliveryAddress,
    required String paymentMethod,
  });
  Future<List<OrderApiModel>> getMyOrders();
  Future<List<OrderApiModel>> getShopOrders();
  Future<OrderApiModel?> getOrderById(String orderId);
  Future<OrderApiModel?> acceptOrder(String orderId);
  Future<OrderApiModel?> rejectOrder(String orderId);
  Future<OrderApiModel?> updateOrderStatus({
    required String orderId,
    required String status,
  });
}
