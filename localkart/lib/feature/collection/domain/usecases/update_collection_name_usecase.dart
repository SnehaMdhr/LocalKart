import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/collection/data/repositories/collection_repository.dart';
import 'package:localkart/feature/collection/domain/entities/collection_entity.dart';
import 'package:localkart/feature/collection/domain/repositories/collection_repository.dart';

class UpdateCollectionNameParams extends Equatable {
  final String collectionId;
  final String newName;

  const UpdateCollectionNameParams({
    required this.collectionId,
    required this.newName,
  });

  @override
  List<Object?> get props => [collectionId, newName];
}

final updateCollectionNameUsecaseProvider =
    Provider<UpdateCollectionNameUsecase>((ref) {
  final collectionRepository = ref.read(collectionRepositoryProvider);
  return UpdateCollectionNameUsecase(
      collectionRepository: collectionRepository);
});

class UpdateCollectionNameUsecase
    implements
        UseCaseWithParams<CollectionEntity, UpdateCollectionNameParams> {
  final ICollectionRepository _collectionRepository;

  UpdateCollectionNameUsecase({
    required ICollectionRepository collectionRepository,
  }) : _collectionRepository = collectionRepository;

  @override
  Future<Either<Failure, CollectionEntity>> call(
      UpdateCollectionNameParams params) {
    return _collectionRepository.updateCollectionName(
      params.collectionId,
      params.newName,
    );
  }
}
