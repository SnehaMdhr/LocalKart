import 'package:dartz/dartz.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/feature/address/domain/entities/address_entity.dart';

abstract interface class IAddressRepository {
  Future<Either<Failure, AddressEntity>> createAddress({
    required String label,
    required String fullAddress,
    required double latitude,
    required double longitude,
  });
  Future<Either<Failure, List<AddressEntity>>> getAddresses();
  Future<Either<Failure, AddressEntity>> getAddressById(String addressId);
  Future<Either<Failure, AddressEntity>> updateAddress({
    required String addressId,
    String? label,
    String? fullAddress,
    double? latitude,
    double? longitude,
  });
  Future<Either<Failure, void>> deleteAddress(String addressId);
}
