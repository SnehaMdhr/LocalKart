import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/feature/order/domain/usecases/place_order_usecase.dart';
import 'package:localkart/feature/order/domain/usecases/get_my_orders_usecase.dart';
import 'package:localkart/feature/order/domain/usecases/get_shop_orders_usecase.dart';
import 'package:localkart/feature/order/domain/usecases/get_order_by_id_usecase.dart';
import 'package:localkart/feature/order/domain/usecases/accept_order_usecase.dart';
import 'package:localkart/feature/order/domain/usecases/reject_order_usecase.dart';
import 'package:localkart/feature/order/domain/usecases/update_order_status_usecase.dart';
import 'package:localkart/feature/order/domain/entities/order_entity.dart';
import 'package:localkart/feature/order/presentation/states/order_state.dart';

final orderViewModelProvider =
    NotifierProvider<OrderViewModel, OrderState>(() => OrderViewModel());

class OrderViewModel extends Notifier<OrderState> {
  late final PlaceOrderUsecase _placeOrderUsecase;
  late final GetMyOrdersUsecase _getMyOrdersUsecase;
  late final GetShopOrdersUsecase _getShopOrdersUsecase;
  late final GetOrderByIdUsecase _getOrderByIdUsecase;
  late final AcceptOrderUsecase _acceptOrderUsecase;
  late final RejectOrderUsecase _rejectOrderUsecase;
  late final UpdateOrderStatusUsecase _updateOrderStatusUsecase;

  @override
  OrderState build() {
    _placeOrderUsecase = ref.read(placeOrderUsecaseProvider);
    _getMyOrdersUsecase = ref.read(getMyOrdersUsecaseProvider);
    _getShopOrdersUsecase = ref.read(getShopOrdersUsecaseProvider);
    _getOrderByIdUsecase = ref.read(getOrderByIdUsecaseProvider);
    _acceptOrderUsecase = ref.read(acceptOrderUsecaseProvider);
    _rejectOrderUsecase = ref.read(rejectOrderUsecaseProvider);
    _updateOrderStatusUsecase = ref.read(updateOrderStatusUsecaseProvider);

    return const OrderState();
  }

  Future<OrderEntity?> placeOrder({
    required String deliveryAddress,
    required String paymentMethod,
  }) async {
    state = state.copyWith(status: OrderStatus.loading);
    final params = PlaceOrderParams(
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
    );
    final result = await _placeOrderUsecase(params);

    OrderEntity? createdOrder;
    result.fold(
      (failure) {
        state = state.copyWith(
          status: OrderStatus.error,
          errorMessage: failure.message,
        );
      },
      (order) {
        createdOrder = order;
        final updatedOrders = <OrderEntity>[...(state.orders ?? []), order];
        state = state.copyWith(
          status: OrderStatus.loaded,
          orders: updatedOrders,
          currentOrder: order,
          errorMessage: null,
        );
      },
    );
    return createdOrder;
  }

  Future<void> getMyOrders() async {
    state = state.copyWith(status: OrderStatus.loading);
    final result = await _getMyOrdersUsecase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: OrderStatus.error,
          errorMessage: failure.message,
        );
      },
      (orders) {
        state = state.copyWith(
          status: OrderStatus.loaded,
          orders: orders,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> getShopOrders() async {
    state = state.copyWith(status: OrderStatus.loading);
    final result = await _getShopOrdersUsecase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: OrderStatus.error,
          errorMessage: failure.message,
        );
      },
      (orders) {
        state = state.copyWith(
          status: OrderStatus.loaded,
          orders: orders,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> getOrderById(String orderId) async {
    state = state.copyWith(status: OrderStatus.loading);
    final params = GetOrderByIdParams(orderId: orderId);
    final result = await _getOrderByIdUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: OrderStatus.error,
          errorMessage: failure.message,
        );
      },
      (order) {
        state = state.copyWith(
          status: OrderStatus.loaded,
          currentOrder: order,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> acceptOrder(String orderId) async {
    state = state.copyWith(status: OrderStatus.loading);
    final params = AcceptOrderParams(orderId: orderId);
    final result = await _acceptOrderUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: OrderStatus.error,
          errorMessage: failure.message,
        );
      },
      (order) {
        _updateOrderInList(order);
        state = state.copyWith(
          status: OrderStatus.loaded,
          currentOrder: order,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> rejectOrder(String orderId) async {
    state = state.copyWith(status: OrderStatus.loading);
    final params = RejectOrderParams(orderId: orderId);
    final result = await _rejectOrderUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: OrderStatus.error,
          errorMessage: failure.message,
        );
      },
      (order) {
        _updateOrderInList(order);
        state = state.copyWith(
          status: OrderStatus.loaded,
          currentOrder: order,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    state = state.copyWith(status: OrderStatus.loading);
    final params = UpdateOrderStatusParams(
      orderId: orderId,
      status: status,
    );
    final result = await _updateOrderStatusUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: OrderStatus.error,
          errorMessage: failure.message,
        );
      },
      (order) {
        _updateOrderInList(order);
        state = state.copyWith(
          status: OrderStatus.loaded,
          currentOrder: order,
          errorMessage: null,
        );
      },
    );
  }

  void _updateOrderInList(OrderEntity updatedOrder) {
    final currentOrders = state.orders;
    if (currentOrders == null) return;

    final updatedOrders = currentOrders.map((order) {
      if (order.orderId == updatedOrder.orderId) {
        return updatedOrder;
      }
      return order;
    }).toList();

    state = state.copyWith(orders: updatedOrders);
  }
}
