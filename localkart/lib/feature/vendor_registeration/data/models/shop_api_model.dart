import 'package:localkart/feature/vendor_registeration/domain/entities/shop_entity.dart';

class ShopApiModel {
  final String? id;
  final String? userId;
  final String shopName;
  final String address;
  final String description;
  final List<String> categories;
  final String? imageUrl;
  final String? status;

  ShopApiModel({
    this.id,
    this.userId,
    required this.shopName,
    required this.address,
    required this.description,
    required this.categories,
    this.imageUrl,
    this.status,
  });

  // toJson
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> payload = {
      "shopName": shopName,
      "address": address,
      "description": description,
      "categories": categories,
    };

    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      payload["imageUrl"] = imageUrl;
    }

    return payload;
  }

  // fromJson
  factory ShopApiModel.fromJson(Map<String, dynamic> json) {
    return ShopApiModel(
      id: json["_id"] as String? ?? json["id"] as String?,
      userId: json["userId"] as String?,
      shopName: json["shopName"] as String? ?? "",
      address: json["address"] as String? ?? "",
      description: json["description"] as String? ?? "",
      categories: (json["categories"] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      imageUrl: json["imageUrl"] as String?,
      status: json["status"] as String?,
    );
  }

  // toEntity
  ShopEntity toEntity() {
    return ShopEntity(
      shopId: id,
      userId: userId,
      shopName: shopName,
      address: address,
      description: description,
      categories: categories,
      imageUrl: imageUrl,
      status: status,
    );
  }

  // fromEntity
  factory ShopApiModel.fromEntity(ShopEntity entity) {
    return ShopApiModel(
      shopName: entity.shopName,
      address: entity.address,
      description: entity.description,
      categories: entity.categories,
      imageUrl: entity.imageUrl,
    );
  }

  // toEntityList
  static List<ShopEntity> toEntityList(List<ShopApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
