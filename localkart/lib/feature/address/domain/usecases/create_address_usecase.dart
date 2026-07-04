import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/address/data/repositories/address_repository.dart';
import 'package:localkart/feature/address/domain/entities/address_entity.dart';
import 'package:localkart/feature/address/domain/repositories/address_repository.dart';

class CreateAddressParams extends Equatable {
  final String label;
  final String fullAddress;
  final double latitude;
  final double longitude;

  const CreateAddressParams({
    this.label = 'Home',
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [label, fullAddress, latitude, longitude];
}

final createAddressUsecaseProvider = Provider<CreateAddressUsecase>((ref) {
  final addressRepository = ref.read(addressRepositoryProvider);
  return CreateAddressUsecase(addressRepository: addressRepository);
});

class CreateAddressUsecase
    implements UseCaseWithParams<AddressEntity, CreateAddressParams> {
  final IAddressRepository _addressRepository;

  CreateAddressUsecase({required IAddressRepository addressRepository})
      : _addressRepository = addressRepository;

  @override
  Future<Either<Failure, AddressEntity>> call(CreateAddressParams params) {
    return _addressRepository.createAddress(
      label: params.label,
      fullAddress: params.fullAddress,
      latitude: params.latitude,
      longitude: params.longitude,
    );
  }
}
