import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/difficulty.dart';
import '../../../../core/services/game_history_service.dart';
import '../../../../core/services/level_service.dart';
import '../widgets/bottom_nav_bar.dart';

class SelectGamePage extends StatefulWidget {
  const SelectGamePage({super.key});

  @override
  State<SelectGamePage> createState() => _SelectGamePageState();
}

class _SelectGamePageState extends State<SelectGamePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;
  final GameHistoryService _historyService = GameHistoryService();
  
  Map<String, dynamic> _totalProgress = {
    'completed': 0,
    'total': 0,
    'percentage': 0,
  };
  
  Map<String, dynamic> _currentProgress = {
    'completed': 0,
    'total': 0,
    'percentage': 0,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTab = _tabController.index;
        });
        _loadProgress();
      }
    });
    _loadProgress();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final total = await _historyService.getTotalProgress();
    final current = await _historyService.getProgress(
      Difficulty.values[_selectedTab].value,
      100, // Giả sử mỗi difficulty có 100 levels
    );

    setState(() {
      _totalProgress = total;
      _currentProgress = current;
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
          'Chọn màn chơi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          // Level Badge
          FutureBuilder<LevelInfo>(
            future: LevelService().getLevelInfo(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox(width: 48);
              
              final info = snapshot.data!;
              return GestureDetector(
                onTap: () => context.push('/stats'),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF005BC1), Color(0xFF0077ED)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '⭐',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Lv.${info.level}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Difficulty Tabs
          _buildDifficultyTabs(isDark),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Progress Card
                  _buildProgressCard(isDark),
                  const SizedBox(height: 24),
                  // Level Grid
                  _buildLevelGrid(isDark),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentRoute: 'select'),
    );
  }

  Widget _buildDifficultyTabs(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: Difficulty.values.asMap().entries.map((entry) {
            final index = entry.key;
            final difficulty = entry.value;
            final isSelected = _selectedTab == index;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _tabController.animateTo(index);
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF005BC1)
                          : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F4F7)),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF005BC1).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      difficulty.displayName.toUpperCase(),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.grey[400] : const Color(0xFF596064)),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProgressCard(bool isDark) {
    final percentage = _currentProgress['percentage'] ?? 0;
    final completed = _currentProgress['completed'] ?? 0;
    final total = _currentProgress['total'] ?? 100;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F4F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TIẾN TRÌNH CỦA BẠN',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: isDark ? Colors.grey[400] : const Color(0xFF49636F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$percentage% Hoàn thành',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 6,
              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFDCE4E8),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF005BC1)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$completed trong $total màn đã hoàn thành',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : const Color(0xFF596064),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelGrid(bool isDark) {
    return FutureBuilder<List<String>>(
      future: _loadSudokus(Difficulty.values[_selectedTab]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có Sudoku'));
        }

        final sudokus = snapshot.data!;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: sudokus.length > 30 ? 30 : sudokus.length,
          itemBuilder: (context, index) {
            return _buildLevelCard(index, sudokus[index], isDark);
          },
        );
      },
    );
  }

  Widget _buildLevelCard(int index, String sudoku, bool isDark) {
    return FutureBuilder<bool>(
      future: _historyService.isCompleted(sudoku),
      builder: (context, snapshot) {
        final isCompleted = snapshot.data ?? false;
        final isActive = false; // TODO: Check if this is current game
        final isLocked = false; // Không lock nữa, cho chơi tất cả

        return FutureBuilder<int?>(
          future: _historyService.getBestTime(sudoku),
          builder: (context, timeSnapshot) {
            final bestTime = timeSnapshot.data;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  context.push(
                    '/game?sudoku=$sudoku&difficulty=${Difficulty.values[_selectedTab].displayName}',
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? (isDark ? const Color(0xFF1E3A4C) : const Color(0xFFCBE7F5))
                        : isActive
                            ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F4F7)),
                    borderRadius: BorderRadius.circular(16),
                    border: isActive
                        ? Border.all(color: const Color(0xFF005BC1), width: 2)
                        : null,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: const Color(0xFF005BC1).withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isLocked)
                              Icon(
                                Icons.lock_outline,
                                color: isDark ? Colors.grey[600] : const Color(0xFFACB3B7),
                                size: 24,
                              ),
                            if (isLocked) const SizedBox(height: 4),
                            Text(
                              '#${index + 1}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: isCompleted
                                    ? (isDark ? Colors.blue[200] : const Color(0xFF3C5561))
                                    : isActive
                                        ? const Color(0xFF005BC1)
                                        : (isDark ? Colors.grey[400] : const Color(0xFF596064)),
                              ),
                            ),
                            if (isCompleted && bestTime != null)
                              Text(
                                _formatTime(bestTime),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF596064),
                                ),
                              ),
                            if (isActive)
                              const Text(
                                'TIẾP TỤC',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF005BC1),
                                  letterSpacing: 0.5,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (isCompleted)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Icon(
                            Icons.check_circle,
                            color: isDark ? Colors.blue[200] : const Color(0xFF3C5561),
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<List<String>> _loadSudokus(Difficulty difficulty) async {
    try {
      final content = await rootBundle.loadString(
        'assets/sudokus/${difficulty.value}.txt',
      );
      return content
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty && line.length == 81)
          .toList();
    } catch (e) {
      return [];
    }
  }
}
