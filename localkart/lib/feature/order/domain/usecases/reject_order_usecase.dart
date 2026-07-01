import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/order/data/repositories/order_repository.dart';
import 'package:localkart/feature/order/domain/entities/order_entity.dart';
import 'package:localkart/feature/order/domain/repositories/order_repository.dart';

class RejectOrderParams extends Equatable {
  final String orderId;

  const RejectOrderParams({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

final rejectOrderUsecaseProvider = Provider<RejectOrderUsecase>((ref) {
  final orderRepository = ref.read(orderRepositoryProvider);
  return RejectOrderUsecase(orderRepository: orderRepository);
});

class RejectOrderUsecase
    implements UseCaseWithParams<OrderEntity, RejectOrderParams> {
  final IOrderRepository _orderRepository;

  RejectOrderUsecase({required IOrderRepository orderRepository})
      : _orderRepository = orderRepository;

  @override
  Future<Either<Failure, OrderEntity>> call(RejectOrderParams params) {
    return _orderRepository.rejectOrder(params.orderId);
  }
}
