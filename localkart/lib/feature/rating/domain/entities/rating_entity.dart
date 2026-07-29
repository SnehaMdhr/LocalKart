import 'package:equatable/equatable.dart';

class RatingEntity extends Equatable {
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

  const RatingEntity({
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

  RatingEntity copyWith({
    String? ratingId,
    String? orderId,
    String? customerId,
    String? vendorId,
    String? shopId,
    int? rating,
    String? comment,
    String? createdAt,
    String? updatedAt,
    String? customerName,
    String? customerImageUrl,
    String? orderNumber,
  }) {
    return RatingEntity(
      ratingId: ratingId ?? this.ratingId,
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      vendorId: vendorId ?? this.vendorId,
      shopId: shopId ?? this.shopId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customerName: customerName ?? this.customerName,
      customerImageUrl: customerImageUrl ?? this.customerImageUrl,
      orderNumber: orderNumber ?? this.orderNumber,
    );
  }

  @override
  List<Object?> get props => [
    ratingId,
    orderId,
    customerId,
    vendorId,
    shopId,
    rating,
    comment,
    createdAt,
    updatedAt,
    customerName,
    customerImageUrl,
    orderNumber,
  ];
}
