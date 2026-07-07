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

  OrderHiveModel({
    String? orderId,
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
  }) : orderId = orderId ?? const Uuid().v4();

  factory OrderHiveModel.fromEntity(OrderEntity entity) {
    return OrderHiveModel(
      orderId: entity.orderId,
      customerId: entity.customerId,
      shopId: entity.shopId,
      items: entity.items.map((e) => OrderItemHiveModel.fromEntity(e)).toList(),
      totalAmount: entity.totalAmount,
      deliveryAddress: entity.deliveryAddress,
      paymentMethod: entity.paymentMethod,
      paymentStatus: entity.paymentStatus,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
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
