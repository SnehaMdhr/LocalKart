import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/feature/order/domain/usecases/place_order_usecase.dart';
import 'package:localkart/feature/order/domain/usecases/get_my_orders_usecase.dart';
import 'package:localkart/feature/order/domain/usecases/get_shop_orders_usecase.dart';
import 'package:localkart/feature/order/domain/usecases/get_pending_orders_usecase.dart';
import 'package:localkart/feature/order/domain/usecases/get_order_by_id_usecase.dart';
import 'package:localkart/feature/order/domain/usecases/accept_order_usecase.dart';
import 'package:localkart/feature/order/domain/usecases/reject_order_usecase.dart';
import 'package:localkart/feature/order/domain/usecases/update_order_status_usecase.dart';
import 'package:localkart/feature/order/domain/usecases/mark_order_paid_usecase.dart';
import 'package:localkart/feature/order/domain/entities/order_entity.dart';
import 'package:localkart/feature/order/presentation/states/order_state.dart';

final orderViewModelProvider =
    NotifierProvider<OrderViewModel, OrderState>(() => OrderViewModel());

class OrderViewModel extends Notifier<OrderState> {
  late final PlaceOrderUsecase _placeOrderUsecase;
  late final GetMyOrdersUsecase _getMyOrdersUsecase;
  late final GetShopOrdersUsecase _getShopOrdersUsecase;
  late final GetPendingOrdersUsecase _getPendingOrdersUsecase;
  late final GetOrderByIdUsecase _getOrderByIdUsecase;
  late final AcceptOrderUsecase _acceptOrderUsecase;
  late final RejectOrderUsecase _rejectOrderUsecase;
  late final UpdateOrderStatusUsecase _updateOrderStatusUsecase;
  late final MarkOrderPaidUsecase _markOrderPaidUsecase;

  @override
  OrderState build() {
    _placeOrderUsecase = ref.read(placeOrderUsecaseProvider);
    _getMyOrdersUsecase = ref.read(getMyOrdersUsecaseProvider);
    _getShopOrdersUsecase = ref.read(getShopOrdersUsecaseProvider);
    _getPendingOrdersUsecase = ref.read(getPendingOrdersUsecaseProvider);
    _getOrderByIdUsecase = ref.read(getOrderByIdUsecaseProvider);
    _acceptOrderUsecase = ref.read(acceptOrderUsecaseProvider);
    _rejectOrderUsecase = ref.read(rejectOrderUsecaseProvider);
    _updateOrderStatusUsecase = ref.read(updateOrderStatusUsecaseProvider);
    _markOrderPaidUsecase = ref.read(markOrderPaidUsecaseProvider);

    return const OrderState();
  }

  Future<OrderEntity?> placeOrder({
    required String deliveryAddress,
    required double latitude,
    required double longitude,
    required String paymentMethod,
    String? customerNote,
  }) async {
    state = state.copyWith(status: OrderStatus.loading);
    final params = PlaceOrderParams(
      deliveryAddress: deliveryAddress,
      latitude: latitude,
      longitude: longitude,
      paymentMethod: paymentMethod,
      customerNote: customerNote,
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

  Future<void> loadAllShopData() async {
    state = state.copyWith(status: OrderStatus.loading);

    // Fetch both pending and active orders in parallel
    final pendingResult = await _getPendingOrdersUsecase();
    final ordersResult = await _getShopOrdersUsecase();

    List<OrderEntity>? pending;
    List<OrderEntity>? orders;
    String? error;

    pendingResult.fold(
      (failure) => error = failure.message,
      (data) => pending = data,
    );

    ordersResult.fold(
      (failure) => error = failure.message,
      (data) => orders = data,
    );

    state = state.copyWith(
      status: OrderStatus.loaded,
      pendingOrders: pending,
      orders: orders,
      errorMessage: error,
    );
  }

  Future<void> getPendingOrders() async {
    state = state.copyWith(status: OrderStatus.loading);
    final result = await _getPendingOrdersUsecase();

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
          pendingOrders: orders,
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

  Future<void> acceptOrder(String orderId, {int? estimatedDeliveryTime}) async {
    state = state.copyWith(status: OrderStatus.loading);
    final params = AcceptOrderParams(
      orderId: orderId,
      estimatedDeliveryTime: estimatedDeliveryTime,
    );
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

  Future<void> markOrderPaid(String orderId) async {
    state = state.copyWith(status: OrderStatus.loading);
    final params = MarkOrderPaidParams(orderId: orderId);
    final result = await _markOrderPaidUsecase(params);

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
