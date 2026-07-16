import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/rating/data/repositories/rating_repository.dart';
import 'package:localkart/feature/rating/domain/entities/rating_entity.dart';
import 'package:localkart/feature/rating/domain/repositories/rating_repository.dart';

class GetVendorRatingsParams extends Equatable {
  final String vendorId;

  const GetVendorRatingsParams({required this.vendorId});

  @override
  List<Object?> get props => [vendorId];
}

final getVendorRatingsUsecaseProvider =
    Provider<GetVendorRatingsUsecase>((ref) {
  final ratingRepository = ref.read(ratingRepositoryProvider);
  return GetVendorRatingsUsecase(ratingRepository: ratingRepository);
});

class GetVendorRatingsUsecase
    implements UseCaseWithParams<List<RatingEntity>, GetVendorRatingsParams> {
  final IRatingRepository _ratingRepository;

  GetVendorRatingsUsecase({required IRatingRepository ratingRepository})
      : _ratingRepository = ratingRepository;

  @override
  Future<Either<Failure, List<RatingEntity>>> call(
      GetVendorRatingsParams params) {
    return _ratingRepository.getVendorRatings(params.vendorId);
  }
}
