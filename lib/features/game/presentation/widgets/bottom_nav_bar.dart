import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  final String currentRoute;

  const BottomNavBar({
    super.key,
    required this.currentRoute,
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                Icons.calendar_today_outlined,
                'Hàng ngày',
                currentRoute == 'daily',
                isDark,
                () {
                  if (currentRoute != 'daily') {
                    context.push('/daily');
                  }
                },
              ),
              _buildNavItem(
                context,
                Icons.grid_view_outlined,
                'Màn chơi',
                currentRoute == 'select',
                isDark,
                () {
                  if (currentRoute != 'select') {
                    context.go('/select');
                  }
                },
              ),
              _buildNavItem(
                context,
                Icons.leaderboard_outlined,
                'Thống kê',
                currentRoute == 'stats',
                isDark,
                () {
                  if (currentRoute != 'stats') {
                    context.push('/stats');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
    bool isDark,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? const Color(0xFF1E3A4C) : const Color(0xFFCBE7F5))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive
                    ? const Color(0xFF005BC1)
                    : (isDark ? Colors.grey[400] : const Color(0xFF4A6273)),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: isActive
                      ? const Color(0xFF005BC1)
                      : (isDark ? Colors.grey[400] : const Color(0xFF4A6273)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
