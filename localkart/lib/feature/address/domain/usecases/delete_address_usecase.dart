import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/address/data/repositories/address_repository.dart';
import 'package:localkart/feature/address/domain/repositories/address_repository.dart';

class DeleteAddressParams extends Equatable {
  final String addressId;

  const DeleteAddressParams({required this.addressId});

  @override
  List<Object?> get props => [addressId];
}

final deleteAddressUsecaseProvider = Provider<DeleteAddressUsecase>((ref) {
  final addressRepository = ref.read(addressRepositoryProvider);
  return DeleteAddressUsecase(addressRepository: addressRepository);
});

class DeleteAddressUsecase
    implements UseCaseWithParams<void, DeleteAddressParams> {
  final IAddressRepository _addressRepository;

  DeleteAddressUsecase({required IAddressRepository addressRepository})
      : _addressRepository = addressRepository;

  @override
  Future<Either<Failure, void>> call(DeleteAddressParams params) {
    return _addressRepository.deleteAddress(params.addressId);
  }
}
