import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/cell.dart';
import '../../../../core/services/settings_service.dart';
import '../providers/sudoku_provider.dart';

class SudokuBoardNew extends StatelessWidget {
  final List<Cell> cells;

  const SudokuBoardNew({super.key, required this.cells});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SudokuProvider, SettingsService>(
      builder: (context, sudoku, settings, _) {
        if (cells.length != 81) {
          return const Center(child: Text('Lỗi: Bàn cờ không hợp lệ'));
        }

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4F7),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
              ),
              itemCount: 81,
              itemBuilder: (context, index) {
                final cell = cells[index];
                final isSelected = sudoku.selectedCell?.x == cell.x &&
                    sudoku.selectedCell?.y == cell.y;

                return _buildCell(context, cell, isSelected, sudoku, settings);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCell(
    BuildContext context,
    Cell cell,
    bool isSelected,
    SudokuProvider sudoku,
    SettingsService settings,
  ) {

    // Highlight logic
    final isHighlighted = sudoku.selectedCell != null &&
        (sudoku.selectedCell!.x == cell.x ||
            sudoku.selectedCell!.y == cell.y ||
            (sudoku.selectedCell!.x ~/ 3 == cell.x ~/ 3 &&
                sudoku.selectedCell!.y ~/ 3 == cell.y ~/ 3));

    final isSameNumber = sudoku.selectedCell != null &&
        cell.number != 0 &&
        cell.number == sudoku.selectedCell!.number;

    final conflicts = settings.highlightDuplicates
        ? sudoku.getConflictingCells(cell.x, cell.y)
        : <Cell>[];
    final hasConflict = conflicts.isNotEmpty && cell.number != 0;

    // Colors
    Color backgroundColor;
    if (isSelected) {
      backgroundColor = const Color(0xFFCBE7F5);
    } else if (isSameNumber) {
      backgroundColor = const Color(0xFFE3E9ED);
    } else if (isHighlighted) {
      backgroundColor = const Color(0xFFF0F4F7);
    } else {
      backgroundColor = Colors.white;
    }

    final textColor = hasConflict
        ? const Color(0xFFA83836)
        : cell.initial
            ? const Color(0xFF2C3437)
            : const Color(0xFF005BC1);

    // Borders for 3x3 blocks
    final hasThickRight = (cell.x + 1) % 3 == 0 && cell.x != 8;
    final hasThickBottom = (cell.y + 1) % 3 == 0 && cell.y != 8;

    return GestureDetector(
      onTap: () {
        sudoku.selectCell(cell.x, cell.y);
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            right: BorderSide(
              color: hasThickRight
                  ? const Color(0xFFD4DBDF)
                  : const Color(0xFFACB3B7).withValues(alpha: 0.15),
              width: hasThickRight ? 2 : 1,
            ),
            bottom: BorderSide(
              color: hasThickBottom
                  ? const Color(0xFFD4DBDF)
                  : const Color(0xFFACB3B7).withValues(alpha: 0.15),
              width: hasThickBottom ? 2 : 1,
            ),
          ),
        ),
        child: Center(
          child: cell.number != 0
              ? Text(
                  cell.number.toString(),
                  style: TextStyle(
                    fontSize: isSelected ? 24 : 20,
                    fontWeight: cell.initial ? FontWeight.bold : FontWeight.w600,
                    color: textColor,
                  ),
                )
              : cell.notes.isNotEmpty
                  ? _buildNotes(cell)
                  : null,
        ),
      ),
    );
  }

  Widget _buildNotes(Cell cell) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        final number = index + 1;
        final hasNote = cell.notes.contains(number);
        return Center(
          child: Text(
            hasNote ? number.toString() : '',
            style: const TextStyle(
              fontSize: 8,
              color: Color(0xFF596064),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }
}
