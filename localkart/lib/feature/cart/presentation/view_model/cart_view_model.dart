import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/feature/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:localkart/feature/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:localkart/feature/cart/domain/usecases/get_cart_usecase.dart';
import 'package:localkart/feature/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:localkart/feature/cart/domain/usecases/update_cart_quantity_usecase.dart';
import 'package:localkart/feature/cart/domain/entities/cart_entity.dart';
import 'package:localkart/feature/cart/presentation/states/cart_state.dart';

final cartViewModelProvider =
    NotifierProvider<CartViewModel, CartState>(() => CartViewModel());

class CartViewModel extends Notifier<CartState> {
  late final GetCartUsecase _getCartUsecase;
  late final AddToCartUsecase _addToCartUsecase;
  late final UpdateCartQuantityUsecase _updateCartQuantityUsecase;
  late final RemoveFromCartUsecase _removeFromCartUsecase;
  late final ClearCartUsecase _clearCartUsecase;

  @override
  CartState build() {
    _getCartUsecase = ref.read(getCartUsecaseProvider);
    _addToCartUsecase = ref.read(addToCartUsecaseProvider);
    _updateCartQuantityUsecase = ref.read(updateCartQuantityUsecaseProvider);
    _removeFromCartUsecase = ref.read(removeFromCartUsecaseProvider);
    _clearCartUsecase = ref.read(clearCartUsecaseProvider);

    return const CartState();
  }

  Future<void> getCart() async {
    state = state.copyWith(status: CartStatus.loading);
    final result = await _getCartUsecase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: CartStatus.error,
          errorMessage: failure.message,
        );
      },
      (cart) {
        state = state.copyWith(
          status: CartStatus.loaded,
          cart: cart,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> addToCart(String productId, {int quantity = 1}) async {
    state = state.copyWith(status: CartStatus.loading);
    final params = AddToCartParams(productId: productId, quantity: quantity);
    final result = await _addToCartUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: CartStatus.error,
          errorMessage: failure.message,
        );
      },
      (cart) {
        state = state.copyWith(
          status: CartStatus.loaded,
          cart: cart,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final currentCart = state.cart;
    if (currentCart == null) return;

    // Optimistic update
    final updatedItems = currentCart.items.map((item) {
      if (item.productId == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = state.copyWith(
      cart: currentCart.copyWith(items: updatedItems),
    );

    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }

    final params = UpdateCartQuantityParams(
      productId: productId,
      quantity: quantity,
    );
    final result = await _updateCartQuantityUsecase(params);

    result.fold(
      (failure) {
        // Revert optimistic update on failure
        state = state.copyWith(
          status: CartStatus.error,
          errorMessage: failure.message,
          cart: currentCart,
        );
      },
      (cart) {
        state = state.copyWith(
          status: CartStatus.loaded,
          cart: cart,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> removeFromCart(String productId) async {
    final currentCart = state.cart;
    if (currentCart == null) return;

    // Optimistic removal
    final updatedItems = currentCart.items
        .where((item) => item.productId != productId)
        .toList();

    state = state.copyWith(
      cart: currentCart.copyWith(items: updatedItems),
    );

    final params = RemoveFromCartParams(productId: productId);
    final result = await _removeFromCartUsecase(params);

    result.fold(
      (failure) {
        // Revert optimistic removal on failure
        state = state.copyWith(
          status: CartStatus.error,
          errorMessage: failure.message,
          cart: currentCart,
        );
      },
      (cart) {
        state = state.copyWith(
          status: CartStatus.loaded,
          cart: cart,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> clearCart() async {
    state = state.copyWith(status: CartStatus.loading);
    final result = await _clearCartUsecase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: CartStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          status: CartStatus.loaded,
          cart: const CartEntity(),
          errorMessage: null,
        );
      },
    );
  }
}
