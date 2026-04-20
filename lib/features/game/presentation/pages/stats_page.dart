/**
 * STATS_PAGE.DART
 * ===============
 * 
 * TỔNG QUAN:
 * Màn hình Thống kê - hiển thị các số liệu và thành tích của người chơi.
 * Bao gồm thống kê tổng quan, thành tích theo tuần, theo độ khó, và các achievements.
 * 
 * TÍNH NĂNG CHÍNH:
 * - Level Card: Hiển thị level và XP hiện tại của người chơi
 * - Hero Stats: 3 card hiển thị số ván chơi, tỷ lệ thắng, tổng thời gian
 * - Achievements Section: Các thành tích đã đạt được
 * - Streak Stats: Chuỗi thắng hiện tại và kỷ lục
 * - Weekly Performance: Biểu đồ cột hiển thị số ván thắng trong 7 ngày qua
 * - Difficulty Breakdown: Bảng thống kê theo từng độ khó (thời gian tốt nhất, trung bình)
 * 
 * LUỒNG HOẠT ĐỘNG:
 * 1. Load tất cả dữ liệu thống kê từ GameHistoryService khi khởi tạo
 * 2. Hiển thị các số liệu trong các section tương ứng
 * 3. Người dùng có thể xem chi tiết từng loại thống kê
 * 4. Có nút share để chia sẻ thành tích (chưa implement)
 * 
 * CẤU TRÚC UI:
 * - AppBar: Tiêu đề + nút back + nút share + nút settings
 * - Level Card: Card hiển thị level và progress bar XP
 * - Hero Stats Grid: 3 card hiển thị số liệu chính
 * - Achievements Section: Grid các achievement đã đạt được
 * - Streak Stats: 2 card hiển thị chuỗi hiện tại và kỷ lục
 * - Weekly Performance: Biểu đồ cột 7 ngày
 * - Difficulty Breakdown: Bảng thống kê theo độ khó
 * - Bottom Navigation Bar: Điều hướng giữa các màn hình chính
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/difficulty.dart';
import '../../../../core/services/game_history_service.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/level_card.dart';
import '../widgets/achievements_section.dart';

/// Widget chính của màn hình Thống kê
/// Sử dụng StatefulWidget để quản lý state của các số liệu thống kê
class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  // Service để truy vấn dữ liệu thống kê
  final GameHistoryService _historyService = GameHistoryService();
  
  // Thống kê tổng quan: totalGames, totalTime, winRate, ...
  Map<String, dynamic> _overallStats = {};
  
  // Dữ liệu 7 ngày qua: số ván thắng mỗi ngày [T2, T3, T4, T5, T6, T7, CN]
  List<int> _weeklyData = [];
  
  // Chuỗi thắng hiện tại (số ván thắng liên tiếp)
  int _currentStreak = 0;
  
  // Chuỗi thắng tốt nhất (kỷ lục)
  int _bestStreak = 0;
  
  // Thống kê theo từng độ khó: {easy: {bestTime, avgTime}, medium: {...}, ...}
  Map<String, Map<String, dynamic>> _difficultyStats = {};

  /// Lifecycle: Khởi tạo state khi widget được tạo
  /// Gọi _loadStats() để tải tất cả dữ liệu thống kê
  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  /// Tải tất cả dữ liệu thống kê từ GameHistoryService
  /// 
  /// LOGIC:
  /// 1. Load thống kê tổng quan (totalGames, winRate, totalTime)
  /// 2. Load dữ liệu 7 ngày qua (số ván thắng mỗi ngày)
  /// 3. Load chuỗi thắng hiện tại và kỷ lục
  /// 4. Load thống kê theo từng độ khó (bestTime, avgTime)
  /// 5. Cập nhật state để UI render lại
  Future<void> _loadStats() async {
    // Load thống kê tổng quan
    final overall = await _historyService.getOverallStats();
    
    // Load dữ liệu 7 ngày qua
    final weekly = await _historyService.getWeeklyStats();
    
    // Load chuỗi thắng
    final current = await _historyService.getCurrentStreak();
    final best = await _historyService.getBestStreak();
    
    // Load thống kê theo từng độ khó
    final diffStats = <String, Map<String, dynamic>>{};
    for (var difficulty in Difficulty.values) {
      diffStats[difficulty.value] = await _historyService.getStatsByDifficulty(difficulty.displayName);
    }

    // Cập nhật state
    setState(() {
      _overallStats = overall;
      _weeklyData = weekly;
      _currentStreak = current;
      _bestStreak = best;
      _difficultyStats = diffStats;
    });
  }

  /// Build UI chính của màn hình
  /// 
  /// CẤU TRÚC:
  /// - AppBar: Tiêu đề + nút back + nút share + nút settings
  /// - Body: ScrollView chứa các section thống kê
  ///   + Level Card: Level và XP
  ///   + Hero Stats: 3 card số liệu chính
  ///   + Achievements Section: Các thành tích
  ///   + Streak Stats: Chuỗi thắng
  ///   + Weekly Performance: Biểu đồ tuần
  ///   + Difficulty Breakdown: Bảng theo độ khó
  /// - Bottom Navigation Bar
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
          // Nút share (chưa implement)
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
          // Nút settings
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
            // 1. Level Card: Hiển thị level và XP
            const LevelCard(),
            const SizedBox(height: 24),
            
            // 2. Hero Stats Grid: 3 card số liệu chính
            _buildHeroStats(isDark),
            const SizedBox(height: 32),
            
            // 3. Achievements Section: Các thành tích đã đạt được
            const AchievementsSection(),
            const SizedBox(height: 32),
            
            // 4. Streak Stats: Chuỗi thắng hiện tại và kỷ lục
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
            
            // 5. Weekly Performance: Biểu đồ cột 7 ngày
            _buildWeeklyPerformance(isDark),
            const SizedBox(height: 32),
            
            // 6. Difficulty Breakdown: Bảng thống kê theo độ khó
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

  /// Build Hero Stats - 3 card hiển thị số liệu chính
  /// 
  /// HIỂN THỊ:
  /// - Card 1: Số ván chơi (totalGames)
  /// - Card 2: Tỷ lệ thắng (winRate %)
  /// - Card 3: Tổng thời gian (totalTime)
  /// 
  /// Mỗi card có: icon, label, value
  Widget _buildHeroStats(bool isDark) {
    final totalGames = _overallStats['totalGames'] ?? 0;
    final totalTime = _overallStats['totalTime'] ?? 0;
    final winRate = _overallStats['winRate'] ?? 0.0;

    return Row(
      children: [
        // Card 1: Số ván chơi
        Expanded(
          child: _buildStatCard(
            icon: Icons.extension,
            label: 'SỐ VÁN CHƠI',
            value: totalGames.toString(),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 16),
        
        // Card 2: Tỷ lệ thắng
        Expanded(
          child: _buildStatCard(
            icon: Icons.emoji_events,
            label: 'TỶ LỆ THẮNG',
            value: '${winRate.toStringAsFixed(1)}%',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 16),
        
        // Card 3: Tổng thời gian
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

  /// Build một stat card với icon, label và value
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
          // Icon
          Icon(
            icon,
            color: const Color(0xFF005BC1),
            size: 32,
          ),
          const SizedBox(height: 8),
          
          // Label
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
          
          // Value
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

  /// Build Achievements - 2 card hiển thị chuỗi thắng hiện tại và kỷ lục
  /// 
  /// HIỂN THỊ:
  /// - Card 1: Chuỗi hiện tại + icon lửa
  /// - Card 2: Kỷ lục + icon huy chương
  Widget _buildAchievements(bool isDark) {
    return Row(
      children: [
        // Card 1: Chuỗi hiện tại
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
                // Icon lửa
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
        
        // Card 2: Kỷ lục
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
                // Icon huy chương
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

  /// Build Weekly Performance - biểu đồ cột hiển thị số ván thắng trong 7 ngày qua
  /// 
  /// HIỂN THỊ:
  /// - Tiêu đề "Hiệu suất tuần" + tổng số thắng
  /// - Biểu đồ cột 7 ngày (T2-CN)
  /// - Chiều cao cột tỷ lệ với số ván thắng
  /// - Màu cột đậm dần theo số ván thắng
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
          // Header: Tiêu đề + tổng số thắng
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
          
          // Biểu đồ cột 7 ngày
          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final value = _weeklyData.length > index ? _weeklyData[index] : 0;
                // Tính chiều cao cột tỷ lệ với giá trị max
                final height = maxValue > 0 ? (value / maxValue * 140) : 0.0;
                
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Cột với chiều cao và màu tỷ lệ
                        Container(
                          height: height.clamp(0, 140),
                          decoration: BoxDecoration(
                            // Màu đậm dần theo giá trị (0.2 - 1.0 alpha)
                            color: const Color(0xFF005BC1).withValues(
                              alpha: 0.2 + (value / (maxValue > 0 ? maxValue : 1) * 0.8),
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Label ngày (T2, T3, ...)
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

  /// Build Difficulty Breakdown - bảng thống kê theo từng độ khó
  /// 
  /// HIỂN THỊ:
  /// - Header: CẤP ĐỘ | TỐT NHẤT | TRUNG BÌNH
  /// - 5 rows cho 5 độ khó: Dễ, Trung bình, Khó, Chuyên gia, Ác mộng
  /// - Mỗi row: chấm màu + tên độ khó + thời gian tốt nhất + thời gian trung bình
  /// - Rows xen kẽ màu background để dễ đọc
  Widget _buildDifficultyBreakdown(bool isDark) {
    // Danh sách các độ khó với màu tương ứng
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
          // Header row: CẤP ĐỘ | TỐT NHẤT | TRUNG BÌNH
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
          
          // Data rows: Mỗi độ khó một row
          ...difficulties.asMap().entries.map((entry) {
            final index = entry.key;
            final diff = entry.value;
            final stats = _difficultyStats[diff['key']] ?? {};
            final bestTime = stats['bestTime'];
            final avgTime = stats['avgTime'];

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              // Xen kẽ màu background cho các row chẵn
              decoration: BoxDecoration(
                color: index % 2 == 1
                    ? (isDark ? const Color(0xFF334155).withValues(alpha: 0.3) : const Color(0xFFE3E9ED).withValues(alpha: 0.3))
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  // Cột 1: Chấm màu + tên độ khó
                  Expanded(
                    child: Row(
                      children: [
                        // Chấm màu
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: diff['color'] as Color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Tên độ khó
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
                  
                  // Cột 2: Thời gian tốt nhất
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
                  
                  // Cột 3: Thời gian trung bình
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

  /// Format thời gian từ giây sang MM:SS
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Format tổng thời gian từ giây sang Xh Ym
  String _formatTotalTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }
}
