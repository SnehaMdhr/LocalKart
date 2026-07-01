import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/order/data/repositories/order_repository.dart';
import 'package:localkart/feature/order/domain/entities/order_entity.dart';
import 'package:localkart/feature/order/domain/repositories/order_repository.dart';

class UpdateOrderStatusParams extends Equatable {
  final String orderId;
  final String status;

  const UpdateOrderStatusParams({
    required this.orderId,
    required this.status,
  });

  @override
  List<Object?> get props => [orderId, status];
}

final updateOrderStatusUsecaseProvider =
    Provider<UpdateOrderStatusUsecase>((ref) {
  final orderRepository = ref.read(orderRepositoryProvider);
  return UpdateOrderStatusUsecase(orderRepository: orderRepository);
});

class UpdateOrderStatusUsecase
    implements
        UseCaseWithParams<OrderEntity, UpdateOrderStatusParams> {
  final IOrderRepository _orderRepository;

  UpdateOrderStatusUsecase({required IOrderRepository orderRepository})
      : _orderRepository = orderRepository;

  @override
  Future<Either<Failure, OrderEntity>> call(UpdateOrderStatusParams params) {
    return _orderRepository.updateOrderStatus(
      orderId: params.orderId,
      status: params.status,
    );
  }
}
