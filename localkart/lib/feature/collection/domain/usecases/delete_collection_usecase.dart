import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/collection/data/repositories/collection_repository.dart';
import 'package:localkart/feature/collection/domain/repositories/collection_repository.dart';

class DeleteCollectionParams extends Equatable {
  final String collectionId;

  const DeleteCollectionParams({required this.collectionId});

  @override
  List<Object?> get props => [collectionId];
}

final deleteCollectionUsecaseProvider = Provider<DeleteCollectionUsecase>((ref) {
  final collectionRepository = ref.read(collectionRepositoryProvider);
  return DeleteCollectionUsecase(collectionRepository: collectionRepository);
});

class DeleteCollectionUsecase
    implements UseCaseWithParams<void, DeleteCollectionParams> {
  final ICollectionRepository _collectionRepository;

  DeleteCollectionUsecase({required ICollectionRepository collectionRepository})
      : _collectionRepository = collectionRepository;

  @override
  Future<Either<Failure, void>> call(DeleteCollectionParams params) {
    return _collectionRepository.deleteCollection(params.collectionId);
  }
}
