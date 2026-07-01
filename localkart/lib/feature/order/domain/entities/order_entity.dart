import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final String productId;
  final String? productName;
  final int? price;
  final String? imageUrl;
  final int quantity;

  const OrderItemEntity({
    required this.productId,
    this.productName,
    this.price,
    this.imageUrl,
    this.quantity = 1,
  });

  OrderItemEntity copyWith({
    String? productId,
    String? productName,
    int? price,
    String? imageUrl,
    int? quantity,
  }) {
    return OrderItemEntity(
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

class OrderEntity extends Equatable {
  final String? orderId;
  final String? customerId;
  final String? shopId;
  final List<OrderItemEntity> items;
  final int totalAmount;
  final String deliveryAddress;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  const OrderEntity({
    this.orderId,
    this.customerId,
    this.shopId,
    this.items = const [],
    this.totalAmount = 0,
    this.deliveryAddress = '',
    this.paymentMethod = 'Cash on Delivery',
    this.paymentStatus = 'Pending',
    this.status = 'Pending',
    this.createdAt,
    this.updatedAt,
  });

  OrderEntity copyWith({
    String? orderId,
    String? customerId,
    String? shopId,
    List<OrderItemEntity>? items,
    int? totalAmount,
    String? deliveryAddress,
    String? paymentMethod,
    String? paymentStatus,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return OrderEntity(
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      shopId: shopId ?? this.shopId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    orderId,
    customerId,
    shopId,
    items,
    totalAmount,
    deliveryAddress,
    paymentMethod,
    paymentStatus,
    status,
    createdAt,
    updatedAt,
  ];
}
