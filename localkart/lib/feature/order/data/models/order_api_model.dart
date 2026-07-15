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

    // Fallback: read productName and price from the top-level item JSON
    // The order schema stores both directly on each item, so even if
    // the product is deleted and populate() returns just the ObjectId string,
    // the values are still available from when the order was created.
    productName ??= json['productName'] as String?;
    price ??= json['price'] as int?;

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
  final String? orderNumber;
  final List<OrderItemApiModel> items;
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

  // Customer details (from populated customerId)
  final String? customerName;
  final String? customerAddress;
  final String? customerPhone;

  // Vendor/shop details (from populated shopId)
  final String? vendorName;
  final String? shopName;
  final String? shopAddress;
  final String? shopPhone;

  OrderApiModel({
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
    this.customerName,
    this.customerAddress,
    this.customerPhone,
    this.vendorName,
    this.shopName,
    this.shopAddress,
    this.shopPhone,
  });

  factory OrderApiModel.fromJson(Map<String, dynamic> json) {
    // customerId can be a populated object or plain string
    final customerRaw = json['customerId'];
    String? customerId;
    String? customerName;
    String? customerAddress;
    String? customerPhone;
    if (customerRaw is Map<String, dynamic>) {
      customerId = customerRaw['_id'] as String? ?? '';
      customerName = customerRaw['name'] as String?;
      customerAddress = customerRaw['address'] as String?;
      customerPhone = customerRaw['phone'] as String?;
    } else {
      customerId = customerRaw as String? ?? '';
    }

    // shopId can be a populated object or plain string or null
    final shopRaw = json['shopId'];
    String? shopId;
    String? vendorName;
    if (shopRaw is Map<String, dynamic>) {
      shopId = shopRaw['_id'] as String?;
      vendorName = shopRaw['name'] as String?;
    } else {
      shopId = shopRaw as String?;
    }

    // Parse shopDetails object (added by backend controller)
    String? shopName;
    String? shopAddress;
    final shopDetailsRaw = json['shopDetails'];
    if (shopDetailsRaw is Map<String, dynamic>) {
      shopName = shopDetailsRaw['shopName'] as String?;
      shopAddress = shopDetailsRaw['address'] as String?;
    }
    // Get shop phone from the populated shopId User object
    final shopPhone = shopRaw is Map<String, dynamic>
        ? (shopRaw['phone'] as String?)
        : null;

    // Parse structured deliveryAddress object
    final deliveryRaw = json['deliveryAddress'];
    String deliveryAddress = '';
    double? latitude;
    double? longitude;
    if (deliveryRaw is Map<String, dynamic>) {
      deliveryAddress = deliveryRaw['fullAddress'] as String? ?? '';
      latitude = (deliveryRaw['latitude'] as num?)?.toDouble();
      longitude = (deliveryRaw['longitude'] as num?)?.toDouble();
    } else {
      deliveryAddress = deliveryRaw as String? ?? '';
    }

    return OrderApiModel(
      orderId: json['_id'] as String? ?? json['orderId'] as String?,
      customerId: customerId,
      shopId: shopId,
      orderNumber: json['orderNumber'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map(
                (e) => OrderItemApiModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      totalAmount: json['totalAmount'] as int? ?? 0,
      deliveryAddress: deliveryAddress,
      latitude: latitude,
      longitude: longitude,
      paymentMethod: json['paymentMethod'] as String? ?? 'Cash on Delivery',
      paymentStatus: json['paymentStatus'] as String? ?? 'Pending',
      status: json['status'] as String? ?? 'Pending',
      customerNote: json['customerNote'] as String?,
      estimatedDeliveryTime: json['estimatedDeliveryTime'] as int?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      customerName: customerName,
      customerAddress: customerAddress,
      customerPhone: customerPhone,
      vendorName: vendorName,
      shopName: shopName,
      shopAddress: shopAddress,
      shopPhone: shopPhone,
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
      orderNumber: orderNumber,
      items: items.map((e) => e.toEntity()).toList(),
      totalAmount: totalAmount,
      deliveryAddress: deliveryAddress,
      latitude: latitude,
      longitude: longitude,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      status: status,
      customerNote: customerNote,
      estimatedDeliveryTime: estimatedDeliveryTime,
      createdAt: createdAt,
      updatedAt: updatedAt,
      customerName: customerName,
      customerAddress: customerAddress,
      customerPhone: customerPhone,
      vendorName: vendorName,
      shopName: shopName,
      shopAddress: shopAddress,
      shopPhone: shopPhone,
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
      orderNumber: orderNumber,
      items: items.map((e) => e.toHiveModel()).toList(),
      totalAmount: totalAmount,
      deliveryAddress: deliveryAddress,
      latitude: latitude,
      longitude: longitude,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      status: status,
      customerNote: customerNote,
      estimatedDeliveryTime: estimatedDeliveryTime,
      createdAt: createdAt,
      updatedAt: updatedAt,
      customerName: customerName,
      customerAddress: customerAddress,
      customerPhone: customerPhone,
      vendorName: vendorName,
      shopName: shopName,
      shopAddress: shopAddress,
      shopPhone: shopPhone,
    );
  }
}
