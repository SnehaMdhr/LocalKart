import 'package:localkart/feature/notification/domain/entities/notification_entity.dart';

class NotificationApiModel {
  final String? notificationId;
  final String receiverId;
  final String receiverRole;
  final String title;
  final String message;
  final String type;
  final String? orderId;
  final String? shopId;
  final String? orderNumber;
  final String? shopName;
  final bool isRead;
  final String? createdAt;
  final String? updatedAt;

  NotificationApiModel({
    this.notificationId,
    required this.receiverId,
    required this.receiverRole,
    required this.title,
    required this.message,
    required this.type,
    this.orderId,
    this.shopId,
    this.orderNumber,
    this.shopName,
    this.isRead = false,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationApiModel.fromJson(Map<String, dynamic> json) {
    return NotificationApiModel(
      notificationId: json['_id'] as String? ?? json['id'] as String?,
      receiverId: json['receiverId'] as String? ?? '',
      receiverRole: json['receiverRole'] as String? ?? 'Customer',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'SYSTEM',
      orderId: json['orderId'] as String?,
      shopId: json['shopId'] as String?,
      orderNumber: json['orderNumber'] as String?,
      shopName: json['shopName'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receiverId': receiverId,
      'receiverRole': receiverRole,
      'title': title,
      'message': message,
      'type': type,
      'orderId': orderId,
      'shopId': shopId,
      'orderNumber': orderNumber,
      'shopName': shopName,
      'isRead': isRead,
    };
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      notificationId: notificationId,
      receiverId: receiverId,
      receiverRole: receiverRole,
      title: title,
      message: message,
      type: type,
      orderId: orderId,
      shopId: shopId,
      orderNumber: orderNumber,
      shopName: shopName,
      isRead: isRead,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory NotificationApiModel.fromEntity(NotificationEntity entity) {
    return NotificationApiModel(
      notificationId: entity.notificationId,
      receiverId: entity.receiverId,
      receiverRole: entity.receiverRole,
      title: entity.title,
      message: entity.message,
      type: entity.type,
      orderId: entity.orderId,
      shopId: entity.shopId,
      orderNumber: entity.orderNumber,
      shopName: entity.shopName,
      isRead: entity.isRead,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static List<NotificationEntity> toEntityList(
    List<NotificationApiModel> models,
  ) {
    return models.map((m) => m.toEntity()).toList();
  }
}
