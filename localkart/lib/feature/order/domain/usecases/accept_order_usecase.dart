import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/order/data/repositories/order_repository.dart';
import 'package:localkart/feature/order/domain/entities/order_entity.dart';
import 'package:localkart/feature/order/domain/repositories/order_repository.dart';

class AcceptOrderParams extends Equatable {
  final String orderId;
  final int? estimatedDeliveryTime;

  const AcceptOrderParams({
    required this.orderId,
    this.estimatedDeliveryTime,
  });

  @override
  List<Object?> get props => [orderId, estimatedDeliveryTime];
}

final acceptOrderUsecaseProvider = Provider<AcceptOrderUsecase>((ref) {
  final orderRepository = ref.read(orderRepositoryProvider);
  return AcceptOrderUsecase(orderRepository: orderRepository);
});

class AcceptOrderUsecase
    implements UseCaseWithParams<OrderEntity, AcceptOrderParams> {
  final IOrderRepository _orderRepository;

  AcceptOrderUsecase({required IOrderRepository orderRepository})
      : _orderRepository = orderRepository;

  @override
  Future<Either<Failure, OrderEntity>> call(AcceptOrderParams params) {
    return _orderRepository.acceptOrder(
      orderId: params.orderId,
      estimatedDeliveryTime: params.estimatedDeliveryTime,
    );
  }
}
