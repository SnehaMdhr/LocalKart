import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/api/api_client.dart';
import 'package:localkart/core/api/api_endpoints.dart';
import 'package:localkart/feature/collection/data/datasource/collection_datasource.dart';
import 'package:localkart/feature/collection/data/models/collection_api_model.dart';

final collectionRemoteDatasourceProvider =
    Provider<ICollectionRemoteDatasource>((ref) {
  return CollectionRemoteDatasource(apiclient: ref.read(apiClientProvider));
});

class CollectionRemoteDatasource implements ICollectionRemoteDatasource {
  final ApiClient _apiClient;

  CollectionRemoteDatasource({required ApiClient apiclient})
      : _apiClient = apiclient;

  @override
  Future<List<CollectionApiModel>?> getAllCollections() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getMyCollections);

      final responseMap = response.data as Map<String, dynamic>?;
      if (responseMap == null) return null;

      final dataList = responseMap['data'] as List?;
      if (dataList == null) return null;

      return CollectionApiModel.fromJsonList(dataList);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CollectionApiModel?> getCollectionById(String collectionId) async {
    try {
      final path =
          ApiEndpoints.getCollectionById.replaceAll(':id', collectionId);
      final response = await _apiClient.get(path);

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) return null;

      final data = responseData['data'] as Map<String, dynamic>?;
      if (data == null) return null;

      return CollectionApiModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CollectionApiModel?> createCollection(String collectionName) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.createCollection,
        data: {"collectionName": collectionName},
      );

      final data = response.data as Map<String, dynamic>?;
      if (data == null) return null;

      final collectionData = data['data'] as Map<String, dynamic>?;
      if (collectionData == null) return null;

      return CollectionApiModel.fromJson(collectionData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteCollection(String collectionId) async {
    try {
      final path =
          ApiEndpoints.deleteCollection.replaceAll(':id', collectionId);
      await _apiClient.delete(path);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CollectionApiModel?> addProductToCollection(
    String collectionId,
    String productId,
  ) async {
    try {
      final path = ApiEndpoints.addProductToCollection
          .replaceAll(':id', collectionId);
      final response = await _apiClient.post(
        path,
        data: {"productId": productId},
      );

      final data = response.data as Map<String, dynamic>?;
      if (data == null) return null;

      final collectionData = data['data'] as Map<String, dynamic>?;
      if (collectionData == null) return null;

      return CollectionApiModel.fromJson(collectionData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CollectionApiModel?> removeProductFromCollection(
    String collectionId,
    String productId,
  ) async {
    try {
      final path = ApiEndpoints.removeProductFromCollection
          .replaceAll(':id', collectionId);
      final response = await _apiClient.delete(
        path,
        data: {"productId": productId},
      );

      final data = response.data as Map<String, dynamic>?;
      if (data == null) return null;

      final collectionData = data['data'] as Map<String, dynamic>?;
      if (collectionData == null) return null;

      return CollectionApiModel.fromJson(collectionData);
    } catch (e) {
      rethrow;
    }
  }
}
