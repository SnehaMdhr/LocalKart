import 'package:flutter_test/flutter_test.dart';
import 'package:localkart/feature/auth/domain/entities/auth_entity.dart';
import 'package:localkart/feature/product/domain/entities/product_entity.dart';
import 'package:localkart/feature/cart/domain/entities/cart_entity.dart';
import 'package:localkart/feature/order/domain/entities/order_entity.dart';
import 'package:localkart/feature/address/domain/entities/address_entity.dart';
import 'package:localkart/feature/collection/domain/entities/collection_entity.dart';
import 'package:localkart/feature/notification/domain/entities/notification_entity.dart';
import 'package:localkart/feature/rating/domain/entities/rating_entity.dart';
import 'package:localkart/feature/vendor_registeration/domain/entities/shop_entity.dart';
import '../../helpers/test_data.dart';

void main() {
  group('AuthEntity', () {
    test('should create instance with required fields', () {
      final entity = createTestAuthEntity();
      expect(entity.name, 'John Doe');
      expect(entity.email, 'john@test.com');
      expect(entity.phone, '9876543210');
    });

    test('should support value equality', () {
      final a1 = createTestAuthEntity();
      final a2 = createTestAuthEntity();
      expect(a1, equals(a2));
    });

    test('props should contain all fields', () {
      final entity = createTestAuthEntity();
      expect(entity.props, containsAll(['John Doe', 'john@test.com']));
    });

    test('two instances with different emails should not be equal', () {
      final a1 = AuthEntity(name: 'A', email: 'a@test.com');
      final a2 = AuthEntity(name: 'A', email: 'b@test.com');
      expect(a1, isNot(equals(a2)));
    });
  });

  group('ProductEntity', () {
    test('should create with default fields', () {
      final entity = createTestProductEntity();
      expect(entity.productName, 'Apple');
      expect(entity.price, 100);
      expect(entity.unit, 'kg');
    });

    test('should support value equality', () {
      final p1 = createTestProductEntity();
      final p2 = createTestProductEntity();
      expect(p1, equals(p2));
    });

    test('props should contain all fields', () {
      final entity = createTestProductEntity();
      expect(entity.props, containsAll(['Apple', 'Fruits', 'kg']));
    });
  });

  group('CartItemEntity', () {
    test('should create with default quantity of 1', () {
      final item = CartItemEntity(productId: 'p1');
      expect(item.quantity, 1);
    });

    test('copyWith should update fields', () {
      final item = createTestCartItemEntity(quantity: 2);
      final updated = item.copyWith(quantity: 5);
      expect(updated.quantity, 5);
      expect(updated.productId, item.productId);
    });

    test('should support value equality', () {
      final i1 = createTestCartItemEntity();
      final i2 = createTestCartItemEntity();
      expect(i1, equals(i2));
    });
  });

  group('CartEntity', () {
    test('should create with empty items by default', () {
      final cart = CartEntity(userId: 'u1');
      expect(cart.items, isEmpty);
    });

    test('copyWith should replace items', () {
      final cart = createTestCartEntity();
      final updated = cart.copyWith(items: []);
      expect(updated.items, isEmpty);
    });
  });

  group('OrderItemEntity', () {
    test('should support copyWith', () {
      final item = createTestOrderItemEntity(quantity: 2);
      final updated = item.copyWith(quantity: 3, price: 150);
      expect(updated.quantity, 3);
      expect(updated.price, 150);
    });
  });

  group('OrderEntity', () {
    test('should create with defaults', () {
      final order = OrderEntity();
      expect(order.totalAmount, 0);
      expect(order.items, isEmpty);
      expect(order.status, 'Pending');
      expect(order.paymentMethod, 'Cash on Delivery');
    });

    test('copyWith should update order fields', () {
      final order = createTestOrderEntity();
      final updated = order.copyWith(status: 'Accepted');
      expect(updated.status, 'Accepted');
      expect(updated.orderId, order.orderId);
    });

    test('should support value equality', () {
      final o1 = createTestOrderEntity();
      final o2 = createTestOrderEntity();
      expect(o1, equals(o2));
    });

    test('props should contain order fields', () {
      final order = createTestOrderEntity();
      expect(order.props, containsAll(['ORD-001', 'Pending']));
    });
  });

  group('AddressEntity', () {
    test('should create with default label Home', () {
      final addr = AddressEntity(
        fullAddress: 'Test',
        latitude: 0,
        longitude: 0,
      );
      expect(addr.label, 'Home');
    });

    test('copyWith should update address fields', () {
      final addr = createTestAddressEntity();
      final updated = addr.copyWith(label: 'Work', fullAddress: 'Office');
      expect(updated.label, 'Work');
      expect(updated.fullAddress, 'Office');
    });
  });

  group('CollectionEntity', () {
    test('should create with empty productIds by default', () {
      final coll = CollectionEntity(collectionName: 'Test');
      expect(coll.productIds, isEmpty);
    });

    test('copyWith should update collection fields', () {
      final coll = createTestCollectionEntity();
      final updated = coll.copyWith(collectionName: 'New Name');
      expect(updated.collectionName, 'New Name');
    });
  });

  group('NotificationEntity', () {
    test('should default isRead to false', () {
      final notif = NotificationEntity(
        receiverId: 'r1',
        receiverRole: 'Customer',
        title: 'Test',
        message: 'Test msg',
        type: 'ORDER',
      );
      expect(notif.isRead, false);
    });

    test('copyWith should toggle isRead', () {
      final notif = createTestNotificationEntity();
      final read = notif.copyWith(isRead: true);
      expect(read.isRead, true);
    });
  });

  group('RatingEntity', () {
    test('should create with default rating of 0 and empty comment', () {
      final rating = RatingEntity();
      expect(rating.rating, 0);
      expect(rating.comment, '');
    });

    test('copyWith should update rating fields', () {
      final rating = createTestRatingEntity();
      final updated = rating.copyWith(rating: 3, comment: 'Okay');
      expect(updated.rating, 3);
      expect(updated.comment, 'Okay');
    });
  });

  group('ShopEntity', () {
    test('should create with required fields', () {
      final shop = createTestShopEntity();
      expect(shop.shopName, 'My Store');
      expect(shop.categories, contains('Vegetables'));
    });

    test('should support value equality', () {
      final s1 = createTestShopEntity();
      final s2 = createTestShopEntity();
      expect(s1, equals(s2));
    });
  });
}
