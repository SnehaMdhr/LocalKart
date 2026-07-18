import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/feature/order/data/models/order_api_model.dart';
import 'package:localkart/feature/order/domain/usecases/place_order_usecase.dart';
import 'package:localkart/feature/order/domain/usecases/get_my_orders_usecase.dart';
import 'package:localkart/feature/order/domain/usecases/get_shop_orders_usecase.dart';
import 'package:localkart/feature/order/domain/usecases/get_pending_orders_usecase.dart';
import 'package:localkart/feature/order/domain/usecases/get_order_by_id_usecase.dart';
import 'package:localkart/feature/order/domain/usecases/accept_order_usecase.dart';
import 'package:localkart/feature/order/domain/usecases/reject_order_usecase.dart';
import 'package:localkart/feature/order/domain/usecases/update_order_status_usecase.dart';
import 'package:localkart/feature/order/domain/usecases/mark_order_paid_usecase.dart';
import 'package:localkart/feature/order/domain/usecases/get_order_etd_usecase.dart';
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
  late final GetOrderEtdUsecase _getOrderEtdUsecase;

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
    _getOrderEtdUsecase = ref.read(getOrderEtdUsecaseProvider);

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

  Future<void> getOrderEtd(String orderId) async {
    final params = GetOrderEtdParams(orderId: orderId);
    final result = await _getOrderEtdUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          etdInfo: null,
          errorMessage: failure.message,
        );
      },
      (etd) {
        state = state.copyWith(
          etdInfo: etd,
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

  // ─────────────────────────────────────────────────────
  // Real-Time Socket Event Handlers
  // ─────────────────────────────────────────────────────

  /// Insert a new incoming order at the beginning of the pending orders list.
  /// Prevents duplicates by checking orderId first.
  void insertIncomingOrder(Map<String, dynamic> orderData) {
    try {
      final orderEntity = OrderApiModel.fromJson(orderData).toEntity();

      // Prevent duplicates
      final currentPending = state.pendingOrders ?? [];
      final alreadyExists = currentPending.any(
        (o) => o.orderId == orderEntity.orderId,
      );
      if (alreadyExists) return;

      final updatedPending = [orderEntity, ...currentPending];

      state = state.copyWith(
        status: OrderStatus.loaded,
        pendingOrders: updatedPending,
        errorMessage: null,
      );
    } catch (e) {
      print('[OrderVM] Failed to insert incoming order: $e');
    }
  }

  /// Remove an order from the pending list when it's accepted by a vendor.
  void removeAcceptedOrder(Map<String, dynamic> eventData) {
    final orderId = eventData['orderId'] as String?;
    final acceptedBy = eventData['acceptedBy'] as String?;
    if (orderId == null) return;

    final currentPending = state.pendingOrders ?? [];
    final updatedPending = currentPending
        .where((o) => o.orderId != orderId)
        .toList();

    // If the list changed, also update the order in the assigned orders
    if (updatedPending.length < currentPending.length) {
      state = state.copyWith(
        pendingOrders: updatedPending,
        status: OrderStatus.loaded,
      );

      // Also move the accepted order from pending to active by refreshing
      // Only if we haven't loaded it yet, reload
      final currentOrders = state.orders ?? [];
      final alreadyInOrders = currentOrders.any((o) => o.orderId == orderId);
      if (!alreadyInOrders) {
        _getPendingOrdersUsecase().then((result) {
          result.fold(
            (failure) {},
            (orders) {
              state = state.copyWith(pendingOrders: orders);
            },
          );
        });
      }
    }
  }

  /// Handle order_updated event — update the order in both pending and assigned lists.
  void updateOrderFromSocket(Map<String, dynamic> orderData) {
    try {
      final orderEntity = OrderApiModel.fromJson(orderData).toEntity();

      // Update in assigned orders
      final currentOrders = state.orders ?? [];
      final updatedOrders = currentOrders.map((o) {
        if (o.orderId == orderEntity.orderId) return orderEntity;
        return o;
      }).toList();

      // Remove from pending if it's no longer pending
      final currentPending = state.pendingOrders ?? [];
      final updatedPending = currentPending
          .where((o) => o.orderId != orderEntity.orderId)
          .toList();

      state = state.copyWith(
        status: OrderStatus.loaded,
        orders: updatedOrders,
        pendingOrders: updatedPending,
        currentOrder: orderEntity,
        errorMessage: null,
      );
    } catch (e) {
      print('[OrderVM] Failed to update order from socket: $e');
    }
  }

  /// Handle order_rejected event — remove the rejected order from the pending list only.
  /// Unlike removeCancelledOrder, the order may still be available to other vendors.
  void removeOrderFromPending(Map<String, dynamic> eventData) {
    final orderId = eventData['orderId'] as String?;
    final rejectedBy = eventData['rejectedBy'] as String?;
    if (orderId == null) return;

    final currentPending = state.pendingOrders ?? [];
    final updatedPending = currentPending
        .where((o) => o.orderId != orderId)
        .toList();

    state = state.copyWith(
      pendingOrders: updatedPending,
      status: OrderStatus.loaded,
    );
  }

  /// Handle order_cancelled event — remove from both lists.
  void removeCancelledOrder(Map<String, dynamic> eventData) {
    final orderId = eventData['orderId'] as String?;
    if (orderId == null) return;

    final currentPending = state.pendingOrders ?? [];
    final currentOrders = state.orders ?? [];

    final updatedPending = currentPending
        .where((o) => o.orderId != orderId)
        .toList();
    final updatedOrders = currentOrders
        .where((o) => o.orderId != orderId)
        .toList();

    state = state.copyWith(
      pendingOrders: updatedPending,
      orders: updatedOrders,
      status: OrderStatus.loaded,
    );
  }
}
