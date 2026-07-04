import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/address/data/repositories/address_repository.dart';
import 'package:localkart/feature/address/domain/entities/address_entity.dart';
import 'package:localkart/feature/address/domain/repositories/address_repository.dart';

class UpdateAddressParams extends Equatable {
  final String addressId;
  final String? label;
  final String? fullAddress;
  final double? latitude;
  final double? longitude;

  const UpdateAddressParams({
    required this.addressId,
    this.label,
    this.fullAddress,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props =>
      [addressId, label, fullAddress, latitude, longitude];
}

final updateAddressUsecaseProvider = Provider<UpdateAddressUsecase>((ref) {
  final addressRepository = ref.read(addressRepositoryProvider);
  return UpdateAddressUsecase(addressRepository: addressRepository);
});

class UpdateAddressUsecase
    implements UseCaseWithParams<AddressEntity, UpdateAddressParams> {
  final IAddressRepository _addressRepository;

  UpdateAddressUsecase({required IAddressRepository addressRepository})
      : _addressRepository = addressRepository;

  @override
  Future<Either<Failure, AddressEntity>> call(UpdateAddressParams params) {
    return _addressRepository.updateAddress(
      addressId: params.addressId,
      label: params.label,
      fullAddress: params.fullAddress,
      latitude: params.latitude,
      longitude: params.longitude,
    );
  }
}
