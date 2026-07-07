import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/services/connectivity/network_info.dart';
import 'package:localkart/feature/address/data/datasource/address_datasource.dart';
import 'package:localkart/feature/address/data/datasource/local/address_local_datasource.dart';
import 'package:localkart/feature/address/data/datasource/remote/address_remote_datasource.dart';
import 'package:localkart/feature/address/data/models/address_api_model.dart';
import 'package:localkart/feature/address/data/models/address_hive_model.dart';
import 'package:localkart/feature/address/domain/entities/address_entity.dart';
import 'package:localkart/feature/address/domain/repositories/address_repository.dart';

final addressRepositoryProvider = Provider<IAddressRepository>((ref) {
  final localDatasource = ref.read(addressLocalDatasourceProvider);
  final remoteDatasource = ref.read(addressRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return AddressRepository(
    localDatasource: localDatasource,
    remoteDatasource: remoteDatasource,
    networkInfo: networkInfo,
  );
});

class AddressRepository implements IAddressRepository {
  final IAddressLocalDatasource _localDatasource;
  final IAddressRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  AddressRepository({
    required IAddressLocalDatasource localDatasource,
    required IAddressRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, AddressEntity>> createAddress({
    required String label,
    required String fullAddress,
    required double latitude,
    required double longitude,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.createAddress(
          label: label,
          fullAddress: fullAddress,
          latitude: latitude,
          longitude: longitude,
        );

        if (result == null) {
          return Left(ApiFailure(message: "Failed to create address"));
        }

        // Refresh local cache
        await _refreshLocalCache();

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to create address",
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
  Future<Either<Failure, List<AddressEntity>>> getAddresses() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.getAddresses();

        // Cache locally
        await _localDatasource.cacheAddresses(
          result.map((e) => e.toHiveModel()).toList(),
        );

        return Right(AddressApiModel.toEntityList(result));
      } on DioException catch (e) {
        // Fallback to local cache on API error
        return _getLocalAddresses(e);
      } catch (e) {
        return _getLocalAddresses(e);
      }
    } else {
      return _getLocalAddresses();
    }
  }

  Future<Either<Failure, List<AddressEntity>>> _getLocalAddresses(
      [dynamic error]) async {
    try {
      final localData = await _localDatasource.getAddresses();
      return Right(AddressHiveModel.toEntityList(localData));
    } catch (e) {
      if (error is DioException) {
        return Left(
          ApiFailure(
            message: error.response?.data["message"] ?? "Failed to fetch addresses",
            statusCode: error.response?.statusCode,
          ),
        );
      }
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> getAddressById(
      String addressId) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.getAddressById(addressId);

        if (result == null) {
          return Left(ApiFailure(message: "Address not found"));
        }

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to fetch address",
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
  Future<Either<Failure, AddressEntity>> updateAddress({
    required String addressId,
    String? label,
    String? fullAddress,
    double? latitude,
    double? longitude,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.updateAddress(
          addressId: addressId,
          label: label,
          fullAddress: fullAddress,
          latitude: latitude,
          longitude: longitude,
        );

        if (result == null) {
          return Left(ApiFailure(message: "Failed to update address"));
        }

        // Refresh local cache
        await _refreshLocalCache();

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to update address",
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
  Future<Either<Failure, void>> deleteAddress(String addressId) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDatasource.deleteAddress(addressId);

        // Refresh local cache
        await _refreshLocalCache();

        return const Right(null);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to delete address",
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

  Future<void> _refreshLocalCache() async {
    try {
      final addresses = await _remoteDatasource.getAddresses();
      await _localDatasource.cacheAddresses(
        addresses.map((e) => e.toHiveModel()).toList(),
      );
    } catch (_) {
      // Silent fail on cache refresh
    }
  }
}
