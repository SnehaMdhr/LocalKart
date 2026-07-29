import 'package:flutter_test/flutter_test.dart';
import 'package:localkart/feature/order/data/models/order_api_model.dart';
import 'package:localkart/feature/order/domain/entities/order_entity.dart';
import '../../helpers/test_data.dart';

void main() {
  group('OrderItemApiModel', () {
    test('fromJson with populated product object', () {
      final json = {
        'productId': {
          '_id': 'prod-1',
          'productName': 'Apple',
          'price': 100,
          'imageUrl': 'img.jpg',
        },
        'quantity': 2,
      };
      final model = OrderItemApiModel.fromJson(json);
      expect(model.productId, 'prod-1');
      expect(model.productName, 'Apple');
      expect(model.price, 100);
      expect(model.quantity, 2);
    });

    test('fromJson with simple string productId', () {
      final json = {'productId': 'prod-1', 'quantity': 2};
      final model = OrderItemApiModel.fromJson(json);
      expect(model.productId, 'prod-1');
      expect(model.quantity, 2);
    });

    test('toEntity converts correctly', () {
      final model = OrderItemApiModel(productId: 'p1', quantity: 3);
      final entity = model.toEntity();
      expect(entity.productId, 'p1');
      expect(entity.quantity, 3);
    });

    test('toJson returns correct map', () {
      final model = OrderItemApiModel(productId: 'p1', quantity: 3);
      final json = model.toJson();
      expect(json['productId'], 'p1');
      expect(json['quantity'], 3);
    });
  });

  group('OrderApiModel', () {
    group('fromJson', () {
      test('should parse order JSON correctly', () {
        final json = createTestOrderJson();
        final model = OrderApiModel.fromJson(json);
        expect(model.orderId, 'order-1');
        expect(model.totalAmount, 200);
        expect(model.status, 'Pending');
        expect(model.items.length, 1);
      });

      test('should handle populated customerId', () {
        final json = createTestOrderJson();
        json['customerId'] = {
          '_id': 'user-1',
          'name': 'John Doe',
          'address': 'KTM',
          'phone': '9876543210',
        };
        final model = OrderApiModel.fromJson(json);
        expect(model.customerName, 'John Doe');
        expect(model.customerAddress, 'KTM');
        expect(model.customerPhone, '9876543210');
      });

      test('should handle populated shopId', () {
        final json = createTestOrderJson();
        json['shopId'] = {'_id': 'shop-1', 'name': 'My Store', 'phone': '1234567890'};
        final model = OrderApiModel.fromJson(json);
        expect(model.vendorName, 'My Store');
        expect(model.shopPhone, '1234567890');
      });

      test('should handle delivery address as map', () {
        final json = createTestOrderJson();
        json['deliveryAddress'] = {
          'fullAddress': 'KTM, Nepal',
          'latitude': 27.7172,
          'longitude': 85.3240,
        };
        final model = OrderApiModel.fromJson(json);
        expect(model.deliveryAddress, 'KTM, Nepal');
        expect(model.latitude, 27.7172);
        expect(model.longitude, 85.3240);
      });

      test('should handle missing fields with defaults', () {
        final json = <String, dynamic>{};
        final model = OrderApiModel.fromJson(json);
        expect(model.totalAmount, 0);
        expect(model.status, 'Pending');
        expect(model.items, isEmpty);
        expect(model.deliveryAddress, '');
      });
    });

    group('toEntity', () {
      test('should convert to entity correctly', () {
        final model = createTestOrderApiModel();
        final entity = model.toEntity();
        expect(entity, isA<OrderEntity>());
        expect(entity.orderId, model.orderId);
        expect(entity.totalAmount, model.totalAmount);
      });
    });

    group('fromJsonWithData', () {
      test('should unwrap data wrapper', () {
        final json = {'success': true, 'data': createTestOrderJson()};
        final model = OrderApiModel.fromJsonWithData(json);
        expect(model.orderId, 'order-1');
      });

      test('should handle plain JSON without wrapper', () {
        final json = createTestOrderJson();
        final model = OrderApiModel.fromJsonWithData(json);
        expect(model.orderId, 'order-1');
      });
    });

    test('toEntityList converts list correctly', () {
      final models = [createTestOrderApiModel()];
      final entities = OrderApiModel.toEntityList(models);
      expect(entities.length, 1);
    });
  });
}
