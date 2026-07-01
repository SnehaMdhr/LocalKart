import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/order/data/repositories/order_repository.dart';
import 'package:localkart/feature/order/domain/entities/order_entity.dart';
import 'package:localkart/feature/order/domain/repositories/order_repository.dart';

class GetOrderByIdParams extends Equatable {
  final String orderId;

  const GetOrderByIdParams({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

final getOrderByIdUsecaseProvider = Provider<GetOrderByIdUsecase>((ref) {
  final orderRepository = ref.read(orderRepositoryProvider);
  return GetOrderByIdUsecase(orderRepository: orderRepository);
});

class GetOrderByIdUsecase
    implements UseCaseWithParams<OrderEntity, GetOrderByIdParams> {
  final IOrderRepository _orderRepository;

  GetOrderByIdUsecase({required IOrderRepository orderRepository})
      : _orderRepository = orderRepository;

  @override
  Future<Either<Failure, OrderEntity>> call(GetOrderByIdParams params) {
    return _orderRepository.getOrderById(params.orderId);
  }
}
