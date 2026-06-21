import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/services/connectivity/network_info.dart';
import 'package:localkart/feature/collection/data/datasource/collection_datasource.dart';
import 'package:localkart/feature/collection/data/datasource/local/collection_local_datasource.dart';
import 'package:localkart/feature/collection/data/datasource/remote/collection_remote_datasource.dart';
import 'package:localkart/feature/collection/data/models/collection_api_model.dart';
import 'package:localkart/feature/collection/data/models/collection_hive_model.dart';
import 'package:localkart/feature/collection/domain/entities/collection_entity.dart';
import 'package:localkart/feature/collection/domain/repositories/collection_repository.dart';

final collectionRepositoryProvider = Provider<ICollectionRepository>((ref) {
  final localDatasource = ref.read(collectionLocalDatasourceProvider);
  final remoteDatasource = ref.read(collectionRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return CollectionRepository(
    localDatasource: localDatasource,
    remoteDatasource: remoteDatasource,
    networkInfo: networkInfo,
  );
});

class CollectionRepository implements ICollectionRepository {
  final ICollectionLocalDatasource _localDatasource;
  final ICollectionRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  CollectionRepository({
    required ICollectionLocalDatasource localDatasource,
    required ICollectionRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<CollectionEntity>>> getAllCollections() async {
    if (await _networkInfo.isConnected) {
      try {
        final remoteData = await _remoteDatasource.getAllCollections();

        if (remoteData == null) {
          return Left(ApiFailure(message: "Failed to fetch collections"));
        }

        final hiveModels = remoteData
            .map((CollectionApiModel apiModel) => apiModel.toHiveModel())
            .toList();

        await _localDatasource.cacheCollections(hiveModels);

        final entities = remoteData
            .map((CollectionApiModel apiModel) => apiModel.toEntity())
            .toList();

        return Right(entities);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data["message"] ?? "Failed to fetch collections",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final localData = await _localDatasource.getAllCollections();
        if (localData == null || localData.isEmpty) {
          return Left(
            LocalDatabaseFailure(message: "No cached collections found"),
          );
        }

        final entities = localData
            .map((CollectionHiveModel model) => model.toEntity())
            .toList();

        return Right(entities);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, CollectionEntity>> getCollectionById(
      String collectionId) async {
    if (await _networkInfo.isConnected) {
      try {
        final remoteCollection =
            await _remoteDatasource.getCollectionById(collectionId);

        if (remoteCollection == null) {
          return Left(ApiFailure(message: "Collection not found"));
        }

        return Right(remoteCollection.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data["message"] ?? "Failed to fetch collection",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final localCollection =
            await _localDatasource.getCollectionById(collectionId);
        if (localCollection == null) {
          return Left(
            LocalDatabaseFailure(message: "Collection not found in cache"),
          );
        }

        return Right(localCollection.toEntity());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, CollectionEntity>> createCollection(
      String collectionName) async {
    if (await _networkInfo.isConnected) {
      try {
        final remoteCollection =
            await _remoteDatasource.createCollection(collectionName);

        if (remoteCollection == null) {
          return Left(ApiFailure(message: "Failed to create collection"));
        }

        return Right(remoteCollection.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data["message"] ?? "Failed to create collection",
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
  Future<Either<Failure, void>> deleteCollection(String collectionId) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDatasource.deleteCollection(collectionId);
        return const Right(null);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data["message"] ?? "Failed to delete collection",
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
  Future<Either<Failure, CollectionEntity>> addProductToCollection(
    String collectionId,
    String productId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.addProductToCollection(
          collectionId,
          productId,
        );

        if (result == null) {
          return Left(ApiFailure(message: "Failed to add product"));
        }

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ??
                "Failed to add product to collection",
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
  Future<Either<Failure, CollectionEntity>> removeProductFromCollection(
    String collectionId,
    String productId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.removeProductFromCollection(
          collectionId,
          productId,
        );

        if (result == null) {
          return Left(ApiFailure(message: "Failed to remove product"));
        }

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ??
                "Failed to remove product from collection",
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
  Future<Either<Failure, CollectionEntity>> updateCollectionName(
    String collectionId,
    String newName,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.updateCollectionName(
          collectionId,
          newName,
        );

        if (result == null) {
          return Left(ApiFailure(message: "Failed to update collection name"));
        }

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ??
                "Failed to update collection name",
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
