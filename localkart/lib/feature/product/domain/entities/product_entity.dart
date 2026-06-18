import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String? productId;
  final String productName;
  final String? description;
  final String categoryName;
  final String? imageUrl;
  final String unit;
  final int price;

  const ProductEntity({
    this.productId,
    required this.productName,
    this.description,
    required this.categoryName,
    this.imageUrl,
    required this.price,
    required this.unit,
  });

  @override
  List<Object?> get props => [
    productId,
    productName,
    description,
    categoryName,
    price,
    imageUrl,
    unit,
  ];
}
