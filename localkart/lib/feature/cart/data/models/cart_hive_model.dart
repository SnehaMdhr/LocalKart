import 'package:hive/hive.dart';
import 'package:localkart/core/constants/hive_table_constants.dart';
import 'package:localkart/feature/cart/domain/entities/cart_entity.dart';
import 'package:uuid/uuid.dart';

part 'cart_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.cartTypeId)
class CartHiveModel extends HiveObject {
  @HiveField(0)
  final String cartId;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final List<CartItemHiveModel> items;

  CartHiveModel({
    String? cartId,
    this.userId = '',
    this.items = const [],
  }) : cartId = cartId ?? const Uuid().v4();

  factory CartHiveModel.fromEntity(CartEntity entity) {
    return CartHiveModel(
      cartId: entity.cartId,
      userId: entity.userId,
      items: entity.items.map((e) => CartItemHiveModel.fromEntity(e)).toList(),
    );
  }

  CartEntity toEntity() {
    return CartEntity(
      cartId: cartId,
      userId: userId,
      items: items.map((e) => e.toEntity()).toList(),
    );
  }

  static List<CartEntity> toEntityList(List<CartHiveModel> models) {
    return models.map((e) => e.toEntity()).toList();
  }
}

@HiveType(typeId: HiveTableConstant.cartTypeId + 1)
class CartItemHiveModel extends HiveObject {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String? productName;

  @HiveField(2)
  final int? price;

  @HiveField(3)
  final String? imageUrl;

  @HiveField(4)
  final int quantity;

  CartItemHiveModel({
    required this.productId,
    this.productName,
    this.price,
    this.imageUrl,
    this.quantity = 1,
  });

  factory CartItemHiveModel.fromEntity(CartItemEntity entity) {
    return CartItemHiveModel(
      productId: entity.productId,
      productName: entity.productName,
      price: entity.price,
      imageUrl: entity.imageUrl,
      quantity: entity.quantity,
    );
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
}
