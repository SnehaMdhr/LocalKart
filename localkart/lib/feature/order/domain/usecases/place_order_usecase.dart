import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/order/data/repositories/order_repository.dart';
import 'package:localkart/feature/order/domain/entities/order_entity.dart';
import 'package:localkart/feature/order/domain/repositories/order_repository.dart';

class PlaceOrderParams extends Equatable {
  final String deliveryAddress;
  final String paymentMethod;

  const PlaceOrderParams({
    required this.deliveryAddress,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [deliveryAddress, paymentMethod];
}

final placeOrderUsecaseProvider = Provider<PlaceOrderUsecase>((ref) {
  final orderRepository = ref.read(orderRepositoryProvider);
  return PlaceOrderUsecase(orderRepository: orderRepository);
});

class PlaceOrderUsecase
    implements UseCaseWithParams<OrderEntity, PlaceOrderParams> {
  final IOrderRepository _orderRepository;

  PlaceOrderUsecase({required IOrderRepository orderRepository})
      : _orderRepository = orderRepository;

  @override
  Future<Either<Failure, OrderEntity>> call(PlaceOrderParams params) {
    return _orderRepository.placeOrder(
      deliveryAddress: params.deliveryAddress,
      paymentMethod: params.paymentMethod,
    );
  }
}
