import 'package:flutter_test/flutter_test.dart';
import 'package:localkart/feature/collection/data/models/collection_api_model.dart';
import '../../helpers/test_data.dart';

void main() {
  group('CollectionApiModel', () {
    group('fromJson', () {
      test('should parse collection JSON correctly', () {
        final json = createTestCollectionJson();
        final model = CollectionApiModel.fromJson(json);
        expect(model.collectionId, 'coll-1');
        expect(model.collectionName, 'My Favorites');
        expect(model.productIds, contains('prod-1'));
      });

      test('should handle populated userId', () {
        final json = createTestCollectionJson();
        json['userId'] = {'_id': 'user-1'};
        final model = CollectionApiModel.fromJson(json);
        expect(model.userId, 'user-1');
      });

      test('should handle productIds as populated objects', () {
        final json = createTestCollectionJson();
        json['productIds'] = [
          {'_id': 'prod-1'},
          {'_id': 'prod-2'},
        ];
        final model = CollectionApiModel.fromJson(json);
        expect(model.productIds, contains('prod-1'));
      });

      test('should handle missing fields with defaults', () {
        final json = <String, dynamic>{};
        final model = CollectionApiModel.fromJson(json);
        expect(model.collectionName, '');
        expect(model.productIds, isEmpty);
      });
    });

    test('toJson returns correct map', () {
      final model = createTestCollectionApiModel();
      final json = model.toJson();
      expect(json['collectionName'], 'My Favorites');
    });

    test('toEntity converts correctly', () {
      final model = createTestCollectionApiModel();
      final entity = model.toEntity();
      expect(entity.collectionName, model.collectionName);
    });

    test('fromJsonList parses list correctly', () {
      final list = [createTestCollectionJson(), createTestCollectionJson()];
      final models = CollectionApiModel.fromJsonList(list);
      expect(models.length, 2);
    });

    test('toEntityList converts list correctly', () {
      final models = [createTestCollectionApiModel()];
      final entities = CollectionApiModel.toEntityList(models);
      expect(entities.length, 1);
    });
  });
}
