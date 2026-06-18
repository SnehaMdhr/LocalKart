import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/product/data/repositories/product_repository.dart';
import 'package:localkart/feature/product/domain/entities/product_entity.dart';
import 'package:localkart/feature/product/domain/repositories/product_repository.dart';

class GetProductByIdParams extends Equatable {
  final String productId;

  const GetProductByIdParams({required this.productId});

  @override
  List<Object?> get props => [productId];
}

final getProductByIdUsecaseProvider = Provider<GetProductByIdUsecase>((ref) {
  final productRepository = ref.read(productRepositoryProvider);
  return GetProductByIdUsecase(productRepository: productRepository);
});

class GetProductByIdUsecase
    implements UseCaseWithParams<ProductEntity, GetProductByIdParams> {
  final IProductRepository _productRepository;

  GetProductByIdUsecase({required IProductRepository productRepository})
    : _productRepository = productRepository;

  @override
  Future<Either<Failure, ProductEntity>> call(GetProductByIdParams params) {
    return _productRepository.getProductById(params.productId);
  }
}
