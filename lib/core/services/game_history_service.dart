import 'dart:convert';
import 'hive_service.dart';
import 'storage_service.dart';
import 'level_service.dart';
import '../models/game_history_hive.dart';

/// GameHistoryService - Quản lý lịch sử game với Hive
/// 
/// THAY ĐỔI: Đã chuyển sang Hive
/// - Dùng Hive thay vì SQLite
/// - Chạy được trên Web + Android + iOS + Desktop
/// - Đơn giản hơn SQLite, nhanh hơn SharedPreferences
class GameHistoryService {
  final HiveService _hive = HiveService.instance;
  final StorageService _storage = StorageService.instance;
  
  static const String _progressKey = 'game_progress';

  /// Lưu lịch sử game và trả về có level up không
  Future<bool> saveGameHistory({
    required String difficulty,
    required int timeSeconds,
    required bool completed,
    required int mistakes,
    required int hintsUsed,
    bool isDaily = false,
    String? sudokuKey,
  }) async {
    final history = GameHistoryHive(
      difficulty: difficulty,
      timeSeconds: timeSeconds,
      completed: completed,
      mistakes: mistakes,
      hintsUsed: hintsUsed,
      date: DateTime.now(),
      isDaily: isDaily,
      sudokuKey: sudokuKey,
    );

    // Add vào Hive box
    final box = _hive.getGameHistoryBox();
    await box.add(history);

    // Thêm XP nếu hoàn thành
    if (completed) {
      final xp = _getXPForDifficulty(difficulty);
      return await LevelService().addXP(xp);
    }

    return false;
  }

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
      case 'Ác mộng':
        return 40;
      default:
        return 10;
    }
  }

  /// Lấy tất cả lịch sử
  Future<List<GameHistoryHive>> getGameHistories() async {
    final box = _hive.getGameHistoryBox();
    return box.values.toList();
  }

  /// Lấy lịch sử theo độ khó
  Future<List<GameHistoryHive>> getHistoriesByDifficulty(String difficulty) async {
    final box = _hive.getGameHistoryBox();
    return box.values.where((h) => h.difficulty == difficulty && h.completed).toList();
  }

  /// Lấy thống kê tổng quan
  Future<Map<String, dynamic>> getOverallStats() async {
    final box = _hive.getGameHistoryBox();
    final all = box.values.toList();
    final completed = all.where((h) => h.completed).toList();

    final totalGames = all.length;
    final totalWins = completed.length;
    final totalTime = completed.fold<int>(0, (sum, h) => sum + h.timeSeconds);
    final winRate = totalGames > 0 ? (totalWins / totalGames * 100) : 0.0;

    return {
      'totalGames': totalGames,
      'totalWins': totalWins,
      'totalTime': totalTime,
      'winRate': winRate,
    };
  }

  /// Lấy thống kê theo độ khó
  Future<Map<String, dynamic>> getStatsByDifficulty(String difficulty) async {
    final histories = await getHistoriesByDifficulty(difficulty);

    if (histories.isEmpty) {
      return {
        'bestTime': null,
        'avgTime': null,
      };
    }

    final times = histories.map((h) => h.timeSeconds).toList();
    final bestTime = times.reduce((a, b) => a < b ? a : b);
    final avgTime = times.reduce((a, b) => a + b) ~/ times.length;

    return {
      'bestTime': bestTime,
      'avgTime': avgTime,
    };
  }

  /// Lấy thống kê theo tuần
  Future<List<int>> getWeeklyStats() async {
    final box = _hive.getGameHistoryBox();
    final now = DateTime.now();
    final weekData = List<int>.filled(7, 0);

    for (var history in box.values) {
      if (!history.completed) continue;

      final diff = now.difference(history.date).inDays;
      if (diff >= 0 && diff < 7) {
        weekData[6 - diff]++;
      }
    }

    return weekData;
  }

  /// Lấy chuỗi thắng hiện tại
  Future<int> getCurrentStreak() async {
    final box = _hive.getGameHistoryBox();
    final completed = box.values.where((h) => h.completed).toList();

    if (completed.isEmpty) return 0;

    completed.sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime? lastDate;

    for (var history in completed) {
      final date = DateTime(history.date.year, history.date.month, history.date.day);

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

  /// Lấy chuỗi thắng tốt nhất
  Future<int> getBestStreak() async {
    final box = _hive.getGameHistoryBox();
    final completed = box.values.where((h) => h.completed).toList();

    if (completed.isEmpty) return 0;

    completed.sort((a, b) => a.date.compareTo(b.date));

    int bestStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (var history in completed) {
      final date = DateTime(history.date.year, history.date.month, history.date.day);

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

  /// Lấy các ngày đã hoàn thành trong tháng
  Future<List<int>> getCompletedDaysInMonth(int year, int month) async {
    final box = _hive.getGameHistoryBox();
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    final Set<int> days = {};
    for (var history in box.values) {
      if (history.completed &&
          history.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          history.date.isBefore(endDate.add(const Duration(days: 1)))) {
        days.add(history.date.day);
      }
    }

    return days.toList()..sort();
  }

  /// Kiểm tra hôm nay đã hoàn thành daily challenge chưa
  Future<bool> isTodayCompleted() async {
    final box = _hive.getGameHistoryBox();
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return box.values.any((h) =>
        h.isDaily &&
        h.completed &&
        h.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
        h.date.isBefore(endOfDay));
  }

  /// Lấy Sudoku cho ngày cụ thể
  String getDailySudokuForDate(DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final sudokus = [
      '530070000600195000098000060800060003400803001700020006060000280000419005000080079',
      '003020600900305001001806400008102900700000008006708200002609500800203009005010300',
      '200080300060070084030500209000105408000000000402706000301007040720040060004010003',
      '000000907000420180000705026100904000050000040000507009920108000034059000507000000',
      '030050040008010500460000012070502080000603000040109030250000098001020600080060020',
    ];
    return sudokus[seed % sudokus.length];
  }

  /// Lấy độ khó cho ngày cụ thể
  String getDailyDifficultyForDate(DateTime date) {
    final dayOfWeek = date.weekday;
    if (dayOfWeek <= 2) return 'Dễ';
    if (dayOfWeek <= 4) return 'Trung bình';
    if (dayOfWeek == 5) return 'Khó';
    return 'Chuyên gia';
  }

  /// Lấy XP cho ngày cụ thể
  int getDailyXPForDate(DateTime date) {
    final difficulty = getDailyDifficultyForDate(date);
    return _getXPForDifficulty(difficulty);
  }

  /// Xóa tất cả lịch sử
  Future<void> clearHistory() async {
    final box = _hive.getGameHistoryBox();
    await box.clear();
  }

  // ===== GAME PROGRESS (SharedPreferences) =====
  // Lưu tiến trình game đang chơi để resume sau
  // Dùng SharedPreferences vì cần lưu/load nhanh

  /// Lưu tiến trình game đang chơi
  /// 
  /// Lưu vào SharedPreferences với key: game_progress_{sudokuKey}
  /// 
  /// Dữ liệu lưu:
  /// - sudokuKey: Chuỗi Sudoku (81 ký tự)
  /// - difficulty: Độ khó
  /// - cells: Tất cả 81 cells (x, y, number, solution, initial, notes)
  /// - secondsPlayed: Thời gian đã chơi
  /// - mistakes: Số lần sai
  /// - hintsUsed: Số lần gợi ý đã dùng
  /// - savedAt: Thời gian lưu
  Future<void> saveGameProgress({
    required String sudokuKey,
    required String difficulty,
    required List<Map<String, dynamic>> cells,
    required int secondsPlayed,
    required int mistakes,
    required int hintsUsed,
  }) async {
    final progress = {
      'sudokuKey': sudokuKey,
      'difficulty': difficulty,
      'cells': cells,
      'secondsPlayed': secondsPlayed,
      'mistakes': mistakes,
      'hintsUsed': hintsUsed,
      'savedAt': DateTime.now().toIso8601String(),
    };
    await _storage.setString('${_progressKey}_$sudokuKey', jsonEncode(progress));
  }

  /// Load tiến trình game đã lưu
  /// 
  /// Returns: Map chứa tiến trình hoặc null nếu không có
  Future<Map<String, dynamic>?> loadGameProgress(String sudokuKey) async {
    final jsonStr = _storage.getString('${_progressKey}_$sudokuKey');
    if (jsonStr == null) return null;
    try {
      return jsonDecode(jsonStr);
    } catch (e) {
      return null;
    }
  }

  /// Xóa tiến trình game đã lưu
  /// 
  /// Gọi khi:
  /// - Hoàn thành game
  /// - Bắt đầu game mới
  Future<void> clearGameProgress(String sudokuKey) async {
    await _storage.remove('${_progressKey}_$sudokuKey');
  }

  // ===== COMPATIBILITY METHODS =====
  // Các method để tương thích với UI cũ

  /// Kiểm tra Sudoku đã hoàn thành chưa
  /// 
  /// Tìm trong Hive xem có history nào với sudokuKey này và completed = true không
  Future<bool> isCompleted(String sudokuKey) async {
    final box = _hive.getGameHistoryBox();
    return box.values.any((h) => h.sudokuKey == sudokuKey && h.completed);
  }

  /// Lấy best time cho Sudoku cụ thể
  /// 
  /// Tìm trong Hive xem có history nào với sudokuKey này không
  /// Returns: Best time (seconds) hoặc null
  Future<int?> getBestTime(String sudokuKey) async {
    final box = _hive.getGameHistoryBox();
    final histories = box.values
        .where((h) => h.sudokuKey == sudokuKey && h.completed)
        .toList();
    
    if (histories.isEmpty) return null;
    
    // Tìm time nhỏ nhất
    return histories.map((h) => h.timeSeconds).reduce((a, b) => a < b ? a : b);
  }

  /// Lấy tiến trình theo độ khó
  /// 
  /// Returns:
  /// - completed: Số level đã hoàn thành
  /// - total: Tổng số level
  /// - percentage: % hoàn thành
  Future<Map<String, dynamic>> getProgress(String difficulty, int totalLevels) async {
    final histories = await getHistoriesByDifficulty(difficulty);
    final completed = histories.length;
    final percentage = totalLevels > 0 ? (completed / totalLevels * 100).round() : 0;
    return {
      'completed': completed,
      'total': totalLevels,
      'percentage': percentage,
    };
  }

  /// Lấy tổng tiến trình (tất cả độ khó)
  /// 
  /// Returns:
  /// - completed: Tổng số level đã hoàn thành
  /// - total: Tổng số level (500)
  /// - percentage: % hoàn thành
  Future<Map<String, dynamic>> getTotalProgress() async {
    final stats = await getOverallStats();
    final completed = stats['totalWins'] ?? 0;
    const totalLevels = 500;
    final percentage = totalLevels > 0 ? (completed / totalLevels * 100).round() : 0;
    return {
      'completed': completed,
      'total': totalLevels,
      'percentage': percentage,
    };
  }
}
