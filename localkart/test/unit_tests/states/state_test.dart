import 'package:flutter_test/flutter_test.dart';
import 'package:localkart/feature/auth/presentation/states/auth_state.dart';
import 'package:localkart/feature/product/presentation/states/product_state.dart';
import 'package:localkart/feature/cart/presentation/states/cart_state.dart';
import 'package:localkart/feature/order/presentation/states/order_state.dart';
import 'package:localkart/feature/address/presentation/states/address_state.dart';
import 'package:localkart/feature/collection/presentation/states/collection_state.dart';
import 'package:localkart/feature/notification/presentation/states/notification_state.dart';
import 'package:localkart/feature/rating/presentation/states/rating_state.dart';
import 'package:localkart/feature/vendor_registeration/presentation/states/shop_state.dart';
import '../../helpers/test_data.dart';

void main() {
  group('AuthState', () {
    test('should initialize with initial status', () {
      const state = AuthState();
      expect(state.status, AuthStatus.initial);
      expect(state.authEntity, isNull);
      expect(state.errorMessage, isNull);
    });

    test('copyWith should update fields', () {
      const state = AuthState();
      final updated = state.copyWith(status: AuthStatus.loading);
      expect(updated.status, AuthStatus.loading);
    });

    test('copyWith with authEntity should persist entity', () {
      const state = AuthState();
      final entity = createTestAuthEntity();
      final updated = state.copyWith(authEntity: entity);
      expect(updated.authEntity, entity);
    });

    test('should support value equality', () {
      const s1 = AuthState();
      const s2 = AuthState();
      expect(s1, equals(s2));
    });
  });

  group('ProductState', () {
    test('should initialize with empty list', () {
      const state = ProductState();
      expect(state.products, isEmpty);
      expect(state.status, ProductStatus.initial);
    });

    test('copyWith should update products', () {
      const state = ProductState();
      final products = [createTestProductEntity()];
      final updated = state.copyWith(products: products, status: ProductStatus.loaded);
      expect(updated.products.length, 1);
      expect(updated.status, ProductStatus.loaded);
    });

    test('should support value equality', () {
      const s1 = ProductState();
      const s2 = ProductState();
      expect(s1, equals(s2));
    });
  });

  group('CartState', () {
    test('should initialize with null cart', () {
      const state = CartState();
      expect(state.cart, isNull);
      expect(state.status, CartStatus.initial);
    });

    test('copyWith should update cart', () {
      const state = CartState();
      final cart = createTestCartEntity();
      final updated = state.copyWith(cart: cart, status: CartStatus.loaded);
      expect(updated.cart, cart);
    });
  });

  group('OrderState', () {
    test('should initialize with null orders', () {
      const state = OrderState();
      expect(state.orders, isNull);
      expect(state.pendingOrders, isNull);
      expect(state.status, OrderStatus.initial);
    });

    test('copyWith should update orders and status', () {
      const state = OrderState();
      final orders = [createTestOrderEntity()];
      final updated = state.copyWith(orders: orders, status: OrderStatus.loaded);
      expect(updated.orders?.length, 1);
      expect(updated.status, OrderStatus.loaded);
    });

    test('copyWith should support clearPendingOrders', () {
      final state = OrderState(pendingOrders: [createTestOrderEntity()]);
      final updated = state.copyWith(clearPendingOrders: true);
      expect(updated.pendingOrders, isNull);
    });
  });

  group('AddressState', () {
    test('should initialize with null addresses', () {
      const state = AddressState();
      expect(state.addresses, isNull);
      expect(state.status, AddressStatus.initial);
    });

    test('copyWith should update addresses', () {
      const state = AddressState();
      final addrs = [createTestAddressEntity()];
      final updated = state.copyWith(addresses: addrs, status: AddressStatus.loaded);
      expect(updated.addresses?.length, 1);
    });
  });

  group('CollectionState', () {
    test('should initialize with empty collections', () {
      const state = CollectionState();
      expect(state.collections, isEmpty);
      expect(state.isCreating, false);
    });

    test('copyWith should update collections', () {
      const state = CollectionState();
      final collections = [createTestCollectionEntity()];
      final updated = state.copyWith(collections: collections, status: CollectionStatus.loaded);
      expect(updated.collections.length, 1);
    });
  });

  group('NotificationState', () {
    test('should initialize with empty notifications', () {
      const state = NotificationState();
      expect(state.notifications, isEmpty);
      expect(state.unreadCount, 0);
      expect(state.hasMore, true);
    });

    test('copyWith should clear notifications flag', () {
      final state = NotificationState(notifications: [createTestNotificationEntity()]);
      final updated = state.copyWith(clearNotifications: true);
      expect(updated.notifications, isEmpty);
    });
  });

  group('RatingState', () {
    test('should initialize with initial status', () {
      const state = RatingState();
      expect(state.status, RatingStatus.initial);
    });

    test('VendorRatingStats should have default values', () {
      const stats = VendorRatingStats();
      expect(stats.averageRating, 0.0);
      expect(stats.totalRatings, 0);
      expect(stats.distribution[5], 0);
    });

    test('copyWith should update rating state', () {
      const state = RatingState();
      final updated = state.copyWith(status: RatingStatus.success, successMessage: 'Done');
      expect(updated.status, RatingStatus.success);
      expect(updated.successMessage, 'Done');
    });
  });

  group('ShopState', () {
    test('should initialize with initial status', () {
      const state = ShopState();
      expect(state.status, ShopStatus.initial);
      expect(state.shopEntity, isNull);
    });

    test('copyWith should update shop entity', () {
      const state = ShopState();
      final shop = createTestShopEntity();
      final updated = state.copyWith(shopEntity: shop, status: ShopStatus.loaded);
      expect(updated.shopEntity, shop);
    });
  });
}
