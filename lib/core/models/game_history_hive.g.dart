// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_history_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameHistoryHiveAdapter extends TypeAdapter<GameHistoryHive> {
  @override
  final int typeId = 0;

  @override
  GameHistoryHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameHistoryHive(
      difficulty: fields[0] as String,
      timeSeconds: fields[1] as int,
      completed: fields[2] as bool,
      mistakes: fields[3] as int,
      hintsUsed: fields[4] as int,
      date: fields[5] as DateTime,
      isDaily: fields[6] as bool,
      sudokuKey: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, GameHistoryHive obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.difficulty)
      ..writeByte(1)
      ..write(obj.timeSeconds)
      ..writeByte(2)
      ..write(obj.completed)
      ..writeByte(3)
      ..write(obj.mistakes)
      ..writeByte(4)
      ..write(obj.hintsUsed)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.isDaily)
      ..writeByte(7)
      ..write(obj.sudokuKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameHistoryHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
