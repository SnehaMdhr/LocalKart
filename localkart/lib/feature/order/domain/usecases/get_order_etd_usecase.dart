import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/order/data/repositories/order_repository.dart';
import 'package:localkart/feature/order/domain/repositories/order_repository.dart';

class GetOrderEtdParams extends Equatable {
  final String orderId;

  const GetOrderEtdParams({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

final getOrderEtdUsecaseProvider = Provider<GetOrderEtdUsecase>((ref) {
  final orderRepository = ref.read(orderRepositoryProvider);
  return GetOrderEtdUsecase(orderRepository: orderRepository);
});

class GetOrderEtdUsecase
    implements UseCaseWithParams<Map<String, dynamic>, GetOrderEtdParams> {
  final IOrderRepository _orderRepository;

  GetOrderEtdUsecase({required IOrderRepository orderRepository})
      : _orderRepository = orderRepository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      GetOrderEtdParams params) {
    return _orderRepository.getOrderEtd(params.orderId);
  }
}
