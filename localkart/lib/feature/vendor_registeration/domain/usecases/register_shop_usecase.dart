import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/app_usecase.dart';
import '../../data/repositories/shop_repository.dart';
import '../entities/shop_entity.dart';
import '../repositories/shop_repository.dart';

class RegisterShopUsecaseParams extends Equatable {
  final String shopName;
  final String address;
  final String description;
  final List<String> categories;
  final String? imageUrl;

  const RegisterShopUsecaseParams({
    required this.shopName,
    required this.address,
    required this.description,
    required this.categories,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [shopName, address, description, categories, imageUrl];
}

final registerShopUsecaseProvider = Provider<RegisterShopUsecase>((ref) {
  final shopRepository = ref.read(shopRepositoryProvider);
  return RegisterShopUsecase(shopRepository: shopRepository);
});

class RegisterShopUsecase implements UseCaseWithParams<bool, RegisterShopUsecaseParams> {
  final IShopRepository _shopRepository;

  RegisterShopUsecase({required IShopRepository shopRepository})
      : _shopRepository = shopRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterShopUsecaseParams params) {
    final entity = ShopEntity(
      shopName: params.shopName,
      address: params.address,
      description: params.description,
      categories: params.categories,
      imageUrl: params.imageUrl,
    );
    return _shopRepository.registerShop(entity);
  }
}
