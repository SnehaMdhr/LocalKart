import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/collection/data/repositories/collection_repository.dart';
import 'package:localkart/feature/collection/domain/entities/collection_entity.dart';
import 'package:localkart/feature/collection/domain/repositories/collection_repository.dart';

class RemoveProductFromCollectionParams extends Equatable {
  final String collectionId;
  final String productId;

  const RemoveProductFromCollectionParams({
    required this.collectionId,
    required this.productId,
  });

  @override
  List<Object?> get props => [collectionId, productId];
}

final removeProductFromCollectionUsecaseProvider =
    Provider<RemoveProductFromCollectionUsecase>((ref) {
  final collectionRepository = ref.read(collectionRepositoryProvider);
  return RemoveProductFromCollectionUsecase(
      collectionRepository: collectionRepository);
});

class RemoveProductFromCollectionUsecase
    implements
        UseCaseWithParams<CollectionEntity,
            RemoveProductFromCollectionParams> {
  final ICollectionRepository _collectionRepository;

  RemoveProductFromCollectionUsecase({
    required ICollectionRepository collectionRepository,
  }) : _collectionRepository = collectionRepository;

  @override
  Future<Either<Failure, CollectionEntity>> call(
      RemoveProductFromCollectionParams params) {
    return _collectionRepository.removeProductFromCollection(
      params.collectionId,
      params.productId,
    );
  }
}
