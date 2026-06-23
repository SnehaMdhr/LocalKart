import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/services/connectivity/network_info.dart';
import 'package:localkart/feature/cart/data/datasource/cart_datasource.dart';
import 'package:localkart/feature/cart/data/datasource/local/cart_local_datasource.dart';
import 'package:localkart/feature/cart/data/datasource/remote/cart_remote_datasource.dart';
import 'package:localkart/feature/cart/domain/entities/cart_entity.dart';
import 'package:localkart/feature/cart/domain/repositories/cart_repository.dart';

final cartRepositoryProvider = Provider<ICartRepository>((ref) {
  final localDatasource = ref.read(cartLocalDatasourceProvider);
  final remoteDatasource = ref.read(cartRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return CartRepository(
    localDatasource: localDatasource,
    remoteDatasource: remoteDatasource,
    networkInfo: networkInfo,
  );
});

class CartRepository implements ICartRepository {
  final ICartLocalDatasource _localDatasource;
  final ICartRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  CartRepository({
    required ICartLocalDatasource localDatasource,
    required ICartRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, CartEntity>> addToCart({
    required String productId,
    required int quantity,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.addToCart(
          productId: productId,
          quantity: quantity,
        );

        if (result == null) {
          return Left(ApiFailure(message: "Failed to add product to cart"));
        }

        // Cache the updated cart locally
        await _localDatasource.cacheCart(result.toHiveModel());

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to add to cart",
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
  Future<Either<Failure, CartEntity>> getCart() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.getCart();

        if (result == null) {
          return Left(ApiFailure(message: "Cart not found"));
        }

        // Cache the cart locally
        await _localDatasource.cacheCart(result.toHiveModel());

        return Right(result.toEntity());
      } on DioException catch (e) {
        // If it's a 404 (no cart yet), that's OK - return empty cart
        if (e.response?.statusCode == 404) {
          return Right(const CartEntity());
        }
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to fetch cart",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final localData = await _localDatasource.getCart();
        if (localData == null) {
          return Right(const CartEntity());
        }
        return Right(localData.toEntity());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, CartEntity>> updateQuantity({
    required String productId,
    required int quantity,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.updateQuantity(
          productId: productId,
          quantity: quantity,
        );

        if (result == null) {
          return Left(ApiFailure(message: "Failed to update quantity"));
        }

        await _localDatasource.cacheCart(result.toHiveModel());

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to update quantity",
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
  Future<Either<Failure, CartEntity>> removeFromCart(String productId) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.removeFromCart(productId);

        if (result == null) {
          return Left(ApiFailure(message: "Failed to remove product from cart"));
        }

        await _localDatasource.cacheCart(result.toHiveModel());

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data["message"] ?? "Failed to remove from cart",
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
  Future<Either<Failure, void>> clearCart() async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDatasource.clearCart();
        await _localDatasource.clearCart();
        return const Right(null);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to clear cart",
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
