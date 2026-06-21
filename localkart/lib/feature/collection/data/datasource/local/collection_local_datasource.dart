import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/services/hive/hive.service.dart';
import 'package:localkart/feature/collection/data/datasource/collection_datasource.dart';
import 'package:localkart/feature/collection/data/models/collection_hive_model.dart';

final collectionLocalDatasourceProvider = Provider<ICollectionLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return CollectionLocalDatasource(hiveService: hiveService);
});

class CollectionLocalDatasource implements ICollectionLocalDatasource {
  final HiveService _hiveService;

  CollectionLocalDatasource({required HiveService hiveService})
      : _hiveService = hiveService;

  @override
  Future<List<CollectionHiveModel>?> getAllCollections() async {
    try {
      final collections = await _hiveService.getAllCollections();
      if (collections.isEmpty) return null;
      return collections;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<CollectionHiveModel?> getCollectionById(String collectionId) async {
    try {
      return await _hiveService.getCollectionById(collectionId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheCollections(List<CollectionHiveModel> collections) async {
    try {
      await _hiveService.cacheCollections(collections);
    } catch (e) {
      rethrow;
    }
  }
}
