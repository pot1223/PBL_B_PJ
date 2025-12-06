// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interested_area.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InterestedAreaAdapter extends TypeAdapter<InterestedArea> {
  @override
  final int typeId = 1;

  @override
  InterestedArea read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InterestedArea(
      id: fields[0] as String,
      address: fields[1] as String,
      reasons: (fields[2] as List).cast<String>(),
      customReason: fields[3] as String?,
      order: fields[4] as int,
      createdAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, InterestedArea obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.reasons)
      ..writeByte(3)
      ..write(obj.customReason)
      ..writeByte(4)
      ..write(obj.order)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterestedAreaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}