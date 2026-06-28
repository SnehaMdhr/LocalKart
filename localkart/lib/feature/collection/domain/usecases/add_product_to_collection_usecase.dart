import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/collection/data/repositories/collection_repository.dart';
import 'package:localkart/feature/collection/domain/entities/collection_entity.dart';
import 'package:localkart/feature/collection/domain/repositories/collection_repository.dart';

class AddProductToCollectionParams extends Equatable {
  final String collectionId;
  final String productId;

  const AddProductToCollectionParams({
    required this.collectionId,
    required this.productId,
  });

  @override
  List<Object?> get props => [collectionId, productId];
}

final addProductToCollectionUsecaseProvider =
    Provider<AddProductToCollectionUsecase>((ref) {
  final collectionRepository = ref.read(collectionRepositoryProvider);
  return AddProductToCollectionUsecase(
      collectionRepository: collectionRepository);
});

class AddProductToCollectionUsecase
    implements
        UseCaseWithParams<CollectionEntity, AddProductToCollectionParams> {
  final ICollectionRepository _collectionRepository;

  AddProductToCollectionUsecase({
    required ICollectionRepository collectionRepository,
  }) : _collectionRepository = collectionRepository;

  @override
  Future<Either<Failure, CollectionEntity>> call(
      AddProductToCollectionParams params) {
    return _collectionRepository.addProductToCollection(
      params.collectionId,
      params.productId,
    );
  }
}
