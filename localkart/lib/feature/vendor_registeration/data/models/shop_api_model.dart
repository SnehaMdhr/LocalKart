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
  final double? latitude;
  final double? longitude;

  ShopApiModel({
    this.id,
    this.userId,
    required this.shopName,
    required this.address,
    required this.description,
    required this.categories,
    this.imageUrl,
    this.status,
    this.latitude,
    this.longitude,
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

    if (latitude != null) {
      payload["latitude"] = latitude;
    }

    if (longitude != null) {
      payload["longitude"] = longitude;
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
      latitude: (json["latitude"] as num?)?.toDouble(),
      longitude: (json["longitude"] as num?)?.toDouble(),
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
      latitude: latitude,
      longitude: longitude,
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
      latitude: entity.latitude,
      longitude: entity.longitude,
    );
  }

  // toEntityList
  static List<ShopEntity> toEntityList(List<ShopApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
