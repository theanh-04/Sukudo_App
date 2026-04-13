import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/game_history_service.dart';
import '../widgets/bottom_nav_bar.dart';

class DailyPage extends StatefulWidget {
  const DailyPage({super.key});

  @override
  State<DailyPage> createState() => _DailyPageState();
}

class _DailyPageState extends State<DailyPage> {
  final GameHistoryService _historyService = GameHistoryService();
  DateTime _currentMonth = DateTime.now();
  Set<int> _completedDays = {};
  final int _todayDay = DateTime.now().day;
  bool _isTodayCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadCompletedDays();
  }

  Future<void> _loadCompletedDays() async {
    final completed = await _historyService.getCompletedDaysInMonth(
      _currentMonth.year,
      _currentMonth.month,
    );
    final todayCompleted = await _historyService.isTodayCompleted();
    
    setState(() {
      _completedDays = completed.toSet();
      _isTodayCompleted = todayCompleted;
    });
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _loadCompletedDays();
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _loadCompletedDays();
  }

  void _playDailyChallenge() {
    final today = DateTime.now();
    final sudoku = _historyService.getDailySudokuForDate(today);
    final difficulty = _historyService.getDailyDifficultyForDate(today);
    
    context.push('/game?sudoku=$sudoku&difficulty=$difficulty&isDaily=true');
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
          'Thử thách hàng ngày',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
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
            _buildMonthNavigator(isDark),
            const SizedBox(height: 24),
            _buildTodayCard(isDark),
            const SizedBox(height: 32),
            _buildCalendar(isDark),
            const SizedBox(height: 32),
            _buildTrophyRoom(isDark),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentRoute: 'daily'),
    );
  }

  Widget _buildMonthNavigator(bool isDark) {
    final monthNames = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
      'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];
    final monthName = '${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}';
    final completedCount = _completedDays.length;
    final totalDays = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  monthName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBE7F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedCount/$totalDays',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF005BC1),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _previousMonth,
              color: const Color(0xFF49636F),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _nextMonth,
              color: const Color(0xFF49636F),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodayCard(bool isDark) {
    final today = DateTime.now();
    final completedCount = _completedDays.length;
    final totalDays = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final progress = completedCount / totalDays;
    final difficulty = _historyService.getDailyDifficultyForDate(today);
    final xp = _historyService.getDailyXPForDate(today);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress Circle
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF0F4F7),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF005BC1)),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.workspace_premium,
                      size: 36,
                      color: Color(0xFF005BC1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedCount/$totalDays',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'NGÀY',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: isDark ? Colors.grey[400] : const Color(0xFF49636F),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'NHIỆM VỤ HÔM NAY',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: isDark ? Colors.blue[300] : const Color(0xFF005BC1),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Thử thách kiến trúc sư',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.signal_cellular_alt,
                    size: 14,
                    color: isDark ? Colors.blue[300] : const Color(0xFF005BC1),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    difficulty,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey[400] : const Color(0xFF49636F),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 14,
                    color: isDark ? Colors.blue[300] : const Color(0xFF005BC1),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+$xp XP',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey[400] : const Color(0xFF49636F),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isTodayCompleted ? null : _playDailyChallenge,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isTodayCompleted 
                    ? Colors.grey 
                    : const Color(0xFF005BC1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: _isTodayCompleted ? 0 : 4,
              ),
              child: Text(
                _isTodayCompleted ? 'Đã hoàn thành' : 'Chơi ngay',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(bool isDark) {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final startWeekday = firstDay.weekday;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F4F7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lịch tháng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF005BC1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'HOÀN THÀNH',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: isDark ? Colors.grey[400] : const Color(0xFF49636F),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 7,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildWeekdayHeader('T2', isDark),
              _buildWeekdayHeader('T3', isDark),
              _buildWeekdayHeader('T4', isDark),
              _buildWeekdayHeader('T5', isDark),
              _buildWeekdayHeader('T6', isDark),
              _buildWeekdayHeader('T7', isDark),
              _buildWeekdayHeader('CN', isDark),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: startWeekday - 1 + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startWeekday - 1) {
                return const SizedBox();
              }
              
              final day = index - startWeekday + 2;
              final isCompleted = _completedDays.contains(day);
              final isToday = day == _todayDay && 
                             _currentMonth.month == DateTime.now().month &&
                             _currentMonth.year == DateTime.now().year;
              final isFuture = DateTime(_currentMonth.year, _currentMonth.month, day)
                  .isAfter(DateTime.now());

              return _buildDayCell(day, isCompleted, isToday, isFuture, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader(String label, bool isDark) {
    return Center(
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: isDark ? Colors.grey[400] : const Color(0xFF747C80),
        ),
      ),
    );
  }

  Widget _buildDayCell(int day, bool isCompleted, bool isToday, bool isFuture, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isToday
            ? const Color(0xFF005BC1)
            : isFuture
                ? (isDark ? const Color(0xFF334155) : const Color(0xFFEAEFF2))
                : (isDark ? const Color(0xFF334155) : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: isFuture
            ? Border.all(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
              )
            : null,
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              day.toString(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isToday
                    ? Colors.white
                    : isFuture
                        ? (isDark ? Colors.grey[600] : const Color(0xFFACB3B7))
                        : null,
              ),
            ),
          ),
          if (isCompleted)
            Positioned(
              top: 4,
              right: 4,
              child: Icon(
                Icons.star,
                size: 10,
                color: isToday ? Colors.white : const Color(0xFF005BC1),
              ),
            ),
          if (isToday)
            Positioned(
              bottom: 3,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrophyRoom(bool isDark) {
    final trophies = [
      {'month': 'Tháng 9', 'title': 'Huy chương bạc', 'icon': Icons.military_tech, 'color': const Color(0xFF747C80)},
      {'month': 'Tháng 8', 'title': 'Vương miện vàng', 'icon': Icons.workspace_premium, 'color': const Color(0xFF565D85)},
      {'month': 'Tháng 7', 'title': 'Khiên bậc thầy', 'icon': Icons.emoji_events, 'color': const Color(0xFF49636F)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phòng cúp',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: trophies.length,
          itemBuilder: (context, index) {
            final trophy = trophies[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (trophy['color'] as Color).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      trophy['icon'] as IconData,
                      size: 24,
                      color: trophy['color'] as Color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    trophy['month'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    trophy['title'] as String,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[400] : const Color(0xFF747C80),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
