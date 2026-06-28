import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/feature/cart/domain/entities/cart_entity.dart';
import 'package:localkart/feature/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:localkart/feature/cart/domain/usecases/get_cart_usecase.dart';
import 'package:localkart/feature/cart/domain/usecases/update_cart_quantity_usecase.dart';
import 'package:localkart/feature/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:localkart/feature/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:localkart/feature/cart/presentation/states/cart_state.dart';

final cartViewModelProvider =
    NotifierProvider<CartViewModel, CartState>(() => CartViewModel());

class CartViewModel extends Notifier<CartState> {
  late final AddToCartUsecase _addToCartUsecase;
  late final GetCartUsecase _getCartUsecase;
  late final UpdateCartQuantityUsecase _updateCartQuantityUsecase;
  late final RemoveFromCartUsecase _removeFromCartUsecase;
  late final ClearCartUsecase _clearCartUsecase;

  @override
  CartState build() {
    _addToCartUsecase = ref.read(addToCartUsecaseProvider);
    _getCartUsecase = ref.read(getCartUsecaseProvider);
    _updateCartQuantityUsecase = ref.read(updateCartQuantityUsecaseProvider);
    _removeFromCartUsecase = ref.read(removeFromCartUsecaseProvider);
    _clearCartUsecase = ref.read(clearCartUsecaseProvider);

    return const CartState();
  }

  int _calculateItemCount(CartEntity cart) {
    return cart.items.fold(0, (sum, item) => sum + item.quantity);
  }

  int _calculateTotalPrice(CartEntity cart) {
    return cart.items.fold<int>(
      0,
      (sum, item) => sum + ((item.price ?? 0) * item.quantity),
    );
  }

  void _updateCartState(CartEntity cart) {
    state = state.copyWith(
      cart: cart,
      itemCount: _calculateItemCount(cart),
      totalPrice: _calculateTotalPrice(cart),
    );
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
        );
        _updateCartState(cart);
      },
    );
  }

  Future<bool> addToCart({
    required String productId,
    required int quantity,
    String? productName,
    int? price,
    String? imageUrl,
  }) async {
    state = state.copyWith(isAddingToCart: true, errorMessage: null);

    // Optimistically update local state
    final existingItems = [...state.cart.items];
    final existingIndex = existingItems.indexWhere(
      (item) => item.productId == productId,
    );

    if (existingIndex >= 0) {
      final existing = existingItems[existingIndex];
      existingItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + quantity,
      );
    } else {
      existingItems.add(
        CartItemEntity(
          productId: productId,
          productName: productName,
          price: price,
          imageUrl: imageUrl,
          quantity: quantity,
        ),
      );
    }

    final optimisticCart = state.cart.copyWith(items: existingItems);
    _updateCartState(optimisticCart);

    final params = AddToCartParams(productId: productId, quantity: quantity);
    final result = await _addToCartUsecase(params);

    return result.fold(
      (failure) {
        // Revert optimistic update on failure
        state = state.copyWith(
          isAddingToCart: false,
          status: CartStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (cart) {
        state = state.copyWith(
          isAddingToCart: false,
          status: CartStatus.loaded,
          errorMessage: null,
        );
        _updateCartState(cart);
        return true;
      },
    );
  }

  Future<bool> updateQuantity({
    required String productId,
    required int quantity,
  }) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);

    // Optimistically update
    final existingItems = [...state.cart.items];
    final index = existingItems.indexWhere(
      (item) => item.productId == productId,
    );

    if (index >= 0) {
      if (quantity <= 0) {
        existingItems.removeAt(index);
      } else {
        existingItems[index] = existingItems[index].copyWith(quantity: quantity);
      }
    }

    final optimisticCart = state.cart.copyWith(items: existingItems);
    _updateCartState(optimisticCart);

    if (quantity <= 0) {
      final params = RemoveFromCartParams(productId: productId);
      final result = await _removeFromCartUsecase(params);

      return result.fold(
        (failure) {
          state = state.copyWith(
            isUpdating: false,
            errorMessage: failure.message,
          );
          return false;
        },
        (cart) {
          state = state.copyWith(
            isUpdating: false,
            status: CartStatus.loaded,
            errorMessage: null,
          );
          _updateCartState(cart);
          return true;
        },
      );
    }

    final params = UpdateCartQuantityParams(
      productId: productId,
      quantity: quantity,
    );
    final result = await _updateCartQuantityUsecase(params);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (cart) {
        state = state.copyWith(
          isUpdating: false,
          status: CartStatus.loaded,
          errorMessage: null,
        );
        _updateCartState(cart);
        return true;
      },
    );
  }

  Future<bool> removeFromCart(String productId) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);

    final params = RemoveFromCartParams(productId: productId);
    final result = await _removeFromCartUsecase(params);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (cart) {
        state = state.copyWith(
          isUpdating: false,
          status: CartStatus.loaded,
          errorMessage: null,
        );
        _updateCartState(cart);
        return true;
      },
    );
  }

  Future<bool> clearCart() async {
    state = state.copyWith(isUpdating: true, errorMessage: null);

    final result = await _clearCartUsecase();

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          isUpdating: false,
          status: CartStatus.loaded,
          cart: const CartEntity(),
          itemCount: 0,
          totalPrice: 0,
          errorMessage: null,
        );
        return true;
      },
    );
  }
}
