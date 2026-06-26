import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/cart/data/repositories/cart_repository.dart';
import 'package:localkart/feature/cart/domain/entities/cart_entity.dart';
import 'package:localkart/feature/cart/domain/repositories/cart_repository.dart';

class RemoveFromCartParams extends Equatable {
  final String productId;

  const RemoveFromCartParams({required this.productId});

  @override
  List<Object?> get props => [productId];
}

final removeFromCartUsecaseProvider = Provider<RemoveFromCartUsecase>((ref) {
  final cartRepository = ref.read(cartRepositoryProvider);
  return RemoveFromCartUsecase(cartRepository: cartRepository);
});

class RemoveFromCartUsecase
    implements UseCaseWithParams<CartEntity, RemoveFromCartParams> {
  final ICartRepository _cartRepository;

  RemoveFromCartUsecase({required ICartRepository cartRepository})
      : _cartRepository = cartRepository;

  @override
  Future<Either<Failure, CartEntity>> call(RemoveFromCartParams params) {
    return _cartRepository.removeFromCart(params.productId);
  }
}
