import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/rating/data/repositories/rating_repository.dart';
import 'package:localkart/feature/rating/domain/entities/rating_entity.dart';
import 'package:localkart/feature/rating/domain/repositories/rating_repository.dart';

class CreateRatingParams extends Equatable {
  final String orderId;
  final int rating;
  final String? comment;

  const CreateRatingParams({
    required this.orderId,
    required this.rating,
    this.comment,
  });

  @override
  List<Object?> get props => [orderId, rating, comment];
}

final createRatingUsecaseProvider = Provider<CreateRatingUsecase>((ref) {
  final ratingRepository = ref.read(ratingRepositoryProvider);
  return CreateRatingUsecase(ratingRepository: ratingRepository);
});

class CreateRatingUsecase
    implements UseCaseWithParams<RatingEntity, CreateRatingParams> {
  final IRatingRepository _ratingRepository;

  CreateRatingUsecase({required IRatingRepository ratingRepository})
      : _ratingRepository = ratingRepository;

  @override
  Future<Either<Failure, RatingEntity>> call(CreateRatingParams params) {
    return _ratingRepository.createRating(
      orderId: params.orderId,
      rating: params.rating,
      comment: params.comment,
    );
  }
}
