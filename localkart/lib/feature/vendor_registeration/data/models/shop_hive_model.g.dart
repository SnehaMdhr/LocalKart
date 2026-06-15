// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShopHiveModelAdapter extends TypeAdapter<ShopHiveModel> {
  @override
  final int typeId = 1;

  @override
  ShopHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShopHiveModel(
      shopId: fields[0] as String?,
      userId: fields[1] as String?,
      shopName: fields[2] as String,
      address: fields[3] as String,
      description: fields[4] as String,
      categories: (fields[5] as List).cast<String>(),
      imageUrl: fields[6] as String?,
      status: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ShopHiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.shopId)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.shopName)
      ..writeByte(3)
      ..write(obj.address)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.categories)
      ..writeByte(6)
      ..write(obj.imageUrl)
      ..writeByte(7)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
