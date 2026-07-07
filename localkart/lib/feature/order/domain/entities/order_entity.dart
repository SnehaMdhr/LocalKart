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
  final String? orderNumber;
  final List<OrderItemEntity> items;
  final int totalAmount;
  final String deliveryAddress;
  final double? latitude;
  final double? longitude;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final String? customerNote;
  final int? estimatedDeliveryTime;
  final String? createdAt;
  final String? updatedAt;

  const OrderEntity({
    this.orderId,
    this.customerId,
    this.shopId,
    this.orderNumber,
    this.items = const [],
    this.totalAmount = 0,
    this.deliveryAddress = '',
    this.latitude,
    this.longitude,
    this.paymentMethod = 'Cash on Delivery',
    this.paymentStatus = 'Pending',
    this.status = 'Pending',
    this.customerNote,
    this.estimatedDeliveryTime,
    this.createdAt,
    this.updatedAt,
  });

  OrderEntity copyWith({
    String? orderId,
    String? customerId,
    String? shopId,
    String? orderNumber,
    List<OrderItemEntity>? items,
    int? totalAmount,
    String? deliveryAddress,
    double? latitude,
    double? longitude,
    String? paymentMethod,
    String? paymentStatus,
    String? status,
    String? customerNote,
    int? estimatedDeliveryTime,
    String? createdAt,
    String? updatedAt,
  }) {
    return OrderEntity(
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      shopId: shopId ?? this.shopId,
      orderNumber: orderNumber ?? this.orderNumber,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      customerNote: customerNote ?? this.customerNote,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    orderId,
    customerId,
    shopId,
    orderNumber,
    items,
    totalAmount,
    deliveryAddress,
    latitude,
    longitude,
    paymentMethod,
    paymentStatus,
    status,
    customerNote,
    estimatedDeliveryTime,
    createdAt,
    updatedAt,
  ];
}
