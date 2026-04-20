/**
 * SELECT GAME PAGE - Màn hình chọn level
 * 
 * Đây là màn hình chính (home page) của app, nơi người chơi chọn level để chơi.
 * 
 * Chức năng chính:
 * - Hiển thị 5 tabs độ khó (Easy, Medium, Hard, Expert, Evil)
 * - Hiển thị grid 30 levels cho mỗi độ khó
 * - Hiển thị tiến trình hoàn thành
 * - Hiển thị level và XP hiện tại
 * - Hiển thị best time cho level đã hoàn thành
 * - Cho phép chọn level để chơi
 * - Bottom navigation để chuyển màn hình
 * 
 * Luồng hoạt động:
 * 1. Load 5 file Sudoku từ assets (easy.txt, medium.txt...)
 * 2. Hiển thị 30 levels đầu tiên của mỗi độ khó
 * 3. Kiểm tra level nào đã hoàn thành (có dấu check)
 * 4. Hiển thị best time nếu đã hoàn thành
 * 5. Khi tap vào level → Chuyển đến GamePage
 * 
 * Cấu trúc UI:
 * - AppBar: Title + Level Badge + Settings
 * - Difficulty Tabs: 5 tabs ngang
 * - Progress Card: Tiến trình % hoàn thành
 * - Level Grid: 3 cột x 10 hàng = 30 levels
 * - Bottom Nav: 3 tabs (Chơi, Hàng ngày, Thống kê)
 */

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
  // TabController để quản lý 5 tabs độ khó
  late TabController _tabController;
  
  // Index của tab đang chọn (0-4)
  int _selectedTab = 0;
  
  // Service để lấy lịch sử và tiến trình
  final GameHistoryService _historyService = GameHistoryService();
  
  // Tiến trình tổng (tất cả độ khó)
  // {completed: 50, total: 500, percentage: 10}
  Map<String, dynamic> _totalProgress = {
    'completed': 0,
    'total': 0,
    'percentage': 0,
  };
  
  // Tiến trình của độ khó hiện tại
  // {completed: 10, total: 100, percentage: 10}
  Map<String, dynamic> _currentProgress = {
    'completed': 0,
    'total': 0,
    'percentage': 0,
  };

  @override
  void initState() {
    super.initState();
    
    // Khởi tạo TabController với 5 tabs
    _tabController = TabController(length: 5, vsync: this);
    
    // Lắng nghe sự kiện chuyển tab
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTab = _tabController.index;
        });
        // Load lại tiến trình khi chuyển tab
        _loadProgress();
      }
    });
    
    // Load tiến trình lần đầu
    _loadProgress();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Load tiến trình hoàn thành
  /// 
  /// Load 2 loại tiến trình:
  /// 1. Tổng tiến trình (tất cả độ khó)
  /// 2. Tiến trình độ khó hiện tại
  Future<void> _loadProgress() async {
    // Load tổng tiến trình
    final total = await _historyService.getTotalProgress();
    
    // Load tiến trình độ khó hiện tại
    final current = await _historyService.getProgress(
      Difficulty.values[_selectedTab].value, // 'easy', 'medium'...
      100, // Giả sử mỗi độ khó có 100 levels
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
      
      // ===== APP BAR =====
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FB),
        elevation: 0,
        
        // Nút back (ẩn vì đây là home page)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        
        // Tiêu đề
        title: const Text(
          'Chọn màn chơi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        
        actions: [
          // ===== LEVEL BADGE =====
          // Hiển thị level hiện tại của người chơi
          // Tap vào để xem stats
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
                    // Gradient xanh dương
                    gradient: const LinearGradient(
                      colors: [Color(0xFF005BC1), Color(0xFF0077ED)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon sao
                      const Text(
                        '⭐',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      // Level (Lv.5)
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
          
          // Nút Settings
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      
      // ===== BODY =====
      body: Column(
        children: [
          // ===== DIFFICULTY TABS =====
          // 5 tabs: Easy, Medium, Hard, Expert, Evil
          _buildDifficultyTabs(isDark),
          
          // ===== SCROLLABLE CONTENT =====
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  
                  // ===== PROGRESS CARD =====
                  // Hiển thị % hoàn thành của độ khó hiện tại
                  _buildProgressCard(isDark),
                  
                  const SizedBox(height: 24),
                  
                  // ===== LEVEL GRID =====
                  // Grid 3x10 = 30 levels
                  _buildLevelGrid(isDark),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: const BottomNavBar(currentRoute: 'select'),
    );
  }

  /// Build Difficulty Tabs
  /// 
  /// Hiển thị 5 tabs ngang:
  /// - Easy (Dễ)
  /// - Medium (Trung bình)
  /// - Hard (Khó)
  /// - Expert (Chuyên gia)
  /// - Evil (Ác mộng)
  /// 
  /// Tab đang chọn có:
  /// - Background xanh dương
  /// - Text trắng
  /// - Shadow
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
                    // Chuyển tab khi tap
                    _tabController.animateTo(index);
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      // Background: Xanh nếu selected, xám nếu không
                      color: isSelected
                          ? const Color(0xFF005BC1)
                          : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F4F7)),
                      borderRadius: BorderRadius.circular(24),
                      // Shadow cho tab selected
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
                        // Text: Trắng nếu selected, xám nếu không
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

  /// Build Progress Card
  /// 
  /// Hiển thị tiến trình hoàn thành của độ khó hiện tại:
  /// - % hoàn thành (10%)
  /// - Progress bar
  /// - Số level hoàn thành / tổng (10/100)
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
          // Label "TIẾN TRÌNH CỦA BẠN"
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
          
          // % hoàn thành (10% Hoàn thành)
          Text(
            '$percentage% Hoàn thành',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          
          // Progress bar
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
          
          // Số level hoàn thành (10 trong 100 màn đã hoàn thành)
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

  /// Build Level Grid
  /// 
  /// Hiển thị grid 3 cột x 10 hàng = 30 levels
  /// 
  /// Các bước:
  /// 1. Load Sudoku từ assets (easy.txt, medium.txt...)
  /// 2. Lấy 30 Sudoku đầu tiên
  /// 3. Hiển thị mỗi level dưới dạng card
  Widget _buildLevelGrid(bool isDark) {
    return FutureBuilder<List<String>>(
      // Load Sudoku từ assets theo độ khó
      future: _loadSudokus(Difficulty.values[_selectedTab]),
      builder: (context, snapshot) {
        // Đang load → Hiện loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Không có data → Hiện thông báo
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có Sudoku'));
        }

        final sudokus = snapshot.data!;

        // Hiển thị grid 3 cột
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 cột
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1, // Vuông
          ),
          // Chỉ hiển thị 30 levels đầu
          itemCount: sudokus.length > 30 ? 30 : sudokus.length,
          itemBuilder: (context, index) {
            return _buildLevelCard(index, sudokus[index], isDark);
          },
        );
      },
    );
  }

  /// Build Level Card
  /// 
  /// Hiển thị 1 level card với:
  /// - Số level (#1, #2...)
  /// - Icon check nếu đã hoàn thành
  /// - Best time nếu đã hoàn thành
  /// - Background xanh nhạt nếu đã hoàn thành
  /// 
  /// Trạng thái:
  /// - Completed: Đã hoàn thành (có check, có best time)
  /// - Active: Đang chơi (border xanh, text "TIẾP TỤC")
  /// - Normal: Chưa chơi (background xám)
  Widget _buildLevelCard(int index, String sudoku, bool isDark) {
    return FutureBuilder<bool>(
      // Kiểm tra level đã hoàn thành chưa
      future: _historyService.isCompleted(sudoku),
      builder: (context, snapshot) {
        final isCompleted = snapshot.data ?? false;
        final isActive = false; // TODO: Kiểm tra có phải game đang chơi không
        final isLocked = false; // Không lock, cho chơi tất cả

        return FutureBuilder<int?>(
          // Lấy best time nếu đã hoàn thành
          future: _historyService.getBestTime(sudoku),
          builder: (context, timeSnapshot) {
            final bestTime = timeSnapshot.data;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                // Tap vào level → Chuyển đến GamePage
                onTap: () {
                  context.push(
                    '/game?sudoku=$sudoku&difficulty=${Difficulty.values[_selectedTab].displayName}',
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    // Background theo trạng thái:
                    // - Completed: Xanh nhạt
                    // - Active: Trắng/Xám đen
                    // - Normal: Xám nhạt
                    color: isCompleted
                        ? (isDark ? const Color(0xFF1E3A4C) : const Color(0xFFCBE7F5))
                        : isActive
                            ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F4F7)),
                    borderRadius: BorderRadius.circular(16),
                    // Border xanh nếu active
                    border: isActive
                        ? Border.all(color: const Color(0xFF005BC1), width: 2)
                        : null,
                    // Shadow nếu active
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
                      // ===== CENTER CONTENT =====
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon lock nếu bị khóa
                            if (isLocked)
                              Icon(
                                Icons.lock_outline,
                                color: isDark ? Colors.grey[600] : const Color(0xFFACB3B7),
                                size: 24,
                              ),
                            if (isLocked) const SizedBox(height: 4),
                            
                            // Số level (#1, #2...)
                            Text(
                              '#${index + 1}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                // Màu theo trạng thái
                                color: isCompleted
                                    ? (isDark ? Colors.blue[200] : const Color(0xFF3C5561))
                                    : isActive
                                        ? const Color(0xFF005BC1)
                                        : (isDark ? Colors.grey[400] : const Color(0xFF596064)),
                              ),
                            ),
                            
                            // Best time nếu đã hoàn thành
                            if (isCompleted && bestTime != null)
                              Text(
                                _formatTime(bestTime),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF596064),
                                ),
                              ),
                            
                            // Text "TIẾP TỤC" nếu active
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
                      
                      // ===== ICON CHECK =====
                      // Hiển thị ở góc trên phải nếu đã hoàn thành
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

  /// Format thời gian từ seconds sang MM:SS
  /// 
  /// Ví dụ:
  /// - 65 seconds → "01:05"
  /// - 300 seconds → "05:00"
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Load Sudoku từ assets
  /// 
  /// Đọc file .txt từ assets/sudokus/
  /// - easy.txt
  /// - medium.txt
  /// - hard.txt
  /// - expert.txt
  /// - evil.txt
  /// 
  /// Mỗi dòng là 1 Sudoku (81 ký tự)
  /// 
  /// Returns: List các chuỗi Sudoku
  Future<List<String>> _loadSudokus(Difficulty difficulty) async {
    try {
      // Đọc file từ assets
      final content = await rootBundle.loadString(
        'assets/sudokus/${difficulty.value}.txt',
      );
      
      // Split theo dòng và filter
      return content
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty && line.length == 81) // Chỉ lấy dòng hợp lệ
          .toList();
    } catch (e) {
      return [];
    }
  }
}
