import 'package:flutter/material.dart';
import '../../../../core/models/cell.dart';
import '../../../../core/engine/sudoku_utility.dart';
import '../../../../core/services/settings_service.dart';

class SudokuProvider extends ChangeNotifier {
  List<Cell> _cells = [];
  List<List<Cell>> _history = [];
  int _historyIndex = -1;
  Cell? _selectedCell;
  bool _notesMode = false;
  int _mistakes = 0;
  final int _maxMistakes = 3;
  
  // Giới hạn số lần gợi ý
  int _hintsUsed = 0;
  final int _maxHints = 3; // Giới hạn 3 lần gợi ý

  List<Cell> get cells => _cells;
  Cell? get selectedCell => _selectedCell;
  bool get notesMode => _notesMode;
  bool get canUndo => _historyIndex < _history.length - 1;
  bool get canRedo => _historyIndex > 0;
  int get mistakes => _mistakes;
  int get maxMistakes => _maxMistakes;
  int get hintsUsed => _hintsUsed;
  int get maxHints => _maxHints;
  int get hintsRemaining => _maxHints - _hintsUsed;
  
  // Game over chỉ khi bật giới hạn sai
  bool get isGameOver {
    final settings = SettingsService.instance;
    return settings.mistakesLimit && _mistakes >= _maxMistakes;
  }

  void initSudoku(List<Cell> cells) {
    _cells = cells;
    _history = [_copyCells(cells)];
    _historyIndex = 0;
    _selectedCell = null;
    _notesMode = false;
    _mistakes = 0;
    _hintsUsed = 0; // Reset số lần gợi ý
    notifyListeners();
  }

  void selectCell(int x, int y) {
    try {
      _selectedCell = _cells.firstWhere((c) => c.x == x && c.y == y);
      notifyListeners();
    } catch (e) {
      // Cell không tồn tại, bỏ qua
    }
  }

  void setNumber(int number) {
    if (_selectedCell == null || _selectedCell!.initial || isGameOver) return;

    _addToHistory();

    final index = _cells.indexWhere(
      (c) => c.x == _selectedCell!.x && c.y == _selectedCell!.y,
    );

    if (_notesMode) {
      // Chế độ ghi chú
      final notes = List<int>.from(_cells[index].notes);
      if (notes.contains(number)) {
        notes.remove(number);
      } else {
        notes.add(number);
        notes.sort();
      }
      _cells[index] = _cells[index].copyWith(notes: notes);
    } else {
      // Chế độ thường - kiểm tra sai
      final isCorrect = _cells[index].solution == number;
      
      _cells[index] = _cells[index].copyWith(
        number: number,
        notes: [],
      );
      
      // Nếu sai, tăng mistakes
      if (!isCorrect) {
        _mistakes++;
      }
    }

    notifyListeners();
  }

  void eraseCell() {
    if (_selectedCell == null || _selectedCell!.initial || isGameOver) return;

    _addToHistory();

    final index = _cells.indexWhere(
      (c) => c.x == _selectedCell!.x && c.y == _selectedCell!.y,
    );

    _cells[index] = _cells[index].copyWith(number: 0, notes: []);
    notifyListeners();
  }

  void toggleNotesMode() {
    _notesMode = !_notesMode;
    notifyListeners();
  }

  /// Gợi ý - điền số đúng vào ô đang chọn
  /// 
  /// GIỚI HẠN:
  /// - Chỉ được dùng tối đa 3 lần (_maxHints)
  /// - Không thể dùng khi đã hết lượt gợi ý
  /// - Không thể dùng khi game over
  /// - Không thể dùng trên ô ban đầu
  void giveHint() {
    // Kiểm tra điều kiện
    if (_selectedCell == null || _selectedCell!.initial || isGameOver) return;
    
    // Kiểm tra đã hết lượt gợi ý chưa
    if (_hintsUsed >= _maxHints) {
      // Không thể gợi ý nữa
      return;
    }

    _addToHistory();

    final index = _cells.indexWhere(
      (c) => c.x == _selectedCell!.x && c.y == _selectedCell!.y,
    );

    // Điền số đúng vào ô
    _cells[index] = _cells[index].copyWith(
      number: _cells[index].solution,
      notes: [],
    );
    
    // Tăng số lần đã dùng gợi ý
    _hintsUsed++;

    notifyListeners();
  }

  void undo() {
    if (!canUndo) return;
    _historyIndex++;
    _cells = _copyCells(_history[_historyIndex]);
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;
    _historyIndex--;
    _cells = _copyCells(_history[_historyIndex]);
    notifyListeners();
  }

  void _addToHistory() {
    // Xóa các state sau historyIndex hiện tại
    _history = _history.sublist(_historyIndex);
    _history.insert(0, _copyCells(_cells));
    _historyIndex = 0;

    // Giới hạn history
    if (_history.length > 50) {
      _history = _history.sublist(0, 50);
    }
  }

  List<Cell> _copyCells(List<Cell> cells) {
    return cells.map((c) => c.copyWith()).toList();
  }

  bool isWon() {
    return SudokuUtility.isWon(_cells);
  }

  List<Cell> getConflictingCells(int x, int y) {
    return SudokuUtility.getConflictingCells(_cells, x, y);
  }
  
  // Reset mistakes (for restart)
  void resetMistakes() {
    _mistakes = 0;
    notifyListeners();
  }
  
  // Set mistakes (for resume)
  void setMistakes(int value) {
    _mistakes = value;
    notifyListeners();
  }
  
  // Reset hints (for restart)
  void resetHints() {
    _hintsUsed = 0;
    notifyListeners();
  }
  
  // Set hints (for resume)
  void setHintsUsed(int value) {
    _hintsUsed = value;
    notifyListeners();
  }
}
