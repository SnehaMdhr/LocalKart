import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

enum OrderStatus { initial, loading, loaded, error }

class OrderState extends Equatable {
  final OrderStatus status;
  final List<OrderEntity>? orders;
  final OrderEntity? currentOrder;
  final String? errorMessage;

  const OrderState({
    this.status = OrderStatus.initial,
    this.orders,
    this.currentOrder,
    this.errorMessage,
  });

  OrderState copyWith({
    OrderStatus? status,
    List<OrderEntity>? orders,
    OrderEntity? currentOrder,
    String? errorMessage,
  }) {
    return OrderState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      currentOrder: currentOrder ?? this.currentOrder,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, orders, currentOrder, errorMessage];
}
