import 'package:localkart/feature/cart/data/models/cart_hive_model.dart';
import 'package:localkart/feature/cart/domain/entities/cart_entity.dart';

class CartItemApiModel {
  final String productId;
  final String? productName;
  final int? price;
  final String? imageUrl;
  final int quantity;

  CartItemApiModel({
    required this.productId,
    this.productName,
    this.price,
    this.imageUrl,
    this.quantity = 1,
  });

  factory CartItemApiModel.fromJson(Map<String, dynamic> json) {
    // productId can be a populated product object or just a string ID
    final productRaw = json['productId'];
    String productId;
    String? productName;
    int? price;
    String? imageUrl;

    if (productRaw is Map<String, dynamic>) {
      // Populated product object
      productId = productRaw['_id'] as String? ??
          productRaw['productId'] as String? ??
          productRaw['id'] as String? ??
          '';
      productName = productRaw['productName'] as String?;
      price = productRaw['price'] as int?;
      imageUrl = productRaw['imageUrl'] as String?;
    } else {
      productId = productRaw as String? ?? json['productId'] as String? ?? '';
    }

    return CartItemApiModel(
      productId: productId,
      productName: productName,
      price: price,
      imageUrl: imageUrl,
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }

  CartItemEntity toEntity() {
    return CartItemEntity(
      productId: productId,
      productName: productName,
      price: price,
      imageUrl: imageUrl,
      quantity: quantity,
    );
  }

  CartItemHiveModel toHiveModel() {
    return CartItemHiveModel(
      productId: productId,
      productName: productName,
      price: price,
      imageUrl: imageUrl,
      quantity: quantity,
    );
  }
}

class CartApiModel {
  final String? cartId;
  final String userId;
  final List<CartItemApiModel> items;

  CartApiModel({
    this.cartId,
    this.userId = '',
    this.items = const [],
  });

  factory CartApiModel.fromJson(Map<String, dynamic> json) {
    // userId can be a populated object or plain string
    final userIdRaw = json['userId'];
    final userId = userIdRaw is Map<String, dynamic>
        ? (userIdRaw['_id'] as String? ?? '')
        : (userIdRaw as String? ?? '');

    return CartApiModel(
      cartId: json['_id'] as String? ?? json['cartId'] as String?,
      userId: userId,
      items: (json['items'] as List<dynamic>?)
              ?.map(
                (e) => CartItemApiModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  factory CartApiModel.fromJsonWithData(Map<String, dynamic> json) {
    // For responses wrapped in { success: true, data: { ... } }
    final data = json['data'] as Map<String, dynamic>?;
    if (data != null) {
      return CartApiModel.fromJson(data);
    }
    return CartApiModel.fromJson(json);
  }

  Map<String, dynamic> toAddToCartJson() {
    return {};
  }

  CartEntity toEntity() {
    return CartEntity(
      cartId: cartId,
      userId: userId,
      items: items.map((e) => e.toEntity()).toList(),
    );
  }

  static List<CartEntity> toEntityList(List<CartApiModel> models) {
    return models.map((m) => m.toEntity()).toList();
  }

  CartHiveModel toHiveModel() {
    return CartHiveModel(
      cartId: cartId,
      userId: userId,
      items: items.map((e) => e.toHiveModel()).toList(),
    );
  }
}
