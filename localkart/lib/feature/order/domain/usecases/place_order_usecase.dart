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
  final double latitude;
  final double longitude;
  final String paymentMethod;
  final String? customerNote;

  const PlaceOrderParams({
    required this.deliveryAddress,
    required this.latitude,
    required this.longitude,
    required this.paymentMethod,
    this.customerNote,
  });

  @override
  List<Object?> get props => [
    deliveryAddress,
    latitude,
    longitude,
    paymentMethod,
    customerNote,
  ];
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
      latitude: params.latitude,
      longitude: params.longitude,
      paymentMethod: params.paymentMethod,
      customerNote: params.customerNote,
    );
  }
}
