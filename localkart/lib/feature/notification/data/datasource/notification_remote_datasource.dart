import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/api/api_client.dart';
import 'package:localkart/core/api/api_endpoints.dart';
import 'package:localkart/feature/notification/data/models/notification_api_model.dart';

abstract interface class INotificationRemoteDatasource {
  Future<List<NotificationApiModel>> getNotifications({
    int page = 1,
    int limit = 20,
  });

  Future<int> getUnreadCount();

  Future<void> markAsRead(String notificationId);

  Future<void> markAllAsRead();

  Future<void> deleteNotification(String notificationId);
}

final notificationRemoteDatasourceProvider =
    Provider<INotificationRemoteDatasource>((ref) {
  return NotificationRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class NotificationRemoteDatasource implements INotificationRemoteDatasource {
  final ApiClient _apiClient;

  NotificationRemoteDatasource({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<NotificationApiModel>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getNotifications,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) return [];

      final data = responseData['data'] as List<dynamic>?;
      if (data == null) return [];

      return data
          .map((e) => NotificationApiModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getUnreadCount);

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) return 0;

      final data = responseData['data'] as Map<String, dynamic>?;
      return data?['count'] as int? ?? 0;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      final path = ApiEndpoints.markNotificationRead(notificationId);
      await _apiClient.patch(path);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _apiClient.patch(ApiEndpoints.markAllNotificationsRead);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      final path = ApiEndpoints.deleteNotification(notificationId);
      await _apiClient.delete(path);
    } catch (e) {
      rethrow;
    }
  }
}
