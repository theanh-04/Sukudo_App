import 'package:flutter/material.dart';
import '../../../../core/services/storage_service.dart';

class PreferencesProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _showHints = true;
  bool _showConflicts = true;
  bool _showTimer = true;
  bool _highlightSameNumbers = true;

  bool get isDarkMode => _isDarkMode;
  bool get showHints => _showHints;
  bool get showConflicts => _showConflicts;
  bool get showTimer => _showTimer;
  bool get highlightSameNumbers => _highlightSameNumbers;

  PreferencesProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final storage = StorageService.instance;
    _isDarkMode = storage.getBool('dark_mode') ?? false;
    _showHints = storage.getBool('show_hints') ?? true;
    _showConflicts = storage.getBool('show_conflicts') ?? true;
    _showTimer = storage.getBool('show_timer') ?? true;
    _highlightSameNumbers = storage.getBool('highlight_same_numbers') ?? true;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await StorageService.instance.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setShowHints(bool value) async {
    _showHints = value;
    await StorageService.instance.setBool('show_hints', value);
    notifyListeners();
  }

  Future<void> setShowConflicts(bool value) async {
    _showConflicts = value;
    await StorageService.instance.setBool('show_conflicts', value);
    notifyListeners();
  }

  Future<void> setShowTimer(bool value) async {
    _showTimer = value;
    await StorageService.instance.setBool('show_timer', value);
    notifyListeners();
  }

  Future<void> setHighlightSameNumbers(bool value) async {
    _highlightSameNumbers = value;
    await StorageService.instance.setBool('highlight_same_numbers', value);
    notifyListeners();
  }
}
