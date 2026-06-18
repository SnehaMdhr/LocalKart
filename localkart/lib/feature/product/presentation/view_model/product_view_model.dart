import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/feature/product/domain/usecases/get_all_products_usecase.dart';
import 'package:localkart/feature/product/domain/usecases/get_product_by_id_usecase.dart';
import 'package:localkart/feature/product/presentation/states/product_state.dart';

final productViewModelProvider =
    NotifierProvider<ProductViewModel, ProductState>(() => ProductViewModel());

class ProductViewModel extends Notifier<ProductState> {
  late final GetAllProductsUsecase _getAllProductsUsecase;
  late final GetProductByIdUsecase _getProductByIdUsecase;

  @override
  ProductState build() {
    _getAllProductsUsecase = ref.read(getAllProductsUsecaseProvider);
    _getProductByIdUsecase = ref.read(getProductByIdUsecaseProvider);

    return const ProductState();
  }

  Future<void> getAllProducts() async {
    state = state.copyWith(status: ProductStatus.loading);
    final result = await _getAllProductsUsecase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ProductStatus.error,
          errorMessage: failure.message,
        );
      },
      (products) {
        state = state.copyWith(
          status: ProductStatus.loaded,
          products: products,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> getProductById(String productId) async {
    state = state.copyWith(status: ProductStatus.loading);
    final params = GetProductByIdParams(productId: productId);

    final result = await _getProductByIdUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ProductStatus.error,
          errorMessage: failure.message,
        );
      },
      (product) {
        state = state.copyWith(
          status: ProductStatus.loaded,
          selectedProduct: product,
          errorMessage: null,
        );
      },
    );
  }
}
