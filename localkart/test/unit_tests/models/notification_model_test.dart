import 'package:flutter_test/flutter_test.dart';
import 'package:localkart/feature/notification/data/models/notification_api_model.dart';
import 'package:localkart/feature/notification/domain/entities/notification_entity.dart';
import '../../helpers/test_data.dart';

void main() {
  group('NotificationApiModel', () {
    group('fromJson', () {
      test('should parse notification JSON correctly', () {
        final json = createTestNotificationJson();
        final model = NotificationApiModel.fromJson(json);
        expect(model.notificationId, 'notif-1');
        expect(model.title, 'Order Update');
        expect(model.type, 'ORDER');
        expect(model.isRead, false);
      });

      test('should handle missing fields with defaults', () {
        final json = <String, dynamic>{};
        final model = NotificationApiModel.fromJson(json);
        expect(model.title, '');
        expect(model.message, '');
        expect(model.type, 'SYSTEM');
        expect(model.isRead, false);
      });
    });

    test('toJson returns correct map', () {
      final model = createTestNotificationApiModel();
      final json = model.toJson();
      expect(json['title'], 'Order Update');
      expect(json['type'], 'ORDER');
      expect(json['receiverId'], 'user-1');
    });

    test('toEntity converts correctly', () {
      final model = createTestNotificationApiModel();
      final entity = model.toEntity();
      expect(entity, isA<NotificationEntity>());
      expect(entity.title, model.title);
    });

    test('fromEntity creates model from entity', () {
      final entity = createTestNotificationEntity();
      final model = NotificationApiModel.fromEntity(entity);
      expect(model.title, entity.title);
      expect(model.message, entity.message);
    });

    test('toEntityList converts list correctly', () {
      final models = [createTestNotificationApiModel()];
      final entities = NotificationApiModel.toEntityList(models);
      expect(entities.length, 1);
    });
  });
}
