import 'package:localkart/feature/order/data/models/order_hive_model.dart';
import 'package:localkart/feature/order/domain/entities/order_entity.dart';

class OrderItemApiModel {
  final String productId;
  final String? productName;
  final int? price;
  final String? imageUrl;
  final int quantity;

  OrderItemApiModel({
    required this.productId,
    this.productName,
    this.price,
    this.imageUrl,
    this.quantity = 1,
  });

  factory OrderItemApiModel.fromJson(Map<String, dynamic> json) {
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

    return OrderItemApiModel(
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

  OrderItemEntity toEntity() {
    return OrderItemEntity(
      productId: productId,
      productName: productName,
      price: price,
      imageUrl: imageUrl,
      quantity: quantity,
    );
  }

  OrderItemHiveModel toHiveModel() {
    return OrderItemHiveModel(
      productId: productId,
      productName: productName,
      price: price,
      imageUrl: imageUrl,
      quantity: quantity,
    );
  }
}

class OrderApiModel {
  final String? orderId;
  final String? customerId;
  final String? shopId;
  final List<OrderItemApiModel> items;
  final int totalAmount;
  final String deliveryAddress;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  OrderApiModel({
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

  factory OrderApiModel.fromJson(Map<String, dynamic> json) {
    // customerId can be a populated object or plain string
    final customerRaw = json['customerId'];
    final customerId = customerRaw is Map<String, dynamic>
        ? (customerRaw['_id'] as String? ?? '')
        : (customerRaw as String? ?? '');

    // shopId can be a populated object or plain string or null
    final shopRaw = json['shopId'];
    String? shopId;
    if (shopRaw is Map<String, dynamic>) {
      shopId = shopRaw['_id'] as String?;
    } else {
      shopId = shopRaw as String?;
    }

    return OrderApiModel(
      orderId: json['_id'] as String? ?? json['orderId'] as String?,
      customerId: customerId,
      shopId: shopId,
      items: (json['items'] as List<dynamic>?)
              ?.map(
                (e) => OrderItemApiModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      totalAmount: json['totalAmount'] as int? ?? 0,
      deliveryAddress: json['deliveryAddress'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? 'Cash on Delivery',
      paymentStatus: json['paymentStatus'] as String? ?? 'Pending',
      status: json['status'] as String? ?? 'Pending',
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  factory OrderApiModel.fromJsonWithData(Map<String, dynamic> json) {
    // For responses wrapped in { success: true, data: { ... } }
    final data = json['data'] as Map<String, dynamic>?;
    if (data != null) {
      return OrderApiModel.fromJson(data);
    }
    return OrderApiModel.fromJson(json);
  }

  OrderEntity toEntity() {
    return OrderEntity(
      orderId: orderId,
      customerId: customerId,
      shopId: shopId,
      items: items.map((e) => e.toEntity()).toList(),
      totalAmount: totalAmount,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static List<OrderEntity> toEntityList(List<OrderApiModel> models) {
    return models.map((m) => m.toEntity()).toList();
  }

  OrderHiveModel toHiveModel() {
    return OrderHiveModel(
      orderId: orderId,
      customerId: customerId,
      shopId: shopId,
      items: items.map((e) => e.toHiveModel()).toList(),
      totalAmount: totalAmount,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
