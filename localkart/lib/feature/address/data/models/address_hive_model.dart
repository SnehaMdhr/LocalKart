import 'package:hive/hive.dart';
import 'package:localkart/core/constants/hive_table_constants.dart';
import 'package:localkart/feature/address/domain/entities/address_entity.dart';
import 'package:uuid/uuid.dart';

part 'address_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.addressTypeId)
class AddressHiveModel extends HiveObject {
  @HiveField(0)
  final String addressId;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String label;

  @HiveField(3)
  final String fullAddress;

  @HiveField(4)
  final double latitude;

  @HiveField(5)
  final double longitude;

  @HiveField(6)
  final String? createdAt;

  @HiveField(7)
  final String? updatedAt;

  AddressHiveModel({
    String? addressId,
    this.userId = '',
    this.label = 'Home',
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
    this.createdAt,
    this.updatedAt,
  }) : addressId = addressId ?? const Uuid().v4();

  factory AddressHiveModel.fromEntity(AddressEntity entity) {
    return AddressHiveModel(
      addressId: entity.addressId,
      userId: entity.userId,
      label: entity.label,
      fullAddress: entity.fullAddress,
      latitude: entity.latitude,
      longitude: entity.longitude,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
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

  static List<AddressEntity> toEntityList(List<AddressHiveModel> models) {
    return models.map((e) => e.toEntity()).toList();
  }
}
