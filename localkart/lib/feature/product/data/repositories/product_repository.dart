import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/services/connectivity/network_info.dart';
import 'package:localkart/feature/product/data/datasource/local/product_local_datasource.dart';
import 'package:localkart/feature/product/data/datasource/product_datasource.dart';
import 'package:localkart/feature/product/data/datasource/remote/product_remote_datasource.dart';
import 'package:localkart/feature/product/data/models/product_api_model.dart';
import 'package:localkart/feature/product/data/models/product_hive_model.dart';
import 'package:localkart/feature/product/domain/entities/product_entity.dart';
import 'package:localkart/feature/product/domain/repositories/product_repository.dart';

final productRepositoryProvider = Provider<IProductRepository>((ref) {
  final productDatasource = ref.read(productLocalDatasourceProvider);
  final productRemoteDatasource = ref.read(productRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return ProductRepository(
    productLocalDatasource: productDatasource,
    productRemoteDatasource: productRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class ProductRepository implements IProductRepository {
  final IProductLocalDatasource _productLocalDatasource;
  final IProductRemoteDatasource _productRemoteDataSource;
  final NetworkInfo _networkInfo;

  ProductRepository({
    required IProductLocalDatasource productLocalDatasource,
    required IProductRemoteDatasource productRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _productLocalDatasource = productLocalDatasource,
       _productRemoteDataSource = productRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<ProductEntity>>> getAllProducts() async {
    if (await _networkInfo.isConnected) {
      try {
        final remoteData = await _productRemoteDataSource.getAllProducts();

        if (remoteData == null) {
          return Left(ApiFailure(message: "Failed to fetch products"));
        }

        final hiveModels = remoteData
            .map((ProductApiModel apiModel) => apiModel.toHiveModel())
            .toList();

        await _productLocalDatasource.cacheProducts(hiveModels);

        final entities = remoteData
            .map((ProductApiModel apiModel) => apiModel.toEntity())
            .toList();

        return Right(entities);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to fetch products",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final localData = await _productLocalDatasource.getAllProducts();
        if (localData == null || localData.isEmpty) {
          return Left(
            LocalDatabaseFailure(message: "No cached products found"),
          );
        }

        final entities = localData
            .map((ProductHiveModel model) => model.toEntity())
            .toList();

        return Right(entities);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(
    String productId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final remoteProduct = await _productRemoteDataSource.getProductById(
          productId,
        );

        if (remoteProduct == null) {
          return Left(ApiFailure(message: "Product not found"));
        }

        return Right(remoteProduct.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to fetch product",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final localProduct = await _productLocalDatasource.getProductById(
          productId,
        );
        if (localProduct == null) {
          return Left(
            LocalDatabaseFailure(message: "Product not found in cache"),
          );
        }

        return Right(localProduct.toEntity());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }
}
