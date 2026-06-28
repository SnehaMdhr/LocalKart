import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final String productId;
  final String? productName;
  final int? price;
  final String? imageUrl;
  final int quantity;

  const CartItemEntity({
    required this.productId,
    this.productName,
    this.price,
    this.imageUrl,
    this.quantity = 1,
  });

  CartItemEntity copyWith({
    String? productId,
    String? productName,
    int? price,
    String? imageUrl,
    int? quantity,
  }) {
    return CartItemEntity(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [productId, productName, price, imageUrl, quantity];
}

class CartEntity extends Equatable {
  final String? cartId;
  final String userId;
  final List<CartItemEntity> items;

  const CartEntity({
    this.cartId,
    this.userId = '',
    this.items = const [],
  });

  CartEntity copyWith({
    String? cartId,
    String? userId,
    List<CartItemEntity>? items,
  }) {
    return CartEntity(
      cartId: cartId ?? this.cartId,
      userId: userId ?? this.userId,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [cartId, userId, items];
}
