import 'package:flutter_test/flutter_test.dart';
import 'package:localkart/feature/cart/data/models/cart_api_model.dart';
import 'package:localkart/feature/cart/domain/entities/cart_entity.dart';
import '../../helpers/test_data.dart';

void main() {
  group('CartItemApiModel', () {
    group('fromJson', () {
      test('should parse from simple ID string', () {
        final json = createTestCartItemJson();
        final model = CartItemApiModel.fromJson(json);
        expect(model.productId, 'prod-1');
        expect(model.quantity, 2);
      });

      test('should parse from populated product object', () {
        final json = {
          'productId': {
            '_id': 'prod-1',
            'productName': 'Apple',
            'price': 100,
          },
          'quantity': 3,
        };
        final model = CartItemApiModel.fromJson(json);
        expect(model.productId, 'prod-1');
        expect(model.productName, 'Apple');
        expect(model.price, 100);
        expect(model.quantity, 3);
      });
    });

    test('toJson should return correct map', () {
      final model = createTestCartItemApiModel();
      final json = model.toJson();
      expect(json['productId'], 'prod-1');
      expect(json['quantity'], 2);
    });

    test('toEntity should convert correctly', () {
      final model = createTestCartItemApiModel();
      final entity = model.toEntity();
      expect(entity.productId, 'prod-1');
      expect(entity.quantity, 2);
    });
  });

  group('CartApiModel', () {
    group('fromJson', () {
      test('should parse cart JSON correctly', () {
        final json = createTestCartJson();
        final model = CartApiModel.fromJson(json);
        expect(model.cartId, 'cart-1');
        expect(model.userId, 'user-1');
        expect(model.items.length, 1);
      });

      test('should handle populated userId', () {
        final json = createTestCartJson();
        json['userId'] = {'_id': 'user-1'};
        final model = CartApiModel.fromJson(json);
        expect(model.userId, 'user-1');
      });
    });

    test('toEntity should convert correctly', () {
      final json = createTestCartJson();
      final model = CartApiModel.fromJson(json);
      final entity = model.toEntity();
      expect(entity, isA<CartEntity>());
    });
  });
}
