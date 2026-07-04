import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/address/data/repositories/address_repository.dart';
import 'package:localkart/feature/address/domain/entities/address_entity.dart';
import 'package:localkart/feature/address/domain/repositories/address_repository.dart';

final getAddressesUsecaseProvider = Provider<GetAddressesUsecase>((ref) {
  final addressRepository = ref.read(addressRepositoryProvider);
  return GetAddressesUsecase(addressRepository: addressRepository);
});

class GetAddressesUsecase implements UsecaseWithoutParams<List<AddressEntity>> {
  final IAddressRepository _addressRepository;

  GetAddressesUsecase({required IAddressRepository addressRepository})
      : _addressRepository = addressRepository;

  @override
  Future<Either<Failure, List<AddressEntity>>> call() {
    return _addressRepository.getAddresses();
  }
}
