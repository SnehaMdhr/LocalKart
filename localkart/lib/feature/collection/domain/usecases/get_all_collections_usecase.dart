import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/collection/data/repositories/collection_repository.dart';
import 'package:localkart/feature/collection/domain/entities/collection_entity.dart';
import 'package:localkart/feature/collection/domain/repositories/collection_repository.dart';

final getAllCollectionsUsecaseProvider = Provider<GetAllCollectionsUsecase>((ref) {
  final collectionRepository = ref.read(collectionRepositoryProvider);
  return GetAllCollectionsUsecase(collectionRepository: collectionRepository);
});

class GetAllCollectionsUsecase
    implements UsecaseWithoutParams<List<CollectionEntity>> {
  final ICollectionRepository _collectionRepository;

  GetAllCollectionsUsecase({required ICollectionRepository collectionRepository})
      : _collectionRepository = collectionRepository;

  @override
  Future<Either<Failure, List<CollectionEntity>>> call() {
    return _collectionRepository.getAllCollections();
  }
}
