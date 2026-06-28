import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/collection/data/repositories/collection_repository.dart';
import 'package:localkart/feature/collection/domain/entities/collection_entity.dart';
import 'package:localkart/feature/collection/domain/repositories/collection_repository.dart';

class CreateCollectionParams extends Equatable {
  final String collectionName;

  const CreateCollectionParams({required this.collectionName});

  @override
  List<Object?> get props => [collectionName];
}

final createCollectionUsecaseProvider = Provider<CreateCollectionUsecase>((ref) {
  final collectionRepository = ref.read(collectionRepositoryProvider);
  return CreateCollectionUsecase(collectionRepository: collectionRepository);
});

class CreateCollectionUsecase
    implements UseCaseWithParams<CollectionEntity, CreateCollectionParams> {
  final ICollectionRepository _collectionRepository;

  CreateCollectionUsecase({required ICollectionRepository collectionRepository})
      : _collectionRepository = collectionRepository;

  @override
  Future<Either<Failure, CollectionEntity>> call(CreateCollectionParams params) {
    return _collectionRepository.createCollection(params.collectionName);
  }
}
