import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/services/connectivity/network_info.dart';
import 'package:localkart/feature/notification/data/datasource/notification_remote_datasource.dart';
import 'package:localkart/feature/notification/data/models/notification_api_model.dart';
import 'package:localkart/feature/notification/domain/entities/notification_entity.dart';
import 'package:localkart/feature/notification/domain/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {
  final remoteDatasource = ref.read(notificationRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return NotificationRepository(
    remoteDatasource: remoteDatasource,
    networkInfo: networkInfo,
  );
});

class NotificationRepository implements INotificationRepository {
  final INotificationRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  NotificationRepository({
    required INotificationRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  })  : _remoteDatasource = remoteDatasource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.getNotifications(
          page: page,
          limit: limit,
        );
        return Right(NotificationApiModel.toEntityList(result));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data['message'] ?? 'Failed to fetch notifications',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    if (await _networkInfo.isConnected) {
      try {
        final count = await _remoteDatasource.getUnreadCount();
        return Right(count);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ??
                'Failed to fetch unread count',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDatasource.markAsRead(notificationId);
        return const Right(null);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ??
                'Failed to mark notification as read',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDatasource.markAllAsRead();
        return const Right(null);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ??
                'Failed to mark all as read',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(
    String notificationId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDatasource.deleteNotification(notificationId);
        return const Right(null);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ??
                'Failed to delete notification',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
