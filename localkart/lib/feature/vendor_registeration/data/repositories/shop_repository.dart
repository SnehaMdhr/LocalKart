import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/services/connectivity/network_info.dart';
import 'package:localkart/feature/vendor_registeration/data/datasources/remote/shop_remote_datasource.dart';
import 'package:localkart/feature/vendor_registeration/data/models/shop_api_model.dart';
import 'package:localkart/feature/vendor_registeration/data/models/shop_hive_model.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/shop_entity.dart';
import '../../domain/repositories/shop_repository.dart';
import '../datasources/shop_datasource.dart';
import '../datasources/local/shop_local_datasource.dart';

final shopRepositoryProvider = Provider<IShopRepository>((ref) {
  final shopDatasource = ref.read(shopLocalDatasourceProvider);
  final shopRemoteDatasource = ref.read(shopRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return ShopRepository(
    shopLocalDatasource: shopDatasource,
    shopRemoteDatasource: shopRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class ShopRepository implements IShopRepository {
  final IShopLocalDatasource _shopLocalDatasource;
  final IShopRemoteDatasource _shopRemoteDatasource;
  final NetworkInfo _networkInfo;

  ShopRepository({
    required IShopLocalDatasource shopLocalDatasource,
    required IShopRemoteDatasource shopRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _shopLocalDatasource = shopLocalDatasource,
       _shopRemoteDatasource = shopRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, bool>> registerShop(ShopEntity entity) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = ShopApiModel.fromEntity(entity);
        await _shopRemoteDatasource.registerShop(apiModel);
        return const Right(true);
      } on DioException catch (e) {
        return left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Shop registration failed",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final model = ShopHiveModel.fromEntity(entity);
        final result = await _shopLocalDatasource.registerShop(model);
        if (result) {
          return Right(true);
        }
        return Left(LocalDatabaseFailure(message: "Failed to register shop"));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }
}
