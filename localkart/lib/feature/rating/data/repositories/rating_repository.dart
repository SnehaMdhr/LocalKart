import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/services/connectivity/network_info.dart';
import 'package:localkart/feature/rating/data/datasource/rating_remote_datasource.dart';
import 'package:localkart/feature/rating/data/models/rating_api_model.dart';
import 'package:localkart/feature/rating/domain/entities/rating_entity.dart';
import 'package:localkart/feature/rating/domain/repositories/rating_repository.dart';

final ratingRepositoryProvider = Provider<IRatingRepository>((ref) {
  final remoteDatasource = ref.read(ratingRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return RatingRepository(
    remoteDatasource: remoteDatasource,
    networkInfo: networkInfo,
  );
});

class RatingRepository implements IRatingRepository {
  final IRatingRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  RatingRepository({
    required IRatingRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  })  : _remoteDatasource = remoteDatasource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, RatingEntity>> createRating({
    required String orderId,
    required int rating,
    String? comment,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.createRating(
          orderId: orderId,
          rating: rating,
          comment: comment,
        );

        if (result == null) {
          return Left(ApiFailure(message: "Failed to submit rating"));
        }

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to submit rating",
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
  Future<Either<Failure, List<RatingEntity>>> getVendorRatings(
      String vendorId) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.getVendorRatings(vendorId);
        return Right(RatingApiModel.toEntityList(result));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ??
                "Failed to fetch vendor ratings",
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
  Future<Either<Failure, RatingEntity?>> getOrderRating(String orderId) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.getOrderRating(orderId);
        if (result == null) return const Right(null);
        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ??
                "Failed to fetch order rating",
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
  Future<Either<Failure, RatingEntity>> updateRating({
    required String ratingId,
    int? rating,
    String? comment,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.updateRating(
          ratingId: ratingId,
          rating: rating,
          comment: comment,
        );

        if (result == null) {
          return Left(ApiFailure(message: "Failed to update rating"));
        }

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to update rating",
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
  Future<Either<Failure, void>> deleteRating(String ratingId) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDatasource.deleteRating(ratingId);
        return const Right(null);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to delete rating",
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
