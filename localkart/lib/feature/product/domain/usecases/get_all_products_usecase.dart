import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/product/data/repositories/product_repository.dart';
import 'package:localkart/feature/product/domain/entities/product_entity.dart';
import 'package:localkart/feature/product/domain/repositories/product_repository.dart';

final getAllProductsUsecaseProvider = Provider<GetAllProductsUsecase>((ref) {
  final productRepository = ref.read(productRepositoryProvider);
  return GetAllProductsUsecase(productRepository: productRepository);
});

class GetAllProductsUsecase
    implements UsecaseWithoutParams<List<ProductEntity>> {
  final IProductRepository _productRepository;

  GetAllProductsUsecase({required IProductRepository productRepository})
    : _productRepository = productRepository;

  @override
  Future<Either<Failure, List<ProductEntity>>> call() {
    return _productRepository.getAllProducts();
  }
}
