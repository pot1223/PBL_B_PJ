// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shelter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShelterAdapter extends TypeAdapter<Shelter> {
  @override
  final int typeId = 3;

  @override
  Shelter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Shelter(
      name: fields[0] as String,
      address: fields[1] as String,
      longitude: fields[2] as double,
      latitude: fields[3] as double,
      phoneNumber: fields[4] as String?,
      capacity: fields[5] as int?,
      facilityType: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Shelter obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.longitude)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.phoneNumber)
      ..writeByte(5)
      ..write(obj.capacity)
      ..writeByte(6)
      ..write(obj.facilityType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShelterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
