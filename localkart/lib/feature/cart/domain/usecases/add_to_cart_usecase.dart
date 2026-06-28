import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/cart/data/repositories/cart_repository.dart';
import 'package:localkart/feature/cart/domain/entities/cart_entity.dart';
import 'package:localkart/feature/cart/domain/repositories/cart_repository.dart';

class AddToCartParams extends Equatable {
  final String productId;
  final int quantity;

  const AddToCartParams({
    required this.productId,
    this.quantity = 1,
  });

  @override
  List<Object?> get props => [productId, quantity];
}

final addToCartUsecaseProvider = Provider<AddToCartUsecase>((ref) {
  final cartRepository = ref.read(cartRepositoryProvider);
  return AddToCartUsecase(cartRepository: cartRepository);
});

class AddToCartUsecase
    implements UseCaseWithParams<CartEntity, AddToCartParams> {
  final ICartRepository _cartRepository;

  AddToCartUsecase({required ICartRepository cartRepository})
      : _cartRepository = cartRepository;

  @override
  Future<Either<Failure, CartEntity>> call(AddToCartParams params) {
    return _cartRepository.addToCart(
      productId: params.productId,
      quantity: params.quantity,
    );
  }
}
