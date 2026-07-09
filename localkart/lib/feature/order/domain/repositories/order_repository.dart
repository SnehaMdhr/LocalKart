import 'package:dartz/dartz.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/feature/order/domain/entities/order_entity.dart';

abstract interface class IOrderRepository {
  Future<Either<Failure, OrderEntity>> placeOrder({
    required String deliveryAddress,
    required double latitude,
    required double longitude,
    required String paymentMethod,
    String? customerNote,
  });
  Future<Either<Failure, List<OrderEntity>>> getMyOrders();
  Future<Either<Failure, List<OrderEntity>>> getShopOrders();
  Future<Either<Failure, List<OrderEntity>>> getPendingOrders();
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId);
  Future<Either<Failure, OrderEntity>> acceptOrder({
    required String orderId,
    int? estimatedDeliveryTime,
  });
  Future<Either<Failure, OrderEntity>> rejectOrder(String orderId);
  Future<Either<Failure, OrderEntity>> updateOrderStatus({
    required String orderId,
    required String status,
  });
  Future<Either<Failure, OrderEntity>> markOrderPaid(String orderId);
  Future<Either<Failure, Map<String, dynamic>>> getOrderEtd(String orderId);
}
