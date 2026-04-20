import 'package:hive/hive.dart';

part 'game_history_hive.g.dart';

/// Hive Model cho Game History
/// 
/// @HiveType: Đánh dấu class này là Hive model
/// typeId: ID duy nhất cho model này (0-223)
@HiveType(typeId: 0)
class GameHistoryHive extends HiveObject {
  @HiveField(0)
  String difficulty;

  @HiveField(1)
  int timeSeconds;

  @HiveField(2)
  bool completed;

  @HiveField(3)
  int mistakes;

  @HiveField(4)
  int hintsUsed;

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  bool isDaily;

  @HiveField(7)
  String? sudokuKey;

  GameHistoryHive({
    required this.difficulty,
    required this.timeSeconds,
    required this.completed,
    required this.mistakes,
    required this.hintsUsed,
    required this.date,
    this.isDaily = false,
    this.sudokuKey,
  });

  @override
  String toString() {
    return 'GameHistoryHive(difficulty: $difficulty, time: $timeSeconds, completed: $completed, mistakes: $mistakes, hints: $hintsUsed, date: $date, isDaily: $isDaily, sudokuKey: $sudokuKey)';
  }
}
