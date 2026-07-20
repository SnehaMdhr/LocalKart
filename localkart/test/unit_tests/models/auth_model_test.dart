import 'package:flutter_test/flutter_test.dart';
import 'package:localkart/feature/auth/data/models/auth_api_model.dart';
import 'package:localkart/feature/auth/domain/entities/auth_entity.dart';
import '../../helpers/test_data.dart';

void main() {
  group('AuthApiModel', () {
    group('fromJson', () {
      test('should parse JSON correctly', () {
        final json = createTestAuthJson();
        final model = AuthApiModel.fromJson(json);
        expect(model.id, 'user-1');
        expect(model.name, 'John Doe');
        expect(model.email, 'john@test.com');
        expect(model.phone, '9876543210');
        expect(model.role, 'Customer');
      });

      test('should handle missing fields with defaults', () {
        final json = <String, dynamic>{};
        final model = AuthApiModel.fromJson(json);
        expect(model.name, '');
        expect(model.email, '');
        expect(model.role, 'Customer');
      });

      test('should handle null phone gracefully', () {
        final json = createTestAuthJson()..remove('phone');
        final model = AuthApiModel.fromJson(json);
        expect(model.phone, isNull);
      });
    });

    group('toJson', () {
      test('should serialize to JSON correctly', () {
        final model = createTestAuthApiModel();
        final json = model.toJson();
        expect(json['name'], 'John Doe');
        expect(json['email'], 'john@test.com');
        expect(json['phone'], '9876543210');
      });
    });

    group('toEntity', () {
      test('should convert to entity correctly', () {
        final model = createTestAuthApiModel();
        final entity = model.toEntity();
        expect(entity.name, model.name);
        expect(entity.email, model.email);
        expect(entity.userId, model.id);
      });
    });

    group('fromEntity', () {
      test('should create model from entity', () {
        final entity = createTestAuthEntity();
        final model = AuthApiModel.fromEntity(entity);
        expect(model.name, entity.name);
        expect(model.email, entity.email);
      });
    });

    group('toEntityList', () {
      test('should convert list of models to list of entities', () {
        final models = [createTestAuthApiModel(), createTestAuthApiModel(id: 'user-2')];
        final entities = AuthApiModel.toEntityList(models);
        expect(entities.length, 2);
        expect(entities[0].userId, 'user-1');
        expect(entities[1].userId, 'user-2');
      });
    });
  });
}
