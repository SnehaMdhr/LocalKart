import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/cart/data/repositories/cart_repository.dart';
import 'package:localkart/feature/cart/domain/repositories/cart_repository.dart';

final clearCartUsecaseProvider = Provider<ClearCartUsecase>((ref) {
  final cartRepository = ref.read(cartRepositoryProvider);
  return ClearCartUsecase(cartRepository: cartRepository);
});

class ClearCartUsecase implements UsecaseWithoutParams<void> {
  final ICartRepository _cartRepository;

  ClearCartUsecase({required ICartRepository cartRepository})
      : _cartRepository = cartRepository;

  @override
  Future<Either<Failure, void>> call() {
    return _cartRepository.clearCart();
  }
}
