import 'package:localkart/feature/collection/data/models/collection_api_model.dart';
import 'package:localkart/feature/collection/data/models/collection_hive_model.dart';

abstract interface class ICollectionLocalDatasource {
  Future<List<CollectionHiveModel>?> getAllCollections();
  Future<CollectionHiveModel?> getCollectionById(String collectionId);
  Future<void> cacheCollections(List<CollectionHiveModel> collections);
}

abstract interface class ICollectionRemoteDatasource {
  Future<List<CollectionApiModel>?> getAllCollections();
  Future<CollectionApiModel?> getCollectionById(String collectionId);
  Future<CollectionApiModel?> createCollection(String collectionName);
  Future<void> deleteCollection(String collectionId);
  Future<CollectionApiModel?> addProductToCollection(
    String collectionId,
    String productId,
  );
  Future<CollectionApiModel?> removeProductFromCollection(
    String collectionId,
    String productId,
  );
  Future<CollectionApiModel?> updateCollectionName(
    String collectionId,
    String newName,
  );
}
