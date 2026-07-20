import 'package:flutter_test/flutter_test.dart';
import 'package:localkart/feature/rating/data/models/rating_api_model.dart';
import 'package:localkart/feature/rating/domain/entities/rating_entity.dart';
import '../../helpers/test_data.dart';

void main() {
  group('RatingApiModel', () {
    group('fromJson', () {
      test('should parse rating JSON correctly', () {
        final json = createTestRatingJson();
        final model = RatingApiModel.fromJson(json);
        expect(model.ratingId, 'rating-1');
        expect(model.rating, 5);
        expect(model.comment, 'Great service!');
      });

      test('should handle missing fields with defaults', () {
        final json = <String, dynamic>{};
        final model = RatingApiModel.fromJson(json);
        expect(model.rating, 0);
        expect(model.comment, '');
      });

      test('should parse populated customerId', () {
        final json = createTestRatingJson();
        json['customerId'] = {
          '_id': 'user-1',
          'name': 'John Doe',
          'imageUrl': 'img.jpg',
        };
        final model = RatingApiModel.fromJson(json);
        expect(model.customerName, 'John Doe');
        expect(model.customerImageUrl, 'img.jpg');
      });

      test('should parse populated orderId for orderNumber', () {
        final json = createTestRatingJson();
        json['orderId'] = {
          '_id': 'order-1',
          'orderNumber': 'ORD-001',
        };
        final model = RatingApiModel.fromJson(json);
        expect(model.orderNumber, 'ORD-001');
      });
    });

    test('toJson returns correct map', () {
      final model = createTestRatingApiModel();
      final json = model.toJson();
      expect(json['rating'], 5);
      expect(json['comment'], 'Great service!');
    });

    test('toEntity converts correctly', () {
      final model = createTestRatingApiModel();
      final entity = model.toEntity();
      expect(entity, isA<RatingEntity>());
      expect(entity.rating, model.rating);
    });

    test('toEntityList converts list correctly', () {
      final models = [createTestRatingApiModel()];
      final entities = RatingApiModel.toEntityList(models);
      expect(entities.length, 1);
    });
  });
}
