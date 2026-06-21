import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/collection/data/repositories/collection_repository.dart';
import 'package:localkart/feature/collection/domain/entities/collection_entity.dart';
import 'package:localkart/feature/collection/domain/repositories/collection_repository.dart';

class GetCollectionByIdParams extends Equatable {
  final String collectionId;

  const GetCollectionByIdParams({required this.collectionId});

  @override
  List<Object?> get props => [collectionId];
}

final getCollectionByIdUsecaseProvider = Provider<GetCollectionByIdUsecase>((ref) {
  final collectionRepository = ref.read(collectionRepositoryProvider);
  return GetCollectionByIdUsecase(collectionRepository: collectionRepository);
});

class GetCollectionByIdUsecase
    implements UseCaseWithParams<CollectionEntity, GetCollectionByIdParams> {
  final ICollectionRepository _collectionRepository;

  GetCollectionByIdUsecase({required ICollectionRepository collectionRepository})
      : _collectionRepository = collectionRepository;

  @override
  Future<Either<Failure, CollectionEntity>> call(GetCollectionByIdParams params) {
    return _collectionRepository.getCollectionById(params.collectionId);
  }
}
