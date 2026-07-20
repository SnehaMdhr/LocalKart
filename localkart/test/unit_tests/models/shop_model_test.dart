import 'package:flutter_test/flutter_test.dart';
import 'package:localkart/feature/vendor_registeration/data/models/shop_api_model.dart';
import 'package:localkart/feature/vendor_registeration/domain/entities/shop_entity.dart';
import '../../helpers/test_data.dart';

void main() {
  group('ShopApiModel', () {
    group('fromJson', () {
      test('should parse shop JSON correctly', () {
        final json = createTestShopJson();
        final model = ShopApiModel.fromJson(json);
        expect(model.id, 'shop-1');
        expect(model.shopName, 'My Store');
        expect(model.categories, contains('Vegetables'));
        expect(model.status, 'Approved');
      });

      test('should handle missing fields with defaults', () {
        final json = <String, dynamic>{};
        final model = ShopApiModel.fromJson(json);
        expect(model.shopName, '');
        expect(model.address, '');
        expect(model.categories, isEmpty);
      });
    });

    group('toJson', () {
      test('should serialize correctly', () {
        final model = createTestShopApiModel();
        final json = model.toJson();
        expect(json['shopName'], 'My Store');
        expect(json['address'], 'Kathmandu');
        expect(json['latitude'], 27.7172);
      });

      test('should only include non-null optional fields', () {
        final model = ShopApiModel(
          shopName: 'Test',
          address: 'Addr',
          description: 'Desc',
          categories: [],
        );
        final json = model.toJson();
        expect(json.containsKey('latitude'), false);
        expect(json.containsKey('longitude'), false);
      });
    });

    test('toEntity converts correctly', () {
      final model = createTestShopApiModel();
      final entity = model.toEntity();
      expect(entity, isA<ShopEntity>());
      expect(entity.shopName, model.shopName);
      expect(entity.shopId, model.id);
    });

    test('fromEntity creates model from entity', () {
      final entity = createTestShopEntity();
      final model = ShopApiModel.fromEntity(entity);
      expect(model.shopName, entity.shopName);
      expect(model.categories, entity.categories);
    });

    test('toEntityList converts list correctly', () {
      final models = [createTestShopApiModel(), createTestShopApiModel(id: 'shop-2')];
      final entities = ShopApiModel.toEntityList(models);
      expect(entities.length, 2);
    });
  });
}
