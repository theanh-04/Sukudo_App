/// Model cho game history trong database
/// 
/// Lưu thông tin về mỗi ván chơi:
/// - Độ khó
/// - Thời gian hoàn thành
/// - Số lỗi
/// - Số lần gợi ý
/// - Ngày chơi
/// - Có phải daily challenge không
class GameHistoryModel {
  final int? id;
  final String difficulty;
  final int timeSeconds;
  final bool completed;
  final int mistakes;
  final int hintsUsed;
  final DateTime date;
  final bool isDaily;

  GameHistoryModel({
    this.id,
    required this.difficulty,
    required this.timeSeconds,
    required this.completed,
    required this.mistakes,
    required this.hintsUsed,
    required this.date,
    this.isDaily = false,
  });

  /// Chuyển từ Map (database) sang Model
  factory GameHistoryModel.fromMap(Map<String, dynamic> map) {
    return GameHistoryModel(
      id: map['id'] as int?,
      difficulty: map['difficulty'] as String,
      timeSeconds: map['time_seconds'] as int,
      completed: (map['completed'] as int) == 1,
      mistakes: map['mistakes'] as int,
      hintsUsed: map['hints_used'] as int,
      date: DateTime.parse(map['date'] as String),
      isDaily: (map['is_daily'] as int) == 1,
    );
  }

  /// Chuyển từ Model sang Map (để insert vào database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'difficulty': difficulty,
      'time_seconds': timeSeconds,
      'completed': completed ? 1 : 0,
      'mistakes': mistakes,
      'hints_used': hintsUsed,
      'date': date.toIso8601String(),
      'is_daily': isDaily ? 1 : 0,
    };
  }

  /// Copy with - tạo bản sao với một số field thay đổi
  GameHistoryModel copyWith({
    int? id,
    String? difficulty,
    int? timeSeconds,
    bool? completed,
    int? mistakes,
    int? hintsUsed,
    DateTime? date,
    bool? isDaily,
  }) {
    return GameHistoryModel(
      id: id ?? this.id,
      difficulty: difficulty ?? this.difficulty,
      timeSeconds: timeSeconds ?? this.timeSeconds,
      completed: completed ?? this.completed,
      mistakes: mistakes ?? this.mistakes,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      date: date ?? this.date,
      isDaily: isDaily ?? this.isDaily,
    );
  }

  @override
  String toString() {
    return 'GameHistoryModel(id: $id, difficulty: $difficulty, time: $timeSeconds, completed: $completed, mistakes: $mistakes, hints: $hintsUsed, date: $date, isDaily: $isDaily)';
  }
}
