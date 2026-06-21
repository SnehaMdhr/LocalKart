import 'package:localkart/feature/product/data/models/product_hive_model.dart';
import 'package:localkart/feature/product/domain/entities/product_entity.dart';

class ProductApiModel {
  final String? productId;
  final String productName;
  final int price;
  final String? description;
  final String categoryName;
  final String unit;
  final String? imageUrl;

  ProductApiModel({
    this.productId,
    required this.price,
    required this.productName,
    this.description,
    required this.categoryName,
    required this.unit,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    final payroll = {
      "productName": productName,
      "description": description,
      "categoryName": categoryName,
      "unit": unit,
      "price":price,
    };

    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      payroll["imageUrl"] = imageUrl;
    }
    return payroll;
  }

  factory ProductApiModel.fromJson(Map<String, dynamic> json) {
    return ProductApiModel(
      productId: json["productId"] as String? ?? json["_productId"] as String? ?? json["_id"] as String?,
      productName: json["productName"] as String? ?? "",
      description: json["description"] as String? ?? "",
      categoryName: json["categoryName"] as String? ?? "",
      unit: json["unit"] as String? ?? "",
      imageUrl: json["imageUrl"] as String? ?? "",
      price: json["price"] as int? ?? 0,
    );
  }

  ProductEntity toEntity() {
    return ProductEntity(
      productId: productId,
      productName: productName,
      description: description ?? "",
      categoryName: categoryName,
      unit: unit,
      price: price,
      imageUrl: imageUrl ?? "",
    );
  }

  factory ProductApiModel.fromEntity(ProductEntity entity) {
    return ProductApiModel(
      productId: entity.productId,
      productName: entity.productName,
      description: entity.description,
      categoryName: entity.categoryName,
      unit: entity.unit,
      imageUrl: entity.imageUrl,
      price: entity.price,
    );
  }

  static List<ProductEntity> toEntityList(List<ProductApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }

  static List<ProductApiModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => ProductApiModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  ProductHiveModel toHiveModel() {
    return ProductHiveModel(
      productId: productId,
      productName: productName,
      description: description,
      categoryName: categoryName,
      unit: unit,
      imageUrl: imageUrl,
      price: price,
    );
  }
}
