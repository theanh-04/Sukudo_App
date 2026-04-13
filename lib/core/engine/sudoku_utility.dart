import '../models/cell.dart';

class SudokuUtility {
  static const List<int> sudokuCoordinates = [0, 1, 2, 3, 4, 5, 6, 7, 8];
  static const List<int> sudokuNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 9];

  // Chuyển đổi SimpleSudoku thành danh sách Cell
  static List<Cell> simpleSudokuToCells(
    List<List<int>> grid,
    List<List<int>>? solution,
  ) {
    final cells = <Cell>[];
    for (int y = 0; y < 9; y++) {
      for (int x = 0; x < 9; x++) {
        final number = grid[y][x];
        cells.add(Cell(
          x: x,
          y: y,
          number: number,
          notes: [],
          initial: number != 0,
          solution: solution != null ? solution[y][x] : 0,
        ));
      }
    }
    return cells;
  }

  // Chuyển đổi danh sách Cell thành SimpleSudoku
  static List<List<int>> cellsToSimpleSudoku(List<Cell> cells) {
    final simple = List.generate(9, (_) => List.filled(9, 0));
    for (final cell in cells) {
      if (cell.initial) {
        simple[cell.y][cell.x] = cell.number;
      }
    }
    return simple;
  }

  // Chuyển đổi SimpleSudoku thành chuỗi
  static String stringifySudoku(List<List<int>> grid) {
    return grid.map((row) => row.map((c) => c.toString()).join('')).join('');
  }

  // Parse chuỗi thành SimpleSudoku
  static List<List<int>> parseSudoku(String sudoku) {
    if (sudoku.length != 81) {
      throw Exception(
        'Dữ liệu không hợp lệ, chỉ cho phép 81 ký tự, nhưng tìm thấy ${sudoku.length} ký tự',
      );
    }

    for (final char in sudoku.split('')) {
      if (!['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'].contains(char)) {
        throw Exception('Dữ liệu không hợp lệ, chỉ cho phép 0-9, nhưng tìm thấy $char');
      }
    }

    final lines = <String>[];
    for (int i = 0; i < 9; i++) {
      lines.add(sudoku.substring(i * 9, (i + 1) * 9));
    }

    return lines.map((line) {
      return line.split('').map((c) => int.parse(c)).toList();
    }).toList();
  }

  // Kiểm tra xung đột
  static bool hasConflict(List<Cell> cells, int x, int y, int number) {
    if (number == 0) return false;

    for (final cell in cells) {
      if (cell.x == x && cell.y == y) continue;
      if (cell.number == 0) continue;

      // Cùng hàng
      if (cell.y == y && cell.number == number) return true;

      // Cùng cột
      if (cell.x == x && cell.number == number) return true;

      // Cùng khối 3x3
      if ((cell.x ~/ 3) == (x ~/ 3) &&
          (cell.y ~/ 3) == (y ~/ 3) &&
          cell.number == number) {
        return true;
      }
    }

    return false;
  }

  // Lấy các ô xung đột
  static List<Cell> getConflictingCells(List<Cell> cells, int x, int y) {
    final cell = cells.firstWhere((c) => c.x == x && c.y == y);
    if (cell.number == 0) return [];

    final conflicts = <Cell>[];
    for (final c in cells) {
      if (c.x == x && c.y == y) continue;
      if (c.number == 0) continue;

      // Cùng hàng, cột hoặc khối
      if (c.y == y || c.x == x || 
          ((c.x ~/ 3) == (x ~/ 3) && (c.y ~/ 3) == (y ~/ 3))) {
        if (c.number == cell.number) {
          conflicts.add(c);
        }
      }
    }

    return conflicts;
  }

  // Kiểm tra đã thắng chưa
  static bool isWon(List<Cell> cells) {
    return cells.every((cell) => cell.number != 0 && cell.number == cell.solution);
  }
}
