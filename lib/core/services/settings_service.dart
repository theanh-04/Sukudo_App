import 'package:flutter/foundation.dart';
import 'storage_service.dart';

class SettingsService extends ChangeNotifier {
  static final SettingsService instance = SettingsService._internal();
  factory SettingsService() => instance;
  SettingsService._internal();

  final StorageService _storage = StorageService.instance;

  // Keys
  static const String _soundEffectsKey = 'sound_effects';
  static const String _timerDisplayKey = 'timer_display';
  static const String _mistakesLimitKey = 'mistakes_limit';
  static const String _highlightDuplicatesKey = 'highlight_duplicates';
  static const String _themeKey = 'theme'; // light, dark, system
  static const String _fontSizeKey = 'font_size'; // small, medium, large
  static const String _languageKey = 'language';

  // Sound Effects
  bool get soundEffects => _storage.getBool(_soundEffectsKey) ?? true;
  Future<void> setSoundEffects(bool value) async {
    await _storage.setBool(_soundEffectsKey, value);
    notifyListeners();
  }

  // Timer Display
  bool get timerDisplay => _storage.getBool(_timerDisplayKey) ?? true;
  Future<void> setTimerDisplay(bool value) async {
    await _storage.setBool(_timerDisplayKey, value);
    notifyListeners();
  }

  // Mistakes Limit
  bool get mistakesLimit => _storage.getBool(_mistakesLimitKey) ?? false;
  Future<void> setMistakesLimit(bool value) async {
    await _storage.setBool(_mistakesLimitKey, value);
    notifyListeners();
  }

  // Highlight Duplicates
  bool get highlightDuplicates => _storage.getBool(_highlightDuplicatesKey) ?? true;
  Future<void> setHighlightDuplicates(bool value) async {
    await _storage.setBool(_highlightDuplicatesKey, value);
    notifyListeners();
  }

  // Theme
  String get theme => _storage.getString(_themeKey) ?? 'light';
  Future<void> setTheme(String value) async {
    await _storage.setString(_themeKey, value);
    notifyListeners();
  }

  // Font Size
  String get fontSize => _storage.getString(_fontSizeKey) ?? 'medium';
  Future<void> setFontSize(String value) async {
    await _storage.setString(_fontSizeKey, value);
    notifyListeners();
  }

  // Language
  String get language => _storage.getString(_languageKey) ?? 'Tiếng Việt';
  Future<void> setLanguage(String value) async {
    await _storage.setString(_languageKey, value);
    notifyListeners();
  }
}
