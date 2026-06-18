import 'package:dartz/dartz.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/feature/product/domain/entities/product_entity.dart';

abstract interface class IProductRepository {
  Future<Either<Failure, ProductEntity>> getProductById(String productId);
  Future<Either<Failure, List<ProductEntity>>> getAllProducts();
}
