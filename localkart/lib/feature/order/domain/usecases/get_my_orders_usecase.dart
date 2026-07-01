import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/order/data/repositories/order_repository.dart';
import 'package:localkart/feature/order/domain/entities/order_entity.dart';
import 'package:localkart/feature/order/domain/repositories/order_repository.dart';

final getMyOrdersUsecaseProvider = Provider<GetMyOrdersUsecase>((ref) {
  final orderRepository = ref.read(orderRepositoryProvider);
  return GetMyOrdersUsecase(orderRepository: orderRepository);
});

class GetMyOrdersUsecase implements UsecaseWithoutParams<List<OrderEntity>> {
  final IOrderRepository _orderRepository;

  GetMyOrdersUsecase({required IOrderRepository orderRepository})
      : _orderRepository = orderRepository;

  @override
  Future<Either<Failure, List<OrderEntity>>> call() {
    return _orderRepository.getMyOrders();
  }
}
