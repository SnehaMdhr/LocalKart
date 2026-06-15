import 'package:dartz/dartz.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/feature/vendor_registeration/domain/entities/shop_entity.dart';

abstract interface class IShopRepository {
  Future<Either<Failure, bool>> registerShop(ShopEntity entity);
}
