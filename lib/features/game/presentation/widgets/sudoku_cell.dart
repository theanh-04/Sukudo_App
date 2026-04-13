import 'package:flutter/material.dart';
import '../../../../core/models/cell.dart';

class SudokuCell extends StatelessWidget {
  final Cell cell;
  final bool isSelected;
  final bool isHighlighted;
  final bool isSameNumber;
  final bool hasConflict;
  final VoidCallback onTap;

  const SudokuCell({
    super.key,
    required this.cell,
    required this.isSelected,
    required this.isHighlighted,
    required this.isSameNumber,
    required this.hasConflict,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color backgroundColor;
    if (isSelected) {
      backgroundColor = theme.colorScheme.primary.withValues(alpha: 0.3);
    } else if (isSameNumber) {
      backgroundColor = theme.colorScheme.primary.withValues(alpha: 0.15);
    } else if (isHighlighted) {
      backgroundColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
    } else {
      backgroundColor = theme.scaffoldBackgroundColor;
    }

    final textColor = hasConflict
        ? Colors.red
        : cell.initial
            ? (isDark ? Colors.white : Colors.black)
            : theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            right: BorderSide(
              color: (cell.x + 1) % 3 == 0 ? Colors.black : Colors.grey,
              width: (cell.x + 1) % 3 == 0 ? 2 : 0.5,
            ),
            bottom: BorderSide(
              color: (cell.y + 1) % 3 == 0 ? Colors.black : Colors.grey,
              width: (cell.y + 1) % 3 == 0 ? 2 : 0.5,
            ),
          ),
        ),
        child: Center(
          child: cell.number != 0
              ? Text(
                  cell.number.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: cell.initial ? FontWeight.bold : FontWeight.normal,
                    color: textColor,
                  ),
                )
              : cell.notes.isNotEmpty
                  ? _buildNotes()
                  : null,
        ),
      ),
    );
  }

  Widget _buildNotes() {
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
            style: const TextStyle(fontSize: 8, color: Colors.grey),
          ),
        );
      },
    );
  }
}
