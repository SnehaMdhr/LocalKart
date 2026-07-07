import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/address/data/repositories/address_repository.dart';
import 'package:localkart/feature/address/domain/entities/address_entity.dart';
import 'package:localkart/feature/address/domain/repositories/address_repository.dart';

class GetAddressByIdParams extends Equatable {
  final String addressId;

  const GetAddressByIdParams({required this.addressId});

  @override
  List<Object?> get props => [addressId];
}

final getAddressByIdUsecaseProvider = Provider<GetAddressByIdUsecase>((ref) {
  final addressRepository = ref.read(addressRepositoryProvider);
  return GetAddressByIdUsecase(addressRepository: addressRepository);
});

class GetAddressByIdUsecase
    implements UseCaseWithParams<AddressEntity, GetAddressByIdParams> {
  final IAddressRepository _addressRepository;

  GetAddressByIdUsecase({required IAddressRepository addressRepository})
      : _addressRepository = addressRepository;

  @override
  Future<Either<Failure, AddressEntity>> call(GetAddressByIdParams params) {
    return _addressRepository.getAddressById(params.addressId);
  }
}
