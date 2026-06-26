import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/cart/data/repositories/cart_repository.dart';
import 'package:localkart/feature/cart/domain/entities/cart_entity.dart';
import 'package:localkart/feature/cart/domain/repositories/cart_repository.dart';

final getCartUsecaseProvider = Provider<GetCartUsecase>((ref) {
  final cartRepository = ref.read(cartRepositoryProvider);
  return GetCartUsecase(cartRepository: cartRepository);
});

class GetCartUsecase implements UsecaseWithoutParams<CartEntity> {
  final ICartRepository _cartRepository;

  GetCartUsecase({required ICartRepository cartRepository})
      : _cartRepository = cartRepository;

  @override
  Future<Either<Failure, CartEntity>> call() {
    return _cartRepository.getCart();
  }
}
