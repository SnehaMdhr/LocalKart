import 'package:dartz/dartz.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/feature/rating/domain/entities/rating_entity.dart';

abstract interface class IRatingRepository {
  Future<Either<Failure, RatingEntity>> createRating({
    required String orderId,
    required int rating,
    String? comment,
  });
  Future<Either<Failure, List<RatingEntity>>> getVendorRatings(String vendorId);
  Future<Either<Failure, RatingEntity?>> getOrderRating(String orderId);
  Future<Either<Failure, RatingEntity>> updateRating({
    required String ratingId,
    int? rating,
    String? comment,
  });
  Future<Either<Failure, void>> deleteRating(String ratingId);
}
