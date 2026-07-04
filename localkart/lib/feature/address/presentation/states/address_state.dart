import 'package:equatable/equatable.dart';
import '../../domain/entities/address_entity.dart';

enum AddressStatus { initial, loading, loaded, error }

class AddressState extends Equatable {
  final AddressStatus status;
  final List<AddressEntity>? addresses;
  final AddressEntity? selectedAddress;
  final String? errorMessage;

  const AddressState({
    this.status = AddressStatus.initial,
    this.addresses,
    this.selectedAddress,
    this.errorMessage,
  });

  AddressState copyWith({
    AddressStatus? status,
    List<AddressEntity>? addresses,
    AddressEntity? selectedAddress,
    String? errorMessage,
  }) {
    return AddressState(
      status: status ?? this.status,
      addresses: addresses ?? this.addresses,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, addresses, selectedAddress, errorMessage];
}
