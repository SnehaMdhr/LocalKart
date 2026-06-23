import 'package:dartz/dartz.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/feature/cart/domain/entities/cart_entity.dart';

abstract interface class ICartRepository {
  Future<Either<Failure, CartEntity>> addToCart({
    required String productId,
    required int quantity,
  });
  Future<Either<Failure, CartEntity>> getCart();
  Future<Either<Failure, CartEntity>> updateQuantity({
    required String productId,
    required int quantity,
  });
  Future<Either<Failure, CartEntity>> removeFromCart(String productId);
  Future<Either<Failure, void>> clearCart();
}
