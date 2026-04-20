import 'package:flutter/foundation.dart';
import 'hive_service.dart';
import '../models/settings_hive.dart';

/// SettingsService - Quản lý cài đặt người dùng
/// 
/// THAY ĐỔI: Đã chuyển sang Hive
/// - Dùng Hive thay vì SQLite
/// - Chạy được trên Web + Android + iOS + Desktop
/// - Đơn giản hơn SQLite
class SettingsService extends ChangeNotifier {
  static final SettingsService instance = SettingsService._internal();
  factory SettingsService() => instance;
  SettingsService._internal();

  final HiveService _hive = HiveService.instance;
  SettingsHive? _settings;

  /// Load settings từ Hive
  /// Gọi method này khi khởi động app
  Future<void> loadSettings() async {
    final box = _hive.getSettingsBox();
    _settings = box.get(HiveService.settingsKey);
    
    // Nếu chưa có settings, tạo mới với giá trị mặc định
    if (_settings == null) {
      _settings = SettingsHive();
      await box.put(HiveService.settingsKey, _settings!);
    }
    
    notifyListeners();
  }

  /// Lưu settings vào Hive
  Future<void> _saveSettings() async {
    if (_settings != null) {
      await _settings!.save(); // HiveObject có method save()
      notifyListeners();
    }
  }

  // ===== GETTERS =====

  /// Sound Effects - Bật/tắt âm thanh
  bool get soundEffects => _settings?.soundEffects ?? true;

  /// Timer Display - Hiển thị/ẩn đồng hồ
  bool get timerDisplay => _settings?.timerDisplay ?? true;

  /// Mistakes Limit - Giới hạn số lần sai (3 lần)
  bool get mistakesLimit => _settings?.mistakesLimit ?? false;

  /// Highlight Duplicates - Đánh dấu các số trùng
  bool get highlightDuplicates => _settings?.highlightDuplicates ?? true;

  /// Theme - Giao diện (light/dark)
  String get theme => _settings?.theme ?? 'light';

  /// Font Size - KHÔNG DÙNG NỮA
  String get fontSize => 'medium';

  /// Language - KHÔNG DÙNG NỮA
  String get language => 'Tiếng Việt';

  // ===== SETTERS =====

  /// Cập nhật Sound Effects
  Future<void> setSoundEffects(bool value) async {
    if (_settings != null) {
      _settings!.soundEffects = value;
      await _saveSettings();
    }
  }

  /// Cập nhật Timer Display
  Future<void> setTimerDisplay(bool value) async {
    if (_settings != null) {
      _settings!.timerDisplay = value;
      await _saveSettings();
    }
  }

  /// Cập nhật Mistakes Limit
  Future<void> setMistakesLimit(bool value) async {
    if (_settings != null) {
      _settings!.mistakesLimit = value;
      await _saveSettings();
    }
  }

  /// Cập nhật Highlight Duplicates
  Future<void> setHighlightDuplicates(bool value) async {
    if (_settings != null) {
      _settings!.highlightDuplicates = value;
      await _saveSettings();
    }
  }

  /// Cập nhật Theme
  Future<void> setTheme(String value) async {
    if (_settings != null) {
      _settings!.theme = value;
      await _saveSettings();
    }
  }

  /// Cập nhật Font Size - KHÔNG DÙNG NỮA
  Future<void> setFontSize(String value) async {
    // Do nothing
  }

  /// Cập nhật Language - KHÔNG DÙNG NỮA
  Future<void> setLanguage(String value) async {
    // Do nothing
  }

  /// Reset settings về mặc định
  Future<void> resetToDefault() async {
    _settings = SettingsHive();
    await _saveSettings();
  }
}
