import 'package:flutter/material.dart';
import '../../../../core/services/level_service.dart';

class AchievementsSection extends StatelessWidget {
  const AchievementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FutureBuilder<LevelInfo>(
      future: LevelService().getLevelInfo(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final info = snapshot.data!;
        final levelService = LevelService();
        final unlockedAchievements = levelService.getAchievements(info.level);
        final lockedAchievements = levelService.getLockedAchievements(info.level);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thành tựu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1A1D1F),
              ),
            ),
            const SizedBox(height: 16),
            // Unlocked achievements
            if (unlockedAchievements.isNotEmpty) ...[
              Text(
                'Đã mở khóa (${unlockedAchievements.length})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : const Color(0xFF596064),
                ),
              ),
              const SizedBox(height: 12),
              ...unlockedAchievements.map((achievement) => _buildAchievementCard(
                achievement: achievement,
                isLocked: false,
                isDark: isDark,
              )),
              const SizedBox(height: 20),
            ],
            // Locked achievements
            if (lockedAchievements.isNotEmpty) ...[
              Text(
                'Chưa mở khóa (${lockedAchievements.length})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : const Color(0xFF596064),
                ),
              ),
              const SizedBox(height: 12),
              ...lockedAchievements.map((achievement) => _buildAchievementCard(
                achievement: achievement,
                isLocked: true,
                isDark: isDark,
              )),
            ],
          ],
        );
      },
    );
  }

  Widget _buildAchievementCard({
    required Achievement achievement,
    required bool isLocked,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLocked
            ? (isDark ? const Color(0xFF1E293B).withValues(alpha: 0.5) : const Color(0xFFF7F9FB))
            : (isDark ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked
              ? (isDark ? Colors.grey[800]! : const Color(0xFFE3E9ED))
              : const Color(0xFF005BC1).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isLocked
                  ? (isDark ? Colors.grey[800] : const Color(0xFFE3E9ED))
                  : const Color(0xFF005BC1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                isLocked ? '🔒' : achievement.icon,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isLocked
                        ? (isDark ? Colors.grey[600] : const Color(0xFF9CA3AF))
                        : (isDark ? Colors.white : const Color(0xFF1A1D1F)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isLocked
                        ? (isDark ? Colors.grey[700] : const Color(0xFFBFC5CA))
                        : (isDark ? Colors.grey[400] : const Color(0xFF596064)),
                  ),
                ),
              ],
            ),
          ),
          // Level badge
          if (isLocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : const Color(0xFFE3E9ED),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Lv.${achievement.requiredLevel}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.grey[600] : const Color(0xFF596064),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
