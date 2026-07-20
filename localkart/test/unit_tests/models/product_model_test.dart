import 'package:flutter_test/flutter_test.dart';
import 'package:localkart/feature/product/data/models/product_api_model.dart';
import 'package:localkart/feature/product/domain/entities/product_entity.dart';
import '../../helpers/test_data.dart';

void main() {
  group('ProductApiModel', () {
    group('fromJson', () {
      test('should parse JSON correctly', () {
        final json = createTestProductJson();
        final model = ProductApiModel.fromJson(json);
        expect(model.productId, 'prod-1');
        expect(model.productName, 'Apple');
        expect(model.price, 100);
        expect(model.unit, 'kg');
      });

      test('should handle missing fields with defaults', () {
        final json = <String, dynamic>{};
        final model = ProductApiModel.fromJson(json);
        expect(model.productName, '');
        expect(model.price, 0);
        expect(model.unit, '');
      });

      test('should accept _id or productId', () {
        final json = createTestProductJson()..remove('_id');
        json['productId'] = 'alt-1';
        final model = ProductApiModel.fromJson(json);
        expect(model.productId, 'alt-1');
      });
    });

    group('toJson', () {
      test('should serialize to JSON correctly', () {
        final model = createTestProductApiModel();
        final json = model.toJson();
        expect(json['productName'], 'Apple');
        expect(json['price'], 100);
        expect(json['description'], 'Fresh apple');
      });
    });

    group('toEntity', () {
      test('should convert to entity correctly', () {
        final model = createTestProductApiModel();
        final entity = model.toEntity();
        expect(entity.productName, model.productName);
        expect(entity.price, model.price);
        expect(entity.unit, model.unit);
      });
    });

    group('fromEntity', () {
      test('should create model from entity', () {
        final entity = createTestProductEntity();
        final model = ProductApiModel.fromEntity(entity);
        expect(model.productName, entity.productName);
        expect(model.price, entity.price);
      });
    });

    group('fromJsonList', () {
      test('should parse list of JSON objects', () {
        final jsonList = [createTestProductJson(), createTestProductJson()..update('productName', (v) => 'Banana')];
        final models = ProductApiModel.fromJsonList(jsonList);
        expect(models.length, 2);
      });
    });

    group('toEntityList', () {
      test('should convert list of models to entities', () {
        final models = [createTestProductApiModel()];
        final entities = ProductApiModel.toEntityList(models);
        expect(entities.length, 1);
        expect(entities[0], isA<ProductEntity>());
      });
    });
  });
}
