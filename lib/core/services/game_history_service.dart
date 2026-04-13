import 'dart:convert';
import 'storage_service.dart';
import 'level_service.dart';

class GameHistory {
  final String sudokuKey;
  final String difficulty;
  final int timeInSeconds;
  final DateTime completedAt;
  final bool isCompleted;

  GameHistory({
    required this.sudokuKey,
    required this.difficulty,
    required this.timeInSeconds,
    required this.completedAt,
    required this.isCompleted,
  });

  Map<String, dynamic> toJson() {
    return {
      'sudokuKey': sudokuKey,
      'difficulty': difficulty,
      'timeInSeconds': timeInSeconds,
      'completedAt': completedAt.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory GameHistory.fromJson(Map<String, dynamic> json) {
    return GameHistory(
      sudokuKey: json['sudokuKey'],
      difficulty: json['difficulty'],
      timeInSeconds: json['timeInSeconds'],
      completedAt: DateTime.parse(json['completedAt']),
      isCompleted: json['isCompleted'],
    );
  }
}

class GameHistoryService {
  static const String _historyKey = 'game_history';
  static const String _progressKey = 'game_progress';

  final StorageService _storage = StorageService.instance;

  // Lưu lịch sử chơi và trả về có level up không
  Future<bool> saveGameHistory(GameHistory history) async {
    final histories = await getGameHistories();
    
    // Xóa history cũ của cùng sudoku nếu có
    histories.removeWhere((h) => h.sudokuKey == history.sudokuKey);
    
    // Thêm history mới
    histories.add(history);
    
    // Lưu vào storage
    final jsonList = histories.map((h) => h.toJson()).toList();
    await _storage.setString(_historyKey, jsonEncode(jsonList));
    
    // Thêm XP nếu hoàn thành và trả về có level up không
    if (history.isCompleted) {
      final xp = _getXPForDifficulty(history.difficulty);
      return await LevelService().addXP(xp);
    }
    
    return false;
  }
  
  // Tính XP dựa trên độ khó
  int _getXPForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'Dễ':
        return 10;
      case 'Trung bình':
        return 15;
      case 'Khó':
        return 20;
      case 'Chuyên gia':
        return 30;
      default:
        return 10;
    }
  }

