import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
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

  const NotificationEntity({
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

  NotificationEntity copyWith({
    String? notificationId,
    String? receiverId,
    String? receiverRole,
    String? title,
    String? message,
    String? type,
    String? orderId,
    String? shopId,
    String? orderNumber,
    String? shopName,
    bool? isRead,
    String? createdAt,
    String? updatedAt,
  }) {
    return NotificationEntity(
      notificationId: notificationId ?? this.notificationId,
      receiverId: receiverId ?? this.receiverId,
      receiverRole: receiverRole ?? this.receiverRole,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      orderId: orderId ?? this.orderId,
      shopId: shopId ?? this.shopId,
      orderNumber: orderNumber ?? this.orderNumber,
      shopName: shopName ?? this.shopName,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    notificationId,
    receiverId,
    receiverRole,
    title,
    message,
    type,
    orderId,
    shopId,
    orderNumber,
    shopName,
    isRead,
    createdAt,
    updatedAt,
  ];
}
