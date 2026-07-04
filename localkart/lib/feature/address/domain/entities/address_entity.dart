import 'package:equatable/equatable.dart';

class AddressEntity extends Equatable {
  final String? addressId;
  final String userId;
  final String label;
  final String fullAddress;
  final double latitude;
  final double longitude;
  final String? createdAt;
  final String? updatedAt;

  const AddressEntity({
    this.addressId,
    this.userId = '',
    this.label = 'Home',
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  AddressEntity copyWith({
    String? addressId,
    String? userId,
    String? label,
    String? fullAddress,
    double? latitude,
    double? longitude,
    String? createdAt,
    String? updatedAt,
  }) {
    return AddressEntity(
      addressId: addressId ?? this.addressId,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        addressId,
        userId,
        label,
        fullAddress,
        latitude,
        longitude,
        createdAt,
        updatedAt,
      ];
}