  // Lấy tất cả lịch sử
  Future<List<GameHistory>> getGameHistories() async {
    final jsonStr = _storage.getString(_historyKey);
    if (jsonStr == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.map((json) => GameHistory.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Lấy lịch sử theo difficulty
  Future<List<GameHistory>> getHistoriesByDifficulty(String difficulty) async {
    final histories = await getGameHistories();
    return histories.where((h) => h.difficulty == difficulty).toList();
  }

  // Kiểm tra sudoku đã hoàn thành chưa
  Future<bool> isCompleted(String sudokuKey) async {
    final histories = await getGameHistories();
    final history = histories.where((h) => h.sudokuKey == sudokuKey).firstOrNull;
    return history?.isCompleted ?? false;
  }

  // Lấy thời gian tốt nhất của sudoku
  Future<int?> getBestTime(String sudokuKey) async {
    final histories = await getGameHistories();
    final history = histories.where((h) => h.sudokuKey == sudokuKey).firstOrNull;
    return history?.timeInSeconds;
  }

  // Tính progress theo difficulty
  Future<Map<String, dynamic>> getProgress(String difficulty, int totalLevels) async {
    final histories = await getHistoriesByDifficulty(difficulty);
    final completed = histories.where((h) => h.isCompleted).length;
    final percentage = totalLevels > 0 ? (completed / totalLevels * 100).round() : 0;

    return {
      'completed': completed,
      'total': totalLevels,
      'percentage': percentage,
    };
  }

  // Lấy tổng progress tất cả difficulty
  Future<Map<String, dynamic>> getTotalProgress() async {
    final histories = await getGameHistories();
    final completed = histories.where((h) => h.isCompleted).length;
    
    // Giả sử mỗi difficulty có 100 levels
    const totalLevels = 500; // 5 difficulties x 100 levels
    final percentage = (completed / totalLevels * 100).round();

    return {
      'completed': completed,
      'total': totalLevels,
      'percentage': percentage,
    };
  }

  // Xóa tất cả lịch sử
  Future<void> clearHistory() async {
    await _storage.remove(_historyKey);
  }

  // Lưu tiến trình game đang chơi
  Future<void> saveGameProgress({
    required String sudokuKey,
    required String difficulty,
    required List<Map<String, dynamic>> cells,
    required int secondsPlayed,
    required int mistakes,
  }) async {
    final progress = {
      'sudokuKey': sudokuKey,
      'difficulty': difficulty,
      'cells': cells,
      'secondsPlayed': secondsPlayed,
      'mistakes': mistakes,
      'savedAt': DateTime.now().toIso8601String(),
    };

    await _storage.setString(
      '${_progressKey}_$sudokuKey',
      jsonEncode(progress),
    );
  }

  // Load tiến trình game đang chơi
  Future<Map<String, dynamic>?> loadGameProgress(String sudokuKey) async {
    final jsonStr = _storage.getString('${_progressKey}_$sudokuKey');
    if (jsonStr == null) return null;

    try {
      return jsonDecode(jsonStr);
    } catch (e) {
      return null;
    }
  }

  // Xóa tiến trình game
  Future<void> clearGameProgress(String sudokuKey) async {
    await _storage.remove('${_progressKey}_$sudokuKey');
  }

  // Thống kê tổng quan
  Future<Map<String, dynamic>> getOverallStats() async {
    final histories = await getGameHistories();
    final completed = histories.where((h) => h.isCompleted).toList();
    
    final totalGames = completed.length;
    final totalTime = completed.fold<int>(0, (sum, h) => sum + h.timeInSeconds);
    
    return {
      'totalGames': totalGames,
      'totalTime': totalTime,
      'winRate': totalGames > 0 ? 100.0 : 0.0,
    };
  }

  // Thống kê theo độ khó
  Future<Map<String, dynamic>> getStatsByDifficulty(String difficulty) async {
    final histories = await getHistoriesByDifficulty(difficulty);
    final completed = histories.where((h) => h.isCompleted).toList();
    
    if (completed.isEmpty) {
      return {
        'bestTime': null,
        'avgTime': null,
        'count': 0,
      };
    }
    
    final times = completed.map((h) => h.timeInSeconds).toList();
    final bestTime = times.reduce((a, b) => a < b ? a : b);
    final avgTime = times.reduce((a, b) => a + b) ~/ times.length;
    
    return {
      'bestTime': bestTime,
      'avgTime': avgTime,
      'count': completed.length,
    };
  }

  // Thống kê theo tuần (7 ngày gần nhất)
  Future<List<int>> getWeeklyStats() async {
    final histories = await getGameHistories();
    final now = DateTime.now();
    final weekData = List<int>.filled(7, 0);
    
    for (var history in histories) {
      if (!history.isCompleted) continue;
      
      final diff = now.difference(history.completedAt).inDays;
      if (diff >= 0 && diff < 7) {
        weekData[6 - diff]++;
      }
    }
    
    return weekData;
  }

  // Streak hiện tại
  Future<int> getCurrentStreak() async {
    final histories = await getGameHistories();
    final completed = histories.where((h) => h.isCompleted).toList();
    
    if (completed.isEmpty) return 0;
    
    completed.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    
    int streak = 0;
    DateTime? lastDate;
    
    for (var history in completed) {
      final date = DateTime(
        history.completedAt.year,
        history.completedAt.month,
        history.completedAt.day,
      );
      
      if (lastDate == null) {
        lastDate = date;
        streak = 1;
      } else {
        final diff = lastDate.difference(date).inDays;
        if (diff == 0) {
          continue;
        } else if (diff == 1) {
          streak++;
          lastDate = date;
        } else {
          break;
        }
      }
    }
    
    return streak;
  }

  // Best streak
  Future<int> getBestStreak() async {
    final histories = await getGameHistories();
    final completed = histories.where((h) => h.isCompleted).toList();
    
    if (completed.isEmpty) return 0;
    
    completed.sort((a, b) => a.completedAt.compareTo(b.completedAt));
    
    int bestStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;
    
    for (var history in completed) {
      final date = DateTime(
        history.completedAt.year,
        history.completedAt.month,
        history.completedAt.day,
      );
      
      if (lastDate == null) {
        lastDate = date;
        currentStreak = 1;
      } else {
        final diff = date.difference(lastDate).inDays;
        if (diff == 0) {
          continue;
        } else if (diff == 1) {
          currentStreak++;
          lastDate = date;
        } else {
          if (currentStreak > bestStreak) {
            bestStreak = currentStreak;
          }
          currentStreak = 1;
          lastDate = date;
        }
      }
    }
    
    if (currentStreak > bestStreak) {
      bestStreak = currentStreak;
    }
    
    return bestStreak;
  }

  // Daily Challenge - Lưu ngày đã hoàn thành
  Future<void> completeDailyChallenge(DateTime date) async {
    final key = 'daily_${date.year}_${date.month}';
    final completedDays = await getCompletedDaysInMonth(date.year, date.month);
    
    if (!completedDays.contains(date.day)) {
      completedDays.add(date.day);
      await _storage.setString(key, jsonEncode(completedDays));
    }
  }

  // Daily Challenge - Lấy các ngày đã hoàn thành trong tháng
  Future<List<int>> getCompletedDaysInMonth(int year, int month) async {
    final key = 'daily_${year}_$month';
    final jsonStr = _storage.getString(key);
    
    if (jsonStr == null) return [];
    
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.cast<int>();
    } catch (e) {
      return [];
    }
  }

  // Daily Challenge - Kiểm tra ngày hôm nay đã hoàn thành chưa
  Future<bool> isTodayCompleted() async {
    final now = DateTime.now();
    final completedDays = await getCompletedDaysInMonth(now.year, now.month);
    return completedDays.contains(now.day);
  }

  // Daily Challenge - Lấy Sudoku cho ngày cụ thể
  String getDailySudokuForDate(DateTime date) {
    // Tạo seed từ ngày để có Sudoku cố định cho mỗi ngày
    final seed = date.year * 10000 + date.month * 100 + date.day;
    
    // Danh sách Sudoku mẫu (trong thực tế nên load từ file hoặc API)
    final sudokus = [
      '530070000600195000098000060800060003400803001700020006060000280000419005000080079',
      '003020600900305001001806400008102900700000008006708200002609500800203009005010300',
      '200080300060070084030500209000105408000000000402706000301007040720040060004010003',
    ];
    
    // Chọn Sudoku dựa trên seed
    return sudokus[seed % sudokus.length];
  }

  // Daily Challenge - Lấy độ khó cho ngày cụ thể
  String getDailyDifficultyForDate(DateTime date) {
    final dayOfWeek = date.weekday;
    
    // Thứ 2-3: Dễ
    if (dayOfWeek <= 2) return 'Dễ';
    // Thứ 4-5: Trung bình
    if (dayOfWeek <= 4) return 'Trung bình';
    // Thứ 6: Khó
    if (dayOfWeek == 5) return 'Khó';
    // Thứ 7-CN: Chuyên gia
    return 'Chuyên gia';
  }

  // Daily Challenge - Lấy điểm thưởng cho ngày cụ thể
  int getDailyXPForDate(DateTime date) {
    final difficulty = getDailyDifficultyForDate(date);
    
    switch (difficulty) {
      case 'Dễ':
        return 10;
      case 'Trung bình':
        return 15;
      case 'Khó':
        return 20;
      case 'Chuyên gia':
        return 25;
      default:
        return 10;
    }
  }
}
