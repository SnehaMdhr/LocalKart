import 'package:hive/hive.dart';
import 'package:localkart/core/constants/hive_table_constants.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/shop_entity.dart';
part 'shop_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.shopTypeId)
class ShopHiveModel extends HiveObject {
  @HiveField(0)
  final String shopId;

  @HiveField(1)
  final String? userId;

  @HiveField(2)
  final String shopName;

  @HiveField(3)
  final String address;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final List<String> categories;

  @HiveField(6)
  final String? imageUrl;

  @HiveField(7)
  final String? status;

  ShopHiveModel({
    String? shopId,
    this.userId,
    required this.shopName,
    required this.address,
    required this.description,
    required this.categories,
    this.imageUrl,
    this.status,
  }) : shopId = shopId ?? const Uuid().v4();

  /// Entity → Hive
  factory ShopHiveModel.fromEntity(ShopEntity entity) {
    return ShopHiveModel(
      shopId: entity.shopId,
      userId: entity.userId,
      shopName: entity.shopName,
      address: entity.address,
      description: entity.description,
      categories: entity.categories,
      imageUrl: entity.imageUrl,
      status: entity.status,
    );
  }

  /// Hive → Entity
  ShopEntity toEntity() {
    return ShopEntity(
      shopId: shopId,
      userId: userId,
      shopName: shopName,
      address: address,
      description: description,
      categories: categories,
      imageUrl: imageUrl,
      status: status,
    );
  }

  static List<ShopEntity> toEntityList(List<ShopHiveModel> models) {
    return models.map((e) => e.toEntity()).toList();
  }
}
