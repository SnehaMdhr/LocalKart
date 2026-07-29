import 'package:flutter_test/flutter_test.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/api/api_endpoints.dart';

void main() {
  group('Failure', () {
    test('ApiFailure should store statusCode and message', () {
      final failure = ApiFailure(statusCode: 404, message: 'Not found');
      expect(failure.message, 'Not found');
      expect(failure.statusCode, 404);
    });

    test('ApiFailure should have default null statusCode', () {
      final failure = ApiFailure(message: 'Error');
      expect(failure.statusCode, isNull);
    });

    test('LocalDatabaseFailure should have default message', () {
      const failure = LocalDatabaseFailure();
      expect(failure.message, 'Local database operation failed');
    });

    test('LocalDatabaseFailure should accept custom message', () {
      const failure = LocalDatabaseFailure(message: 'Hive error');
      expect(failure.message, 'Hive error');
    });

    test('NetworkFailure should have default message', () {
      const failure = NetworkFailure();
      expect(failure.message, 'No internet connection');
    });

    test('ApiFailure props should include statusCode', () {
      final f1 = ApiFailure(statusCode: 404, message: 'Not found');
      final f2 = ApiFailure(statusCode: 404, message: 'Not found');
      expect(f1.props, containsAll([404, 'Not found']));
      expect(f1, equals(f2));
    });

    test('different failures should not be equal', () {
      final f1 = ApiFailure(statusCode: 404, message: 'Not found');
      final f2 = ApiFailure(statusCode: 500, message: 'Server error');
      expect(f1, isNot(equals(f2)));
    });
  });

  group('ApiEndpoints', () {
    test('should have baseUrl defined', () {
      expect(ApiEndpoints.baseUrl, isNotEmpty);
    });

    test('should have socketUrl defined', () {
      expect(ApiEndpoints.socketUrl, isNotEmpty);
    });

    test('should have connection timeout defined', () {
      expect(ApiEndpoints.connectionTimeout, const Duration(seconds: 30));
    });

    test('should have receive timeout defined', () {
      expect(ApiEndpoints.receiveTimeout, const Duration(seconds: 30));
    });

    test('should have all auth endpoints', () {
      expect(ApiEndpoints.users, '/auth');
      expect(ApiEndpoints.userLogin, '/auth/login');
      expect(ApiEndpoints.userRegister, '/auth/register');
    });

    test('should have all shop endpoints', () {
      expect(ApiEndpoints.registerShop, '/shop/register-shop');
      expect(ApiEndpoints.myShop, '/shop/my-shop');
    });

    test('should have product endpoints', () {
      expect(ApiEndpoints.getAllProduct, '/product/');
    });

    test('should have cart endpoints', () {
      expect(ApiEndpoints.addToCart, '/cart/add');
      expect(ApiEndpoints.getCart, '/cart/');
      expect(ApiEndpoints.clearCart, '/cart/clear');
    });

    test('should have order endpoints', () {
      expect(ApiEndpoints.createOrder, '/order/');
      expect(ApiEndpoints.getMyOrders, '/order/my-orders');
      expect(ApiEndpoints.getPendingOrders, '/order/shop/pending');
    });

    test('should have notification endpoints', () {
      expect(ApiEndpoints.getNotifications, '/notification');
      expect(ApiEndpoints.markAllNotificationsRead, '/notification/read-all');
    });

    test('should have rating endpoints', () {
      expect(ApiEndpoints.createRating, '/rating');
    });

    test('userById should interpolate id', () {
      expect(ApiEndpoints.userById('123'), '/auth/123');
    });

    test('vendorRatings should interpolate vendorId', () {
      expect(ApiEndpoints.vendorRatings('v1'), '/rating/vendor/v1');
    });
  });
}
