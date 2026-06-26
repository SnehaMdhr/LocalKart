import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/cart/data/repositories/cart_repository.dart';
import 'package:localkart/feature/cart/domain/entities/cart_entity.dart';
import 'package:localkart/feature/cart/domain/repositories/cart_repository.dart';

class UpdateCartQuantityParams extends Equatable {
  final String productId;
  final int quantity;

  const UpdateCartQuantityParams({
    required this.productId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productId, quantity];
}

final updateCartQuantityUsecaseProvider =
    Provider<UpdateCartQuantityUsecase>((ref) {
  final cartRepository = ref.read(cartRepositoryProvider);
  return UpdateCartQuantityUsecase(cartRepository: cartRepository);
});

class UpdateCartQuantityUsecase
    implements
        UseCaseWithParams<CartEntity, UpdateCartQuantityParams> {
  final ICartRepository _cartRepository;

  UpdateCartQuantityUsecase({required ICartRepository cartRepository})
      : _cartRepository = cartRepository;

  @override
  Future<Either<Failure, CartEntity>> call(UpdateCartQuantityParams params) {
    return _cartRepository.updateQuantity(
      productId: params.productId,
      quantity: params.quantity,
    );
  }
}
