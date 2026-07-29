import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/rating/data/repositories/rating_repository.dart';
import 'package:localkart/feature/rating/domain/entities/rating_entity.dart';
import 'package:localkart/feature/rating/domain/repositories/rating_repository.dart';

class GetOrderRatingParams extends Equatable {
  final String orderId;

  const GetOrderRatingParams({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

final getOrderRatingUsecaseProvider =
    Provider<GetOrderRatingUsecase>((ref) {
  final ratingRepository = ref.read(ratingRepositoryProvider);
  return GetOrderRatingUsecase(ratingRepository: ratingRepository);
});

class GetOrderRatingUsecase
    implements UseCaseWithParams<RatingEntity?, GetOrderRatingParams> {
  final IRatingRepository _ratingRepository;

  GetOrderRatingUsecase({required IRatingRepository ratingRepository})
      : _ratingRepository = ratingRepository;

  @override
  Future<Either<Failure, RatingEntity?>> call(GetOrderRatingParams params) {
    return _ratingRepository.getOrderRating(params.orderId);
  }
}
