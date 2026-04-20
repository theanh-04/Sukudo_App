import 'package:flutter/material.dart';

class GameControls extends StatelessWidget {
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback onErase;
  final VoidCallback onToggleNotes;
  final VoidCallback? onHint; // Có thể null khi hết lượt
  final bool notesMode;
  final int hintsRemaining; // Số lượt gợi ý còn lại

  const GameControls({
    super.key,
    this.onUndo,
    this.onRedo,
    required this.onErase,
    required this.onToggleNotes,
    required this.onHint,
    required this.notesMode,
    this.hintsRemaining = 3, // Mặc định 3 lượt
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildControlButton(
            context,
            icon: Icons.undo,
            label: 'Undo',
            onPressed: onUndo,
          ),
          _buildControlButton(
            context,
            icon: Icons.backspace_outlined,
            label: 'Erase',
            onPressed: onErase,
          ),
          _buildControlButton(
            context,
            icon: Icons.edit_outlined,
            label: 'Notes',
            onPressed: onToggleNotes,
            isActive: notesMode,
            showBadge: notesMode,
          ),
          _buildControlButton(
            context,
            icon: Icons.lightbulb_outline,
            label: 'Hint',
            onPressed: onHint,
            badgeText: hintsRemaining > 0 ? '$hintsRemaining' : null,
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
    bool showBadge = false,
    String? badgeText, // Text hiển thị trong badge (VD: số lượt còn lại)
  }) {
    final isEnabled = onPressed != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    size: 32,
                    color: isEnabled
                        ? (isActive
                            ? const Color(0xFF005BC1)
                            : const Color(0xFF49636F))
                        : const Color(0xFFACB3B7),
                  ),
                  // Badge "ON" cho notes mode
                  if (showBadge)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF005BC1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Text(
                          'ON',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  // Badge số lượt còn lại (cho hint)
                  if (badgeText != null)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: isEnabled ? const Color(0xFF005BC1) : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: isEnabled
                      ? const Color(0xFF747C80)
                      : const Color(0xFFACB3B7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
