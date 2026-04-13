import 'package:flutter/material.dart';

class SudokuControls extends StatelessWidget {
  final Function(int) onNumberSelected;
  final VoidCallback onErase;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onHint;
  final VoidCallback onToggleNotes;
  final bool notesMode;
  final bool canUndo;
  final bool canRedo;

  const SudokuControls({
    super.key,
    required this.onNumberSelected,
    required this.onErase,
    required this.onUndo,
    required this.onRedo,
    required this.onHint,
    required this.onToggleNotes,
    required this.notesMode,
    required this.canUndo,
    required this.canRedo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Các nút điều khiển
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                context,
                icon: Icons.undo,
                label: 'Hoàn tác',
                onPressed: canUndo ? onUndo : null,
              ),
              _buildControlButton(
                context,
                icon: Icons.redo,
                label: 'Làm lại',
                onPressed: canRedo ? onRedo : null,
              ),
              _buildControlButton(
                context,
                icon: Icons.backspace,
                label: 'Xóa',
                onPressed: onErase,
              ),
              _buildControlButton(
                context,
                icon: notesMode ? Icons.edit : Icons.edit_outlined,
                label: 'Ghi chú',
                onPressed: onToggleNotes,
                isActive: notesMode,
              ),
              _buildControlButton(
                context,
                icon: Icons.lightbulb,
                label: 'Gợi ý',
                onPressed: onHint,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Bàn phím số
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(9, (index) {
              final number = index + 1;
              return _buildNumberButton(context, number);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isActive = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          color: isActive ? theme.colorScheme.primary : null,
          style: IconButton.styleFrom(
            backgroundColor: isActive
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : null,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildNumberButton(BuildContext context, int number) {
    return SizedBox(
      width: 36,
      height: 36,
      child: ElevatedButton(
        onPressed: () => onNumberSelected(number),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          number.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
