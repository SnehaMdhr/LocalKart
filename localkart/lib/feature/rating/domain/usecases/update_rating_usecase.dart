import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/rating/data/repositories/rating_repository.dart';
import 'package:localkart/feature/rating/domain/entities/rating_entity.dart';
import 'package:localkart/feature/rating/domain/repositories/rating_repository.dart';

class UpdateRatingParams extends Equatable {
  final String ratingId;
  final int? rating;
  final String? comment;

  const UpdateRatingParams({
    required this.ratingId,
    this.rating,
    this.comment,
  });

  @override
  List<Object?> get props => [ratingId, rating, comment];
}

final updateRatingUsecaseProvider = Provider<UpdateRatingUsecase>((ref) {
  final ratingRepository = ref.read(ratingRepositoryProvider);
  return UpdateRatingUsecase(ratingRepository: ratingRepository);
});

class UpdateRatingUsecase
    implements UseCaseWithParams<RatingEntity, UpdateRatingParams> {
  final IRatingRepository _ratingRepository;

  UpdateRatingUsecase({required IRatingRepository ratingRepository})
      : _ratingRepository = ratingRepository;

  @override
  Future<Either<Failure, RatingEntity>> call(UpdateRatingParams params) {
    return _ratingRepository.updateRating(
      ratingId: params.ratingId,
      rating: params.rating,
      comment: params.comment,
    );
  }
}
