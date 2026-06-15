import 'package:equatable/equatable.dart';

class ShopEntity extends Equatable {
  final String? shopId;
  final String? userId;
  final String shopName;
  final String address;
  final String description;
  final List<String> categories;
  final String? imageUrl;
  final String? status;

  const ShopEntity({
    this.shopId,
    this.userId,
    required this.shopName,
    required this.address,
    required this.description,
    required this.categories,
    this.imageUrl,
    this.status,
  });

  @override
  List<Object?> get props => [
        shopId,
        userId,
        shopName,
        address,
        description,
        categories,
        imageUrl,
        status,
      ];
}
