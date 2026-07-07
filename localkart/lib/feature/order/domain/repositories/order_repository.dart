import 'package:dartz/dartz.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/feature/order/domain/entities/order_entity.dart';

abstract interface class IOrderRepository {
  Future<Either<Failure, OrderEntity>> placeOrder({
    required String deliveryAddress,
    required String paymentMethod,
  });
  Future<Either<Failure, List<OrderEntity>>> getMyOrders();
  Future<Either<Failure, List<OrderEntity>>> getShopOrders();
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId);
  Future<Either<Failure, OrderEntity>> acceptOrder(String orderId);
  Future<Either<Failure, OrderEntity>> rejectOrder(String orderId);
  Future<Either<Failure, OrderEntity>> updateOrderStatus({
    required String orderId,
    required String status,
  });
}
