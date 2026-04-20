import 'package:hive_flutter/hive_flutter.dart';
import '../models/game_history_hive.dart';
import '../models/settings_hive.dart';

/// Hive Service - Quản lý Hive database
/// 
/// BOXES:
/// - gameHistory: Lưu lịch sử các ván chơi
/// - settings: Lưu cài đặt (chỉ 1 object)
/// 
/// Hive hoạt động trên: Web, Android, iOS, Desktop
class HiveService {
  static final HiveService instance = HiveService._internal();
  factory HiveService() => instance;
  HiveService._internal();

  // Box names
  static const String gameHistoryBox = 'gameHistory';
  static const String settingsBox = 'settings';
  static const String settingsKey = 'settings'; // Key cho settings object

  bool _initialized = false;

  /// Khởi tạo Hive
  /// 
  /// STEPS:
  /// 1. Init Hive Flutter
  /// 2. Register adapters
  /// 3. Open boxes
  Future<void> init() async {
    if (_initialized) return;

    // Step 1: Init Hive Flutter
    await Hive.initFlutter();

    // Step 2: Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(GameHistoryHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SettingsHiveAdapter());
    }

    // Step 3: Open boxes
    await Hive.openBox<GameHistoryHive>(gameHistoryBox);
    await Hive.openBox<SettingsHive>(settingsBox);

    _initialized = true;
  }

  /// Lấy game history box
  Box<GameHistoryHive> getGameHistoryBox() {
    return Hive.box<GameHistoryHive>(gameHistoryBox);
  }

  /// Lấy settings box
  Box<SettingsHive> getSettingsBox() {
    return Hive.box<SettingsHive>(settingsBox);
  }

  /// Đóng tất cả boxes
  Future<void> close() async {
    await Hive.close();
    _initialized = false;
  }

  /// Xóa tất cả data (dùng cho testing)
  Future<void> clearAll() async {
    await getGameHistoryBox().clear();
    await getSettingsBox().clear();
  }
}
