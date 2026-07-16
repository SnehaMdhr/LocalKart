import 'package:localkart/feature/rating/domain/entities/rating_entity.dart';

class RatingApiModel {
  final String? ratingId;
  final String? orderId;
  final String? customerId;
  final String? vendorId;
  final String? shopId;
  final int rating;
  final String comment;
  final String? createdAt;
  final String? updatedAt;

  // Populated fields
  final String? customerName;
  final String? customerImageUrl;
  final String? orderNumber;

  RatingApiModel({
    this.ratingId,
    this.orderId,
    this.customerId,
    this.vendorId,
    this.shopId,
    this.rating = 0,
    this.comment = '',
    this.createdAt,
    this.updatedAt,
    this.customerName,
    this.customerImageUrl,
    this.orderNumber,
  });

  factory RatingApiModel.fromJson(Map<String, dynamic> json) {
    // Customer data can be populated or just an ID
    String? customerId;
    String? customerName;
    String? customerImageUrl;
    final customerRaw = json['customerId'];
    if (customerRaw is Map<String, dynamic>) {
      customerId = customerRaw['_id'] as String? ?? '';
      customerName = customerRaw['name'] as String?;
      customerImageUrl = customerRaw['imageUrl'] as String?;
    } else {
      customerId = customerRaw as String?;
    }

    // Order data can be populated
    String? orderNumber;
    final orderRaw = json['orderId'];
    if (orderRaw is Map<String, dynamic>) {
      orderNumber = orderRaw['orderNumber'] as String?;
    }

    return RatingApiModel(
      ratingId: json['_id'] as String? ?? json['id'] as String?,
      orderId: json['orderId'] is String ? json['orderId'] as String? : (json['orderId'] as Map<String, dynamic>?)?['_id'] as String?,
      customerId: customerId,
      vendorId: json['vendorId'] as String?,
      shopId: json['shopId'] as String?,
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String? ?? '',
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      customerName: customerName,
      customerImageUrl: customerImageUrl,
      orderNumber: orderNumber,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'customerId': customerId,
      'vendorId': vendorId,
      'shopId': shopId,
      'rating': rating,
      'comment': comment,
    };
  }

  RatingEntity toEntity() {
    return RatingEntity(
      ratingId: ratingId,
      orderId: orderId,
      customerId: customerId,
      vendorId: vendorId,
      shopId: shopId,
      rating: rating,
      comment: comment,
      createdAt: createdAt,
      updatedAt: updatedAt,
      customerName: customerName,
      customerImageUrl: customerImageUrl,
      orderNumber: orderNumber,
    );
  }

  static List<RatingEntity> toEntityList(List<RatingApiModel> models) {
    return models.map((m) => m.toEntity()).toList();
  }
}
