import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/feature/address/domain/usecases/create_address_usecase.dart';
import 'package:localkart/feature/address/domain/usecases/delete_address_usecase.dart';
import 'package:localkart/feature/address/domain/usecases/get_addresses_usecase.dart';
import 'package:localkart/feature/address/domain/usecases/get_address_by_id_usecase.dart';
import 'package:localkart/feature/address/domain/usecases/update_address_usecase.dart';
import 'package:localkart/feature/address/presentation/states/address_state.dart';

final addressViewModelProvider =
    NotifierProvider<AddressViewModel, AddressState>(() => AddressViewModel());

class AddressViewModel extends Notifier<AddressState> {
  late final GetAddressesUsecase _getAddressesUsecase;
  late final GetAddressByIdUsecase _getAddressByIdUsecase;
  late final CreateAddressUsecase _createAddressUsecase;
  late final UpdateAddressUsecase _updateAddressUsecase;
  late final DeleteAddressUsecase _deleteAddressUsecase;

  @override
  AddressState build() {
    _getAddressesUsecase = ref.read(getAddressesUsecaseProvider);
    _getAddressByIdUsecase = ref.read(getAddressByIdUsecaseProvider);
    _createAddressUsecase = ref.read(createAddressUsecaseProvider);
    _updateAddressUsecase = ref.read(updateAddressUsecaseProvider);
    _deleteAddressUsecase = ref.read(deleteAddressUsecaseProvider);

    return const AddressState();
  }

  Future<void> getAddresses() async {
    state = state.copyWith(status: AddressStatus.loading);
    final result = await _getAddressesUsecase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AddressStatus.error,
          errorMessage: failure.message,
        );
      },
      (addresses) {
        state = state.copyWith(
          status: AddressStatus.loaded,
          addresses: addresses,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> getAddressById(String addressId) async {
    state = state.copyWith(status: AddressStatus.loading);
    final params = GetAddressByIdParams(addressId: addressId);
    final result = await _getAddressByIdUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AddressStatus.error,
          errorMessage: failure.message,
        );
      },
      (address) {
        state = state.copyWith(
          status: AddressStatus.loaded,
          selectedAddress: address,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> createAddress({
    required String label,
    required String fullAddress,
    required double latitude,
    required double longitude,
  }) async {
    state = state.copyWith(status: AddressStatus.loading);
    final params = CreateAddressParams(
      label: label,
      fullAddress: fullAddress,
      latitude: latitude,
      longitude: longitude,
    );
    final result = await _createAddressUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AddressStatus.error,
          errorMessage: failure.message,
        );
      },
      (address) {
        // Refresh the list after adding
        getAddresses();
      },
    );
  }

  Future<void> updateAddress({
    required String addressId,
    String? label,
    String? fullAddress,
    double? latitude,
    double? longitude,
  }) async {
    final currentAddresses = state.addresses;
    if (currentAddresses == null) return;

    // Optimistic update
    final updatedAddresses = currentAddresses.map((addr) {
      if (addr.addressId == addressId) {
        return addr.copyWith(
          label: label,
          fullAddress: fullAddress,
          latitude: latitude,
          longitude: longitude,
        );
      }
      return addr;
    }).toList();

    state = state.copyWith(
      addresses: updatedAddresses,
    );

    final params = UpdateAddressParams(
      addressId: addressId,
      label: label,
      fullAddress: fullAddress,
      latitude: latitude,
      longitude: longitude,
    );
    final result = await _updateAddressUsecase(params);

    result.fold(
      (failure) {
        // Revert optimistic update on failure
        state = state.copyWith(
          status: AddressStatus.error,
          errorMessage: failure.message,
          addresses: currentAddresses,
        );
      },
      (address) {
        state = state.copyWith(
          status: AddressStatus.loaded,
          selectedAddress: address,
          errorMessage: null,
        );
        // Refresh the full list
        getAddresses();
      },
    );
  }

  Future<void> deleteAddress(String addressId) async {
    final currentAddresses = state.addresses;
    if (currentAddresses == null) return;

    // Optimistic removal
    final updatedAddresses = currentAddresses
        .where((addr) => addr.addressId != addressId)
        .toList();

    state = state.copyWith(
      addresses: updatedAddresses,
    );

    final params = DeleteAddressParams(addressId: addressId);
    final result = await _deleteAddressUsecase(params);

    result.fold(
      (failure) {
        // Revert optimistic removal on failure
        state = state.copyWith(
          status: AddressStatus.error,
          errorMessage: failure.message,
          addresses: currentAddresses,
        );
      },
      (_) {
        state = state.copyWith(
          status: AddressStatus.loaded,
          errorMessage: null,
        );
      },
    );
  }
}
