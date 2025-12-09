// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 0;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      userId: fields[0] as String,
      currentLocation: fields[1] as CurrentLocation?,
      interestedAreas: (fields[2] as List?)?.cast<InterestedArea>(),
      hasPets: fields[3] as bool,
      livesWithFamily: fields[4] as bool,
      housingTypeCode: fields[5] as String,
      hasVehicle: fields[6] as bool,
      updatedAt: fields[7] as DateTime?,
      createdAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.currentLocation)
      ..writeByte(2)
      ..write(obj.interestedAreas)
      ..writeByte(3)
      ..write(obj.hasPets)
      ..writeByte(4)
      ..write(obj.livesWithFamily)
      ..writeByte(5)
      ..write(obj.housingTypeCode)
      ..writeByte(6)
      ..write(obj.hasVehicle)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
