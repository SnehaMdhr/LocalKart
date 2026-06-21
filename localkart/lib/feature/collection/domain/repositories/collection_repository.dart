import 'package:dartz/dartz.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/feature/collection/domain/entities/collection_entity.dart';

abstract interface class ICollectionRepository {
  Future<Either<Failure, List<CollectionEntity>>> getAllCollections();
  Future<Either<Failure, CollectionEntity>> getCollectionById(String collectionId);
  Future<Either<Failure, CollectionEntity>> createCollection(String collectionName);
  Future<Either<Failure, void>> deleteCollection(String collectionId);
  Future<Either<Failure, CollectionEntity>> addProductToCollection(
    String collectionId,
    String productId,
  );
  Future<Either<Failure, CollectionEntity>> removeProductFromCollection(
    String collectionId,
    String productId,
  );
}
