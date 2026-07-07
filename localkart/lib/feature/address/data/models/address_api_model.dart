import 'package:localkart/feature/address/data/models/address_hive_model.dart';
import 'package:localkart/feature/address/domain/entities/address_entity.dart';

class AddressApiModel {
  final String? addressId;
  final String userId;
  final String label;
  final String fullAddress;
  final double latitude;
  final double longitude;
  final String? createdAt;
  final String? updatedAt;

  AddressApiModel({
    this.addressId,
    this.userId = '',
    this.label = 'Home',
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  factory AddressApiModel.fromJson(Map<String, dynamic> json) {
    final userIdRaw = json['userId'];
    final userId = userIdRaw is Map<String, dynamic>
        ? (userIdRaw['_id'] as String? ?? '')
        : (userIdRaw as String? ?? '');

    return AddressApiModel(
      addressId: json['_id'] as String? ?? json['addressId'] as String?,
      userId: userId,
      label: json['label'] as String? ?? 'Home',
      fullAddress: json['fullAddress'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  factory AddressApiModel.fromJsonWithData(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    if (data != null) {
      return AddressApiModel.fromJson(data);
    }
    return AddressApiModel.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'fullAddress': fullAddress,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    final map = <String, dynamic>{};
    map['label'] = label;
    map['fullAddress'] = fullAddress;
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    return map;
  }

  AddressEntity toEntity() {
    return AddressEntity(
      addressId: addressId,
      userId: userId,
      label: label,
      fullAddress: fullAddress,
      latitude: latitude,
      longitude: longitude,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static List<AddressEntity> toEntityList(List<AddressApiModel> models) {
    return models.map((m) => m.toEntity()).toList();
  }

  AddressHiveModel toHiveModel() {
    return AddressHiveModel(
      addressId: addressId,
      userId: userId,
      label: label,
      fullAddress: fullAddress,
      latitude: latitude,
      longitude: longitude,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
