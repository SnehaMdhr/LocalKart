import 'package:localkart/feature/collection/data/models/collection_hive_model.dart';
import 'package:localkart/feature/collection/domain/entities/collection_entity.dart';

class CollectionApiModel {
  final String? collectionId;
  final String userId;
  final String collectionName;
  final List<String> productIds;

  CollectionApiModel({
    this.collectionId,
    this.userId = '',
    required this.collectionName,
    this.productIds = const [],
  });

  factory CollectionApiModel.fromJson(Map<String, dynamic> json) {
    // userId can be a populated object { _id, ... } or a plain string
    final userIdRaw = json['userId'];
    final userId = userIdRaw is Map<String, dynamic>
        ? (userIdRaw['_id'] as String? ?? '')
        : (userIdRaw as String? ?? '');

    return CollectionApiModel(
      collectionId: json["_id"] as String? ?? json["collectionId"] as String?,
      userId: userId,
      collectionName: json["collectionName"] as String? ?? "",
      productIds: (json["productIds"] as List<dynamic>?)
              ?.map((e) => e is Map<String, dynamic>
                  ? (e['_id'] as String? ?? '')
                  : (e as String? ?? ''))
              .toList() ??
          [],
    );
  }

  static List<CollectionApiModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => CollectionApiModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      "collectionName": collectionName,
    };
  }

  CollectionEntity toEntity() {
    return CollectionEntity(
      collectionId: collectionId,
      userId: userId,
      collectionName: collectionName,
      productIds: productIds,
    );
  }

  static List<CollectionEntity> toEntityList(List<CollectionApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }

  CollectionHiveModel toHiveModel() {
    return CollectionHiveModel(
      collectionId: collectionId,
      userId: userId,
      collectionName: collectionName,
      productIds: productIds,
    );
  }
}
