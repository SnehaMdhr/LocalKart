import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/vendor_registeration/data/repositories/shop_repository.dart';
import 'package:localkart/feature/vendor_registeration/domain/entities/shop_entity.dart';
import 'package:localkart/feature/vendor_registeration/domain/repositories/shop_repository.dart';

class UpdateShopUsecaseParams extends Equatable {
  final String shopName;
  final String address;
  final String description;
  final List<String> categories;
  final double? latitude;
  final double? longitude;

  const UpdateShopUsecaseParams({
    required this.shopName,
    required this.address,
    required this.description,
    required this.categories,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [shopName, address, description, categories, latitude, longitude];
}

final updateShopUsecaseProvider = Provider<UpdateShopUsecase>((ref) {
  final shopRepository = ref.read(shopRepositoryProvider);
  return UpdateShopUsecase(shopRepository: shopRepository);
});

class UpdateShopUsecase implements UseCaseWithParams<ShopEntity?, UpdateShopUsecaseParams> {
  final IShopRepository _shopRepository;

  UpdateShopUsecase({required IShopRepository shopRepository})
      : _shopRepository = shopRepository;

  @override
  Future<Either<Failure, ShopEntity?>> call(UpdateShopUsecaseParams params) {
    final entity = ShopEntity(
      shopName: params.shopName,
      address: params.address,
      description: params.description,
      categories: params.categories,
      latitude: params.latitude,
      longitude: params.longitude,
    );
    return _shopRepository.updateShop(entity);
  }
}
