// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CollectionHiveModelAdapter extends TypeAdapter<CollectionHiveModel> {
  @override
  final int typeId = 3;

  @override
  CollectionHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CollectionHiveModel(
      collectionId: fields[0] as String?,
      userId: fields[1] as String,
      collectionName: fields[2] as String,
      productIds: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, CollectionHiveModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.collectionId)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.collectionName)
      ..writeByte(3)
      ..write(obj.productIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
