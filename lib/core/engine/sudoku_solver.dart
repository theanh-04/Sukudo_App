class SudokuSolver {
  static const List<int> sudokuNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  
  // Bảng các ô trong mỗi khối 3x3
  static final List<List<List<int>>> squareTable = _buildSquareTable();

  static List<List<List<int>>> _buildSquareTable() {
    final Map<int, List<List<int>>> grouped = {};
    
    for (int y = 0; y < 9; y++) {
      for (int x = 0; x < 9; x++) {
        final squareIdx = (y ~/ 3) * 3 + (x ~/ 3);
        grouped.putIfAbsent(squareIdx, () => []);
        grouped[squareIdx]!.add([x, y]);
      }
    }
    
    return List.generate(9, (i) => grouped[i]!);
  }

  static int squareIndex(int x, int y) {
    return (y ~/ 3) * 3 + (x ~/ 3);
  }

  // Giải Sudoku bằng thuật toán AC3
  static SolveResult solve(List<List<int>> grid) {
    final stack = [_toDomainSudoku(grid)];
    return _solveGridAC3(stack, 0);
  }

  static List<List<List<int>>> _toDomainSudoku(List<List<int>> grid) {
    return grid.map((row) {
      return row.map((cell) {
        return cell == 0 ? List<int>.from(sudokuNumbers) : <int>[cell];
      }).toList();
    }).toList();
  }

  static List<List<int>> _toSimpleSudoku(List<List<List<int>>> grid) {
    return grid.map((row) {
      return row.map((cells) {
        return cells.length == 1 ? cells[0] : 0;
      }).toList();
    }).toList();
  }

  static SolveResult _solveGridAC3(
    List<List<List<List<int>>>> stack,
    int iterations,
  ) {
    while (stack.isNotEmpty) {
      var grid = stack.removeAt(0);
      
      iterations++;
      if (iterations > 4000) {
        return SolveResult(
          sudoku: _toSimpleSudoku(grid),
          iterations: double.infinity.toInt(),
        );
      }

      final ac3Result = _ac3(grid);
      if (!ac3Result.solvable) {
        continue;
      }
      grid = ac3Result.sudoku;

      // Kiểm tra xem đã điền đầy chưa
      final isFilled = grid.every((row) {
        return row.every((cells) => cells.length == 1);
      });

      if (isFilled) {
        return SolveResult(
          sudoku: _toSimpleSudoku(grid),
          iterations: iterations,
        );
      }

      // Tìm ô có ít khả năng nhất (MRV heuristic)
      final possibleCells = <List<int>>[];
      for (int y = 0; y < 9; y++) {
        for (int x = 0; x < 9; x++) {
          if (grid[y][x].length > 1) {
            possibleCells.add([y, x, grid[y][x].length]);
          }
        }
      }

      possibleCells.sort((a, b) => a[2].compareTo(b[2]));
      final bestCell = possibleCells.first;
      final rowIndex = bestCell[0];
      final cellIndex = bestCell[1];
      final cell = grid[rowIndex][cellIndex];

      // Tạo grid mới cho mỗi khả năng
      final newGrids = cell.map((n) {
        return grid.map((row) {
          return row.map((cells) => List<int>.from(cells)).toList();
        }).toList()
          ..[rowIndex][cellIndex] = [n];
      }).toList();

      stack.insertAll(0, newGrids);
    }

    return SolveResult(sudoku: null, iterations: double.infinity.toInt());
  }

  static AC3Result _ac3(List<List<List<int>>> sudoku) {
    sudoku = sudoku.map((r) => r.map((c) => List<int>.from(c)).toList()).toList();

    while (true) {
      bool change = false;

      for (int y = 0; y < 9; y++) {
        for (int x = 0; x < 9; x++) {
          var domain1 = sudoku[y][x];

          final coordinates = <List<int>>[];

          // Các ô cùng hàng
          for (int xx = 0; xx < 9; xx++) {
            if (xx != x) coordinates.add([y, xx]);
          }

          // Các ô cùng cột
          for (int yy = 0; yy < 9; yy++) {
            if (yy != y) coordinates.add([yy, x]);
          }

          // Các ô cùng khối 3x3
          final square = squareTable[squareIndex(x, y)];
          for (final s in square) {
            final xx = s[0];
            final yy = s[1];
            if (xx != x || yy != y) {
              coordinates.add([yy, xx]);
            }
          }

          for (final coord in coordinates) {
            final yy = coord[0];
            final xx = coord[1];
            final domain2 = sudoku[yy][xx];

            if (domain2.length == 1) {
              final index = domain1.indexOf(domain2[0]);
              if (index != -1) {
                domain1.removeAt(index);
                change = true;
              }
            }

            sudoku[y][x] = domain1;
          }

          if (domain1.isEmpty) {
            return AC3Result(sudoku: sudoku, solvable: false);
          }
        }
      }

      if (!change) break;
    }

    return AC3Result(sudoku: sudoku, solvable: true);
  }
}

class SolveResult {
  final List<List<int>>? sudoku;
  final int iterations;

  SolveResult({required this.sudoku, required this.iterations});
}

class AC3Result {
  final List<List<List<int>>> sudoku;
  final bool solvable;

  AC3Result({required this.sudoku, required this.solvable});
}
