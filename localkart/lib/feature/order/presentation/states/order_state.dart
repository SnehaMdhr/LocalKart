import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

enum OrderStatus { initial, loading, loaded, error }

class OrderState extends Equatable {
  final OrderStatus status;
  final List<OrderEntity>? orders;
  final List<OrderEntity>? pendingOrders;
  final OrderEntity? currentOrder;
  final String? errorMessage;

  const OrderState({
    this.status = OrderStatus.initial,
    this.orders,
    this.pendingOrders,
    this.currentOrder,
    this.errorMessage,
  });

  OrderState copyWith({
    OrderStatus? status,
    List<OrderEntity>? orders,
    List<OrderEntity>? pendingOrders,
    OrderEntity? currentOrder,
    String? errorMessage,
    bool clearPendingOrders = false,
  }) {
    return OrderState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      pendingOrders: clearPendingOrders ? null : (pendingOrders ?? this.pendingOrders),
      currentOrder: currentOrder ?? this.currentOrder,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, orders, pendingOrders, currentOrder, errorMessage];
}
