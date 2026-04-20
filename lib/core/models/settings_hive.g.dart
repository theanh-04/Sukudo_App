// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsHiveAdapter extends TypeAdapter<SettingsHive> {
  @override
  final int typeId = 1;

  @override
  SettingsHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsHive(
      theme: fields[0] as String,
      soundEffects: fields[1] as bool,
      timerDisplay: fields[2] as bool,
      mistakesLimit: fields[3] as bool,
      highlightDuplicates: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsHive obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.theme)
      ..writeByte(1)
      ..write(obj.soundEffects)
      ..writeByte(2)
      ..write(obj.timerDisplay)
      ..writeByte(3)
      ..write(obj.mistakesLimit)
      ..writeByte(4)
      ..write(obj.highlightDuplicates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
