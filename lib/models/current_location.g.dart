// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_location.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CurrentLocationAdapter extends TypeAdapter<CurrentLocation> {
  @override
  final int typeId = 2;

  @override
  CurrentLocation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CurrentLocation(
      address: fields[0] as String,
      latitude: fields[1] as double,
      longitude: fields[2] as double,
      lastUpdated: fields[3] as DateTime?,
      isAutoDetected: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CurrentLocation obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.address)
      ..writeByte(1)
      ..write(obj.latitude)
      ..writeByte(2)
      ..write(obj.longitude)
      ..writeByte(3)
      ..write(obj.lastUpdated)
      ..writeByte(4)
      ..write(obj.isAutoDetected);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrentLocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}