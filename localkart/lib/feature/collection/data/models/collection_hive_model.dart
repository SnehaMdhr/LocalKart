import 'package:hive/hive.dart';
import 'package:localkart/core/constants/hive_table_constants.dart';
import 'package:localkart/feature/collection/domain/entities/collection_entity.dart';
import 'package:uuid/uuid.dart';

part 'collection_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.collectionTypeId)
class CollectionHiveModel extends HiveObject {
  @HiveField(0)
  final String collectionId;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String collectionName;

  @HiveField(3)
  final List<String> productIds;

  CollectionHiveModel({
    String? collectionId,
    this.userId = '',
    required this.collectionName,
    this.productIds = const [],
  }) : collectionId = collectionId ?? const Uuid().v4();

  factory CollectionHiveModel.fromEntity(CollectionEntity entity) {
    return CollectionHiveModel(
      collectionId: entity.collectionId,
      userId: entity.userId,
      collectionName: entity.collectionName,
      productIds: entity.productIds,
    );
  }

  CollectionEntity toEntity() {
    return CollectionEntity(
      collectionId: collectionId,
      userId: userId,
      collectionName: collectionName,
      productIds: productIds,
    );
  }

  static List<CollectionEntity> toEntityList(List<CollectionHiveModel> models) {
    return models.map((e) => e.toEntity()).toList();
  }
}
