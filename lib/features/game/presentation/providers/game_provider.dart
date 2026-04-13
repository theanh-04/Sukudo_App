import 'package:flutter/material.dart';
import '../../../../core/services/storage_service.dart';

enum GameState { running, paused, won }

class GameProvider extends ChangeNotifier {
  GameState _state = GameState.running;
  int _secondsPlayed = 0;
  bool _won = false;
  int _timesSolved = 0;
  List<int> _previousTimes = [];
  String? _currentSudokuKey;

  GameState get state => _state;
  int get secondsPlayed => _secondsPlayed;
  bool get won => _won;
  int get timesSolved => _timesSolved;
  List<int> get previousTimes => _previousTimes;

  void startGame(String sudokuKey) {
    _currentSudokuKey = sudokuKey;
    _state = GameState.running;
    _won = false;
    _loadGameState();
    notifyListeners();
  }

  void pauseGame() {
    _state = GameState.paused;
    _saveGameState();
    notifyListeners();
  }

  void resumeGame() {
    _state = GameState.running;
    notifyListeners();
  }

  void wonGame() {
    _state = GameState.won;
    _won = true;
    _timesSolved++;
    _previousTimes.add(_secondsPlayed);
    _saveGameState();
    notifyListeners();
  }

  void updateTime(int seconds) {
    _secondsPlayed = seconds;
    notifyListeners();
  }

  void resetGame() {
    _secondsPlayed = 0;
    _won = false;
    _state = GameState.running;
    notifyListeners();
  }

  Future<void> _loadGameState() async {
    if (_currentSudokuKey == null) return;

    final storage = StorageService.instance;
    final key = 'game_$_currentSudokuKey';
    final data = storage.getJson(key);

    if (data != null) {
      _secondsPlayed = data['secondsPlayed'] ?? 0;
      _won = data['won'] ?? false;
      _timesSolved = data['timesSolved'] ?? 0;
      _previousTimes = List<int>.from(data['previousTimes'] ?? []);
      
      if (_won) {
        _state = GameState.won;
      }
    }
  }

  Future<void> _saveGameState() async {
    if (_currentSudokuKey == null) return;

    final storage = StorageService.instance;
    final key = 'game_$_currentSudokuKey';

    await storage.setJson(key, {
      'secondsPlayed': _secondsPlayed,
      'won': _won,
      'timesSolved': _timesSolved,
      'previousTimes': _previousTimes,
    });
  }
}
