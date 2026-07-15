import 'package:hive/hive.dart';
import 'package:localkart/core/constants/hive_table_constants.dart';
import 'package:localkart/feature/order/domain/entities/order_entity.dart';
import 'package:uuid/uuid.dart';

part 'order_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.orderTypeId)
class OrderHiveModel extends HiveObject {
  @HiveField(0)
  final String orderId;

  @HiveField(1)
  final String? customerId;

  @HiveField(2)
  final String? shopId;

  @HiveField(3)
  final List<OrderItemHiveModel> items;

  @HiveField(4)
  final int totalAmount;

  @HiveField(5)
  final String deliveryAddress;

  @HiveField(6)
  final String paymentMethod;

  @HiveField(7)
  final String paymentStatus;

  @HiveField(8)
  final String status;

  @HiveField(9)
  final String? createdAt;

  @HiveField(10)
  final String? updatedAt;

  @HiveField(11)
  final String? orderNumber;

  @HiveField(12)
  final double? latitude;

  @HiveField(13)
  final double? longitude;

  @HiveField(14)
  final String? customerNote;

  @HiveField(15)
  final int? estimatedDeliveryTime;

  @HiveField(16)
  final String? customerName;

  @HiveField(17)
  final String? customerAddress;

  @HiveField(18)
  final String? customerPhone;

  @HiveField(19)
  final String? vendorName;

  @HiveField(20)
  final String? shopName;

  @HiveField(21)
  final String? shopAddress;

  @HiveField(22)
  final String? shopPhone;

  OrderHiveModel({
    String? orderId,
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
  }) : orderId = orderId ?? const Uuid().v4();

  factory OrderHiveModel.fromEntity(OrderEntity entity) {
    return OrderHiveModel(
      orderId: entity.orderId,
      customerId: entity.customerId,
      shopId: entity.shopId,
      orderNumber: entity.orderNumber,
      items: entity.items.map((e) => OrderItemHiveModel.fromEntity(e)).toList(),
      totalAmount: entity.totalAmount,
      deliveryAddress: entity.deliveryAddress,
      latitude: entity.latitude,
      longitude: entity.longitude,
      paymentMethod: entity.paymentMethod,
      paymentStatus: entity.paymentStatus,
      status: entity.status,
      customerNote: entity.customerNote,
      estimatedDeliveryTime: entity.estimatedDeliveryTime,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      customerName: entity.customerName,
      customerAddress: entity.customerAddress,
      customerPhone: entity.customerPhone,
      vendorName: entity.vendorName,
      shopName: entity.shopName,
      shopAddress: entity.shopAddress,
      shopPhone: entity.shopPhone,
    );
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

  static List<OrderEntity> toEntityList(List<OrderHiveModel> models) {
    return models.map((e) => e.toEntity()).toList();
  }
}

@HiveType(typeId: HiveTableConstant.orderItemTypeId)
class OrderItemHiveModel extends HiveObject {
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

  OrderItemHiveModel({
    required this.productId,
    this.productName,
    this.price,
    this.imageUrl,
    this.quantity = 1,
  });

  factory OrderItemHiveModel.fromEntity(OrderItemEntity entity) {
    return OrderItemHiveModel(
      productId: entity.productId,
      productName: entity.productName,
      price: entity.price,
      imageUrl: entity.imageUrl,
      quantity: entity.quantity,
    );
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
}
