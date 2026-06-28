import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';

enum ProductStatus { initial, loading, loaded, error }

class ProductState extends Equatable {
  final ProductStatus status;
  final List<ProductEntity> products;
  final ProductEntity? selectedProduct;
  final String? errorMessage;
  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.selectedProduct,
    this.errorMessage,
  });

  ProductState copyWith({
    ProductStatus? status,
    List<ProductEntity>? products,
    ProductEntity? selectedProduct,
    String? errorMessage,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, products, selectedProduct, errorMessage];
}
