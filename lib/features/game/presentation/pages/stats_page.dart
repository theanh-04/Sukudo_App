import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/difficulty.dart';
import '../../../../core/services/game_history_service.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/level_card.dart';
import '../widgets/achievements_section.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final GameHistoryService _historyService = GameHistoryService();
  
  Map<String, dynamic> _overallStats = {};
  List<int> _weeklyData = [];
  int _currentStreak = 0;
  int _bestStreak = 0;
  Map<String, Map<String, dynamic>> _difficultyStats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final overall = await _historyService.getOverallStats();
    final weekly = await _historyService.getWeeklyStats();
    final current = await _historyService.getCurrentStreak();
    final best = await _historyService.getBestStreak();
    
    final diffStats = <String, Map<String, dynamic>>{};
    for (var difficulty in Difficulty.values) {
      diffStats[difficulty.value] = await _historyService.getStatsByDifficulty(difficulty.displayName);
    }

    setState(() {
      _overallStats = overall;
      _weeklyData = weekly;
      _currentStreak = current;
      _bestStreak = best;
      _difficultyStats = diffStats;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thống kê',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level Card
            const LevelCard(),
            const SizedBox(height: 24),
            
            // Hero Stats Grid
            _buildHeroStats(isDark),
            const SizedBox(height: 32),
            
            // Achievements Section
            const AchievementsSection(),
            const SizedBox(height: 32),
            
            // Achievements (old - keep for streak)
            const Text(
              'Thành tích',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildAchievements(isDark),
            const SizedBox(height: 32),
            
            // Weekly Performance
            _buildWeeklyPerformance(isDark),
            const SizedBox(height: 32),
            
            // Difficulty Breakdown
            const Text(
              'Theo độ khó',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDifficultyBreakdown(isDark),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentRoute: 'stats'),
    );
  }

  Widget _buildHeroStats(bool isDark) {
    final totalGames = _overallStats['totalGames'] ?? 0;
    final totalTime = _overallStats['totalTime'] ?? 0;
    final winRate = _overallStats['winRate'] ?? 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.extension,
            label: 'SỐ VÁN CHƠI',
            value: totalGames.toString(),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.emoji_events,
            label: 'TỶ LỆ THẮNG',
            value: '${winRate.toStringAsFixed(1)}%',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.schedule,
            label: 'TỔNG THỜI GIAN',
            value: _formatTotalTime(totalTime),
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF005BC1),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: isDark ? Colors.grey[400] : const Color(0xFF596064),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F4F7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CHUỖI HIỆN TẠI',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          color: isDark ? Colors.grey[400] : const Color(0xFF596064),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_currentStreak Ván',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFCBE7F5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: Color(0xFF005BC1),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F4F7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KỶ LỤC',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          color: isDark ? Colors.grey[400] : const Color(0xFF596064),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_bestStreak Ván',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFCBE7F5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.military_tech,
                    color: Color(0xFF005BC1),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyPerformance(bool isDark) {
    final weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final maxValue = _weeklyData.isEmpty ? 1 : _weeklyData.reduce((a, b) => a > b ? a : b);
    final totalWins = _weeklyData.fold<int>(0, (sum, val) => sum + val);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hiệu suất tuần',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Thắng trong 7 ngày qua',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF596064),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    totalWins.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF005BC1),
                    ),
                  ),
                  Text(
                    'TỔNG THẮNG',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: isDark ? Colors.grey[400] : const Color(0xFF596064),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final value = _weeklyData.length > index ? _weeklyData[index] : 0;
                final height = maxValue > 0 ? (value / maxValue * 140) : 0.0;
                
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: height.clamp(0, 140),
                          decoration: BoxDecoration(
                            color: const Color(0xFF005BC1).withValues(
                              alpha: 0.2 + (value / (maxValue > 0 ? maxValue : 1) * 0.8),
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          weekDays[index],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[400] : const Color(0xFF596064),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyBreakdown(bool isDark) {
    final difficulties = [
      {'name': 'Dễ', 'key': 'easy', 'color': const Color(0xFF10B981)},
      {'name': 'Trung bình', 'key': 'medium', 'color': const Color(0xFFF59E0B)},
      {'name': 'Khó', 'key': 'hard', 'color': const Color(0xFFF97316)},
      {'name': 'Chuyên gia', 'key': 'expert', 'color': const Color(0xFFF43F5E)},
      {'name': 'Ác mộng', 'key': 'evil', 'color': const Color(0xFF991B1B)},
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F4F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'CẤP ĐỘ',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: Color(0xFF596064),
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'TỐT NHẤT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: Color(0xFF596064),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'TRUNG BÌNH',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: isDark ? Colors.grey[400] : const Color(0xFF596064),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...difficulties.asMap().entries.map((entry) {
            final index = entry.key;
            final diff = entry.value;
            final stats = _difficultyStats[diff['key']] ?? {};
            final bestTime = stats['bestTime'];
            final avgTime = stats['avgTime'];

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: index % 2 == 1
                    ? (isDark ? const Color(0xFF334155).withValues(alpha: 0.3) : const Color(0xFFE3E9ED).withValues(alpha: 0.3))
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: diff['color'] as Color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          diff['name'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      bestTime != null ? _formatTime(bestTime) : '--:--',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      avgTime != null ? _formatTime(avgTime) : '--:--',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatTotalTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }
}
