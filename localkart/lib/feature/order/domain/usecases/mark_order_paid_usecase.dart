import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/order/data/repositories/order_repository.dart';
import 'package:localkart/feature/order/domain/entities/order_entity.dart';
import 'package:localkart/feature/order/domain/repositories/order_repository.dart';

class MarkOrderPaidParams extends Equatable {
  final String orderId;

  const MarkOrderPaidParams({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

final markOrderPaidUsecaseProvider = Provider<MarkOrderPaidUsecase>((ref) {
  final orderRepository = ref.read(orderRepositoryProvider);
  return MarkOrderPaidUsecase(orderRepository: orderRepository);
});

class MarkOrderPaidUsecase
    implements UseCaseWithParams<OrderEntity, MarkOrderPaidParams> {
  final IOrderRepository _orderRepository;

  MarkOrderPaidUsecase({required IOrderRepository orderRepository})
      : _orderRepository = orderRepository;

  @override
  Future<Either<Failure, OrderEntity>> call(MarkOrderPaidParams params) {
    return _orderRepository.markOrderPaid(params.orderId);
  }
}
