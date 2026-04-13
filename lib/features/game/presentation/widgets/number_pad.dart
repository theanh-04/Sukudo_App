import 'package:flutter/material.dart';

class NumberPad extends StatelessWidget {
  final Function(int) onNumberSelected;
  final int selectedNumber;

  const NumberPad({
    super.key,
    required this.onNumberSelected,
    this.selectedNumber = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F172A).withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFDCE4E8).withValues(alpha: 0.15),
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hàng 1: 1 2 3
          _buildNumberRow(context, [1, 2, 3], isDark),
          const SizedBox(height: 6),
          // Hàng 2: 4 5 6
          _buildNumberRow(context, [4, 5, 6], isDark),
          const SizedBox(height: 6),
          // Hàng 3: 7 8 9
          _buildNumberRow(context, [7, 8, 9], isDark),
        ],
      ),
    );
  }

  Widget _buildNumberRow(BuildContext context, List<int> numbers, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) {
        final isSelected = selectedNumber == number;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: _buildNumberButton(
              context,
              number,
              isSelected,
              isDark,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumberButton(
    BuildContext context,
    int number,
    bool isSelected,
    bool isDark,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onNumberSelected(number),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 48, // Chiều cao cố định, nhỏ hơn
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF005BC1),
                      Color(0xFF3D89FF),
                    ],
                  )
                : null,
            color: isSelected
                ? null
                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F4F7)),
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF005BC1).withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                fontSize: 20, // Font nhỏ hơn
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF005BC1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
