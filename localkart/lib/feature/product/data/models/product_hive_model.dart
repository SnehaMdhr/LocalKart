import 'package:hive/hive.dart';
import 'package:localkart/core/constants/hive_table_constants.dart';
import 'package:localkart/feature/product/domain/entities/product_entity.dart';
import 'package:uuid/uuid.dart';
part 'product_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.productTypeId)
class ProductHiveModel extends HiveObject {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String categoryName;

  @HiveField(4)
  final String? imageUrl;

  @HiveField(5)
  final String unit;
  ProductHiveModel({
    String? productId,
    required this.productName,
    this.description,
    required this.categoryName,
    this.imageUrl,
    required this.unit,
  }) : productId = productId ?? const Uuid().v4();

  factory ProductHiveModel.fromEntity(ProductEntity entity) {
    return ProductHiveModel(
      productId: entity.productId,
      productName: entity.productName,
      description: entity.description,
      categoryName: entity.categoryName,
      unit: entity.unit,
      imageUrl: entity.imageUrl,
    );
  }

  /// Hive → Entity
  ProductEntity toEntity() {
    return ProductEntity(
      productId: productId,
      productName: productName,
      description: description ?? "",
      categoryName: categoryName,
      unit: unit,
      imageUrl: imageUrl ?? "",
    );
  }

  static List<ProductEntity> toEntityList(List<ProductHiveModel> models) {
    return models.map((e) => e.toEntity()).toList();
  }
}
