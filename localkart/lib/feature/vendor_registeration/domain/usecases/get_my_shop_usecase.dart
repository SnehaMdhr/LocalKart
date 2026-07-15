import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/feature/vendor_registeration/data/repositories/shop_repository.dart';
import 'package:localkart/feature/vendor_registeration/domain/entities/shop_entity.dart';
import 'package:localkart/feature/vendor_registeration/domain/repositories/shop_repository.dart';

final getMyShopUsecaseProvider = Provider<GetMyShopUsecase>((ref) {
  final shopRepository = ref.read(shopRepositoryProvider);
  return GetMyShopUsecase(shopRepository: shopRepository);
});

class GetMyShopUsecase {
  final IShopRepository _shopRepository;

  GetMyShopUsecase({required IShopRepository shopRepository})
      : _shopRepository = shopRepository;

  Future<Either<Failure, ShopEntity?>> call() {
    return _shopRepository.getMyShop();
  }
}
