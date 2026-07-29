import 'package:flutter_test/flutter_test.dart';
import 'package:localkart/feature/address/data/models/address_api_model.dart';
import 'package:localkart/feature/address/domain/entities/address_entity.dart';
import '../../helpers/test_data.dart';

void main() {
  group('AddressApiModel', () {
    group('fromJson', () {
      test('should parse address JSON correctly', () {
        final json = createTestAddressJson();
        final model = AddressApiModel.fromJson(json);
        expect(model.addressId, 'addr-1');
        expect(model.label, 'Home');
        expect(model.fullAddress, 'Kathmandu, Nepal');
        expect(model.latitude, 27.7172);
        expect(model.longitude, 85.3240);
      });

      test('should handle missing fields with defaults', () {
        final json = <String, dynamic>{};
        final model = AddressApiModel.fromJson(json);
        expect(model.label, 'Home');
        expect(model.fullAddress, '');
        expect(model.latitude, 0.0);
        expect(model.longitude, 0.0);
      });

      test('should handle populated userId', () {
        final json = createTestAddressJson();
        json['userId'] = {'_id': 'user-1'};
        final model = AddressApiModel.fromJson(json);
        expect(model.userId, 'user-1');
      });
    });

    group('fromJsonWithData', () {
      test('should unwrap data wrapper', () {
        final json = {'success': true, 'data': createTestAddressJson()};
        final model = AddressApiModel.fromJsonWithData(json);
        expect(model.addressId, 'addr-1');
      });
    });

    test('toJson returns correct map', () {
      final model = createTestAddressApiModel();
      final json = model.toJson();
      expect(json['label'], 'Home');
      expect(json['fullAddress'], 'Kathmandu, Nepal');
      expect(json['latitude'], 27.7172);
      expect(json['longitude'], 85.3240);
    });

    test('toEntity converts correctly', () {
      final model = createTestAddressApiModel();
      final entity = model.toEntity();
      expect(entity, isA<AddressEntity>());
      expect(entity.fullAddress, model.fullAddress);
    });

    test('toEntityList converts list correctly', () {
      final models = [createTestAddressApiModel()];
      final entities = AddressApiModel.toEntityList(models);
      expect(entities.length, 1);
    });
  });
}
