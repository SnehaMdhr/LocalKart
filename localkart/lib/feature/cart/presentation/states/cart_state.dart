import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_entity.dart';

enum CartStatus { initial, loading, loaded, error }

class CartState extends Equatable {
  final CartStatus status;
  final CartEntity cart;
  final int itemCount;
  final int totalPrice;
  final String? errorMessage;
  final bool isAddingToCart;
  final bool isUpdating;

  const CartState({
    this.status = CartStatus.initial,
    this.cart = const CartEntity(),
    this.itemCount = 0,
    this.totalPrice = 0,
    this.errorMessage,
    this.isAddingToCart = false,
    this.isUpdating = false,
  });

  CartState copyWith({
    CartStatus? status,
    CartEntity? cart,
    int? itemCount,
    int? totalPrice,
    String? errorMessage,
    bool? isAddingToCart,
    bool? isUpdating,
  }) {
    return CartState(
      status: status ?? this.status,
      cart: cart ?? this.cart,
      itemCount: itemCount ?? this.itemCount,
      totalPrice: totalPrice ?? this.totalPrice,
      errorMessage: errorMessage ?? this.errorMessage,
      isAddingToCart: isAddingToCart ?? this.isAddingToCart,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object?> get props => [
    status,
    cart,
    itemCount,
    totalPrice,
    errorMessage,
    isAddingToCart,
    isUpdating,
  ];
}
