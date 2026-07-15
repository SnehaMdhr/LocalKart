import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/services/connectivity/network_info.dart';
import 'package:localkart/feature/order/data/datasource/order_datasource.dart';
import 'package:localkart/feature/order/data/datasource/local/order_local_datasource.dart';
import 'package:localkart/feature/order/data/datasource/remote/order_remote_datasource.dart';
import 'package:localkart/feature/order/data/models/order_api_model.dart';
import 'package:localkart/feature/order/data/models/order_hive_model.dart';
import 'package:localkart/feature/order/domain/entities/order_entity.dart';
import 'package:localkart/feature/order/domain/repositories/order_repository.dart';

final orderRepositoryProvider = Provider<IOrderRepository>((ref) {
  final localDatasource = ref.read(orderLocalDatasourceProvider);
  final remoteDatasource = ref.read(orderRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return OrderRepository(
    localDatasource: localDatasource,
    remoteDatasource: remoteDatasource,
    networkInfo: networkInfo,
  );
});

class OrderRepository implements IOrderRepository {
  final IOrderLocalDatasource _localDatasource;
  final IOrderRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  OrderRepository({
    required IOrderLocalDatasource localDatasource,
    required IOrderRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, OrderEntity>> placeOrder({
    required String deliveryAddress,
    required double latitude,
    required double longitude,
    required String paymentMethod,
    String? customerNote,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.placeOrder(
          deliveryAddress: deliveryAddress,
          latitude: latitude,
          longitude: longitude,
          paymentMethod: paymentMethod,
          customerNote: customerNote,
        );

        if (result == null) {
          return Left(ApiFailure(message: "Failed to place order"));
        }

        // Cache the new order locally
        await _localDatasource.cacheOrders([result.toHiveModel()]);

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to place order",
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
  Future<Either<Failure, List<OrderEntity>>> getShopOrders() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.getShopOrders();

        // Cache orders locally
        final hiveModels = result.map((e) => e.toHiveModel()).toList();
        await _localDatasource.cacheOrders(hiveModels);

        return Right(OrderApiModel.toEntityList(result));
      } on DioException catch (e) {
        return _getOrdersFromLocal(e);
      } catch (e) {
        return _getOrdersFromLocal(null);
      }
    } else {
      return _getOrdersFromLocal(null);
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getPendingOrders() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.getPendingOrders();
        return Right(OrderApiModel.toEntityList(result));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data["message"] ?? "Failed to fetch pending orders",
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
  Future<Either<Failure, List<OrderEntity>>> getMyOrders() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.getMyOrders();

        // Cache orders locally
        final hiveModels = result.map((e) => e.toHiveModel()).toList();
        await _localDatasource.cacheOrders(hiveModels);

        return Right(OrderApiModel.toEntityList(result));
      } on DioException catch (e) {
        // Fall back to local cache on API error
        return _getOrdersFromLocal(e);
      } catch (e) {
        return _getOrdersFromLocal(null);
      }
    } else {
      return _getOrdersFromLocal(null);
    }
  }

  Future<Either<Failure, List<OrderEntity>>> _getOrdersFromLocal(
    DioException? error,
  ) async {
    try {
      final localData = await _localDatasource.getOrders();
      if (localData.isEmpty && error != null) {
        return Left(
          ApiFailure(
            message:
                error.response?.data["message"] ?? "Failed to fetch orders",
            statusCode: error.response?.statusCode,
          ),
        );
      }
      return Right(OrderHiveModel.toEntityList(localData));
    } catch (e) {
      if (error != null) {
        return Left(
          ApiFailure(
            message:
                error.response?.data["message"] ?? "Failed to fetch orders",
            statusCode: error.response?.statusCode,
          ),
        );
      }
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.getOrderById(orderId);

        if (result == null) {
          return Left(ApiFailure(message: "Order not found"));
        }

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data["message"] ?? "Failed to fetch order",
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
  Future<Either<Failure, OrderEntity>> acceptOrder({
    required String orderId,
    int? estimatedDeliveryTime,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.acceptOrder(
          orderId: orderId,
          estimatedDeliveryTime: estimatedDeliveryTime,
        );

        if (result == null) {
          return Left(ApiFailure(message: "Failed to accept order"));
        }

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data["message"] ?? "Failed to accept order",
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
  Future<Either<Failure, OrderEntity>> rejectOrder(String orderId) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.rejectOrder(orderId);

        if (result == null) {
          return Left(ApiFailure(message: "Failed to reject order"));
        }

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data["message"] ?? "Failed to reject order",
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
  Future<Either<Failure, OrderEntity>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.updateOrderStatus(
          orderId: orderId,
          status: status,
        );

        if (result == null) {
          return Left(
            ApiFailure(message: "Failed to update order status"),
          );
        }

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ??
                "Failed to update order status",
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
  Future<Either<Failure, Map<String, dynamic>>> getOrderEtd(String orderId) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.getOrderEtd(orderId);
        if (result == null) {
          return Left(ApiFailure(message: "Failed to get ETD"));
        }
        return Right(result);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to get ETD",
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
  Future<Either<Failure, OrderEntity>> markOrderPaid(String orderId) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.markOrderPaid(orderId);

        if (result == null) {
          return Left(ApiFailure(message: "Failed to mark order as paid"));
        }

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ??
                "Failed to mark order as paid",
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
