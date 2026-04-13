import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/cell.dart';
import '../providers/sudoku_provider.dart';
import '../../../../core/services/settings_service.dart';
import 'sudoku_cell.dart';

class SudokuBoard extends StatelessWidget {
  final List<Cell> cells;

  const SudokuBoard({super.key, required this.cells});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SudokuProvider, SettingsService>(
      builder: (context, sudoku, settings, _) {
        // Kiểm tra cells có đủ 81 ô không
        if (cells.length != 81) {
          return const Center(
            child: Text('Lỗi: Bàn cờ không hợp lệ'),
          );
        }

        return AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
              ),
              itemCount: 81,
              itemBuilder: (context, index) {
                final cell = cells[index];
                final isSelected = sudoku.selectedCell?.x == cell.x &&
                    sudoku.selectedCell?.y == cell.y;

                // Highlight cùng hàng, cột, khối
                final isHighlighted = sudoku.selectedCell != null &&
                    (sudoku.selectedCell!.x == cell.x ||
                        sudoku.selectedCell!.y == cell.y ||
                        (sudoku.selectedCell!.x ~/ 3 == cell.x ~/ 3 &&
                            sudoku.selectedCell!.y ~/ 3 == cell.y ~/ 3));

                // Highlight cùng số
                final isSameNumber = settings.highlightDuplicates &&
                    sudoku.selectedCell != null &&
                    cell.number != 0 &&
                    cell.number == sudoku.selectedCell!.number;

                // Kiểm tra xung đột
                final conflicts = settings.highlightDuplicates
                    ? sudoku.getConflictingCells(cell.x, cell.y)
                    : <Cell>[];
                final hasConflict = conflicts.isNotEmpty;

                return SudokuCell(
                  cell: cell,
                  isSelected: isSelected,
                  isHighlighted: isHighlighted,
                  isSameNumber: isSameNumber,
                  hasConflict: hasConflict,
                  onTap: () {
                    sudoku.selectCell(cell.x, cell.y);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
