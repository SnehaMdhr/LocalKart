// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AddressHiveModelAdapter extends TypeAdapter<AddressHiveModel> {
  @override
  final int typeId = 8;

  @override
  AddressHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AddressHiveModel(
      addressId: fields[0] as String?,
      userId: fields[1] as String,
      label: fields[2] as String,
      fullAddress: fields[3] as String,
      latitude: (fields[4] as num).toDouble(),
      longitude: (fields[5] as num).toDouble(),
      createdAt: fields[6] as String?,
      updatedAt: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AddressHiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.addressId)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.label)
      ..writeByte(3)
      ..write(obj.fullAddress)
      ..writeByte(4)
      ..write(obj.latitude)
      ..writeByte(5)
      ..write(obj.longitude)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
