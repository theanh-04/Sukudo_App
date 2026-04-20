/**
 * DAILY_PAGE.DART
 * ===============
 * 
 * TỔNG QUAN:
 * Màn hình Thử thách hàng ngày - nơi người chơi có thể tham gia các thử thách Sudoku
 * được tạo tự động mỗi ngày. Mỗi ngày sẽ có một bảng Sudoku duy nhất với độ khó và
 * điểm thưởng XP cố định.
 * 
 * TÍNH NĂNG CHÍNH:
 * - Hiển thị thử thách hôm nay với thông tin độ khó và XP
 * - Lịch tháng hiển thị các ngày đã hoàn thành
 * - Điều hướng giữa các tháng để xem lịch sử
 * - Phòng cúp hiển thị các thành tích theo tháng
 * - Theo dõi tiến độ hoàn thành trong tháng
 * - Chỉ cho phép chơi thử thách hôm nay một lần
 * 
 * LUỒNG HOẠT ĐỘNG:
 * 1. Tải dữ liệu các ngày đã hoàn thành trong tháng hiện tại
 * 2. Kiểm tra xem hôm nay đã hoàn thành chưa
 * 3. Hiển thị card thử thách hôm nay với nút "Chơi ngay" hoặc "Đã hoàn thành"
 * 4. Hiển thị lịch tháng với các ngày đã hoàn thành được đánh dấu
 * 5. Khi người chơi nhấn "Chơi ngay", chuyển đến màn hình game với isDaily=true
 * 6. Sau khi hoàn thành, game sẽ đánh dấu ngày hôm nay là đã hoàn thành
 * 
 * CẤU TRÚC UI:
 * - AppBar: Tiêu đề + nút back + nút settings
 * - Month Navigator: Tên tháng + số ngày hoàn thành + nút prev/next
 * - Today Card: Vòng tròn tiến độ + thông tin thử thách + nút chơi
 * - Calendar: Lịch tháng với các ngày được đánh dấu
 * - Trophy Room: Các thành tích theo tháng
 * - Bottom Navigation Bar: Điều hướng giữa các màn hình chính
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/game_history_service.dart';
import '../widgets/bottom_nav_bar.dart';

/// Widget chính của màn hình Thử thách hàng ngày
/// Sử dụng StatefulWidget để quản lý state của lịch và dữ liệu hoàn thành
class DailyPage extends StatefulWidget {
  const DailyPage({super.key});

  @override
  State<DailyPage> createState() => _DailyPageState();
}

class _DailyPageState extends State<DailyPage> {
  // Service để truy vấn lịch sử game và dữ liệu daily challenge
  final GameHistoryService _historyService = GameHistoryService();
  
  // Tháng hiện tại đang được hiển thị trên lịch (có thể khác tháng hiện tại)
  DateTime _currentMonth = DateTime.now();
  
  // Set chứa các ngày đã hoàn thành trong tháng đang xem
  Set<int> _completedDays = {};
  
  // Ngày hôm nay (số ngày trong tháng)
  final int _todayDay = DateTime.now().day;
  
  // Flag kiểm tra xem thử thách hôm nay đã hoàn thành chưa
  bool _isTodayCompleted = false;

  /// Lifecycle: Khởi tạo state khi widget được tạo
  /// Gọi _loadCompletedDays() để tải dữ liệu các ngày đã hoàn thành
  @override
  void initState() {
    super.initState();
    _loadCompletedDays();
  }

  /// Tải danh sách các ngày đã hoàn thành trong tháng đang xem
  /// 
  /// LOGIC:
  /// 1. Lấy danh sách ngày đã hoàn thành từ GameHistoryService
  /// 2. Kiểm tra xem hôm nay đã hoàn thành chưa
  /// 3. Cập nhật state để UI render lại
  /// 
  /// Được gọi khi:
  /// - Widget khởi tạo (initState)
  /// - Người dùng chuyển sang tháng khác
  Future<void> _loadCompletedDays() async {
    // Lấy danh sách các ngày đã hoàn thành trong tháng đang xem
    final completed = await _historyService.getCompletedDaysInMonth(
      _currentMonth.year,
      _currentMonth.month,
    );
    
    // Kiểm tra xem thử thách hôm nay đã hoàn thành chưa
    final todayCompleted = await _historyService.isTodayCompleted();
    
    // Cập nhật state
    setState(() {
      _completedDays = completed.toSet(); // Chuyển List thành Set để tra cứu nhanh
      _isTodayCompleted = todayCompleted;
    });
  }

  /// Chuyển sang tháng trước
  /// Cập nhật _currentMonth và tải lại dữ liệu các ngày đã hoàn thành
  void _previousMonth() {
    setState(() {
      // Trừ 1 tháng (DateTime tự động xử lý việc chuyển năm)
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _loadCompletedDays(); // Tải lại dữ liệu cho tháng mới
  }

  /// Chuyển sang tháng sau
  /// Cập nhật _currentMonth và tải lại dữ liệu các ngày đã hoàn thành
  void _nextMonth() {
    setState(() {
      // Cộng 1 tháng (DateTime tự động xử lý việc chuyển năm)
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _loadCompletedDays(); // Tải lại dữ liệu cho tháng mới
  }

  /// Bắt đầu chơi thử thách hàng ngày
  /// 
  /// LOGIC:
  /// 1. Lấy bảng Sudoku và độ khó cho ngày hôm nay từ GameHistoryService
  /// 2. Chuyển đến màn hình game với tham số isDaily=true
  /// 3. Màn hình game sẽ xử lý việc đánh dấu hoàn thành khi người chơi thắng
  void _playDailyChallenge() {
    final today = DateTime.now();
    
    // Lấy bảng Sudoku được tạo cho ngày hôm nay (deterministic dựa trên ngày)
    final sudoku = _historyService.getDailySudokuForDate(today);
    
    // Lấy độ khó cho ngày hôm nay (cũng deterministic)
    final difficulty = _historyService.getDailyDifficultyForDate(today);
    
    // Chuyển đến màn hình game với flag isDaily=true để đánh dấu đây là daily challenge
    context.push('/game?sudoku=$sudoku&difficulty=$difficulty&isDaily=true');
  }

  /// Build UI chính của màn hình
  /// 
  /// CẤU TRÚC:
  /// - Scaffold với background color tùy theo theme
  /// - AppBar: Tiêu đề + nút back + nút settings
  /// - Body: ScrollView chứa các section
  ///   + Month Navigator: Điều hướng tháng
  ///   + Today Card: Thông tin thử thách hôm nay
  ///   + Calendar: Lịch tháng
  ///   + Trophy Room: Phòng cúp
  /// - Bottom Navigation Bar: Điều hướng chính
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // Background color khác nhau cho dark/light mode
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FB),
      
      // AppBar với nút back và settings
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FB),
        elevation: 0, // Không có shadow
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
          // Nút settings ở góc phải
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      
      // Body: ScrollView để có thể cuộn khi nội dung dài
      body: SingleChildScrollView(
        // Padding: 24 trái/phải, 8 trên, 100 dưới (để không bị che bởi bottom nav)
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Month Navigator: Hiển thị tháng hiện tại và nút prev/next
            _buildMonthNavigator(isDark),
            const SizedBox(height: 24),
            
            // 2. Today Card: Card lớn hiển thị thử thách hôm nay
            _buildTodayCard(isDark),
            const SizedBox(height: 32),
            
            // 3. Calendar: Lịch tháng với các ngày được đánh dấu
            _buildCalendar(isDark),
            const SizedBox(height: 32),
            
            // 4. Trophy Room: Các thành tích theo tháng
            _buildTrophyRoom(isDark),
          ],
        ),
      ),
      
      // Bottom Navigation Bar với route hiện tại là 'daily'
      bottomNavigationBar: const BottomNavBar(currentRoute: 'daily'),
    );
  }

  /// Build Month Navigator - thanh điều hướng tháng
  /// 
  /// HIỂN THỊ:
  /// - Tên tháng và năm (VD: "Tháng 4 2026")
  /// - Badge hiển thị số ngày hoàn thành / tổng số ngày (VD: "15/30")
  /// - Nút prev/next để chuyển tháng
  /// 
  /// @param isDark - Theme hiện tại có phải dark mode không
  Widget _buildMonthNavigator(bool isDark) {
    // Danh sách tên tháng tiếng Việt
    final monthNames = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
      'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];
    
    // Tạo chuỗi "Tháng X YYYY"
    final monthName = '${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}';
    
    // Đếm số ngày đã hoàn thành
    final completedCount = _completedDays.length;
    
    // Tính tổng số ngày trong tháng (ngày 0 của tháng sau = ngày cuối tháng này)
    final totalDays = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Phần bên trái: Tên tháng + badge số ngày hoàn thành
        Expanded(
          child: Row(
            children: [
              // Tên tháng (có thể bị cắt nếu quá dài)
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
              
              // Badge hiển thị "X/Y" (số ngày hoàn thành / tổng ngày)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBE7F5), // Màu xanh nhạt
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedCount/$totalDays',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF005BC1), // Màu xanh đậm
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Phần bên phải: Nút prev/next
        Row(
          children: [
            // Nút chuyển sang tháng trước
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _previousMonth,
              color: const Color(0xFF49636F),
            ),
            
            // Nút chuyển sang tháng sau
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

  /// Build Today Card - card hiển thị thử thách hôm nay
  /// 
  /// HIỂN THỊ:
  /// - Vòng tròn tiến độ (progress circle) hiển thị % hoàn thành trong tháng
  /// - Tiêu đề "NHIỆM VỤ HÔM NAY"
  /// - Tên thử thách "Thử thách kiến trúc sư"
  /// - Thông tin độ khó và XP
  /// - Nút "Chơi ngay" hoặc "Đã hoàn thành"
  /// 
  /// LOGIC:
  /// - Nếu đã hoàn thành hôm nay: nút disabled, text "Đã hoàn thành"
  /// - Nếu chưa hoàn thành: nút active, text "Chơi ngay", gọi _playDailyChallenge() khi nhấn
  /// 
  /// @param isDark - Theme hiện tại có phải dark mode không
  Widget _buildTodayCard(bool isDark) {
    final today = DateTime.now();
    
    // Tính toán tiến độ hoàn thành trong tháng
    final completedCount = _completedDays.length;
    final totalDays = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final progress = completedCount / totalDays; // 0.0 - 1.0
    
    // Lấy thông tin độ khó và XP cho ngày hôm nay
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
          // SECTION 1: Vòng tròn tiến độ (Progress Circle)
          // Hiển thị % hoàn thành trong tháng với icon và số liệu
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Vòng tròn tiến độ
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: progress, // 0.0 - 1.0
                    strokeWidth: 8,
                    backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF0F4F7),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF005BC1)),
                  ),
                ),
                
                // Nội dung bên trong vòng tròn
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon huy chương
                    const Icon(
                      Icons.workspace_premium,
                      size: 36,
                      color: Color(0xFF005BC1),
                    ),
                    const SizedBox(height: 4),
                    
                    // Số ngày hoàn thành / tổng ngày
                    Text(
                      '$completedCount/$totalDays',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    // Label "NGÀY"
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
          
          // SECTION 2: Thông tin thử thách
          // Label "NHIỆM VỤ HÔM NAY"
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
          
          // Tên thử thách
          const Text(
            'Thử thách kiến trúc sư',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // SECTION 3: Thông tin độ khó và XP
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              // Độ khó
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
              
              // XP thưởng
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
          
          // SECTION 4: Nút hành động
          // Nếu đã hoàn thành: disabled, text "Đã hoàn thành"
          // Nếu chưa hoàn thành: enabled, text "Chơi ngay"
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isTodayCompleted ? null : _playDailyChallenge,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isTodayCompleted 
                    ? Colors.grey  // Màu xám khi disabled
                    : const Color(0xFF005BC1), // Màu xanh khi enabled
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: _isTodayCompleted ? 0 : 4, // Không có shadow khi disabled
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

  /// Build Calendar - lịch tháng hiển thị các ngày đã hoàn thành
  /// 
  /// HIỂN THỊ:
  /// - Header "Lịch tháng" + legend "HOÀN THÀNH"
  /// - Grid 7 cột (T2-CN) cho các ngày trong tuần
  /// - Grid các ngày trong tháng với:
  ///   + Ngày hôm nay: background xanh, chấm trắng ở dưới
  ///   + Ngày đã hoàn thành: có icon star
  ///   + Ngày tương lai: màu xám nhạt, disabled
  ///   + Ngày quá khứ chưa hoàn thành: màu trắng
  /// 
  /// LOGIC:
  /// - Tính ngày đầu tiên của tháng để biết bắt đầu từ cột nào
  /// - Render empty cells cho các ngày trước ngày đầu tiên
  /// - Render cells cho các ngày trong tháng với style tương ứng
  /// 
  /// @param isDark - Theme hiện tại có phải dark mode không
  Widget _buildCalendar(bool isDark) {
    // Tính toán thông tin tháng
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final startWeekday = firstDay.weekday; // 1=Monday, 7=Sunday

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F4F7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Header: Tiêu đề + legend
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
              
              // Legend: Chấm xanh + text "HOÀN THÀNH"
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
          
          // Grid header: T2, T3, T4, T5, T6, T7, CN
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
          
          // Grid các ngày trong tháng
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: startWeekday - 1 + daysInMonth, // Empty cells + ngày trong tháng
            itemBuilder: (context, index) {
              // Render empty cell cho các ngày trước ngày đầu tiên
              if (index < startWeekday - 1) {
                return const SizedBox();
              }
              
              // Tính ngày hiện tại
              final day = index - startWeekday + 2;
              
              // Kiểm tra các trạng thái
              final isCompleted = _completedDays.contains(day); // Đã hoàn thành
              final isToday = day == _todayDay &&  // Là ngày hôm nay
                             _currentMonth.month == DateTime.now().month &&
                             _currentMonth.year == DateTime.now().year;
              final isFuture = DateTime(_currentMonth.year, _currentMonth.month, day)
                  .isAfter(DateTime.now()); // Là ngày tương lai

              return _buildDayCell(day, isCompleted, isToday, isFuture, isDark);
            },
          ),
        ],
      ),
    );
  }

  /// Build header cho các ngày trong tuần (T2, T3, ...)
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

  /// Build cell cho một ngày trong lịch
  /// 
  /// STYLE:
  /// - isToday: background xanh, text trắng, chấm trắng ở dưới
  /// - isFuture: background xám nhạt, text xám, border mờ
  /// - isCompleted: có icon star ở góc phải trên
  /// - Ngày thường: background trắng/dark, text bình thường
  Widget _buildDayCell(int day, bool isCompleted, bool isToday, bool isFuture, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isToday
            ? const Color(0xFF005BC1) // Xanh cho ngày hôm nay
            : isFuture
                ? (isDark ? const Color(0xFF334155) : const Color(0xFFEAEFF2)) // Xám cho ngày tương lai
                : (isDark ? const Color(0xFF334155) : Colors.white), // Trắng/dark cho ngày thường
        borderRadius: BorderRadius.circular(12),
        border: isFuture
            ? Border.all(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
              )
            : null,
      ),
      child: Stack(
        children: [
          // Số ngày ở giữa
          Center(
            child: Text(
              day.toString(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isToday
                    ? Colors.white // Trắng cho ngày hôm nay
                    : isFuture
                        ? (isDark ? Colors.grey[600] : const Color(0xFFACB3B7)) // Xám cho ngày tương lai
                        : null, // Màu mặc định cho ngày thường
              ),
            ),
          ),
          
          // Icon star nếu đã hoàn thành
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
          
          // Chấm trắng ở dưới nếu là ngày hôm nay
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

  /// Build Trophy Room - phòng cúp hiển thị các thành tích theo tháng
  /// 
  /// HIỂN THỊ:
  /// - Tiêu đề "Phòng cúp"
  /// - Grid 3 cột hiển thị các trophy
  /// - Mỗi trophy có: icon, tên tháng, tên thành tích
  /// 
  /// NOTE: Hiện tại đang hardcode 3 trophy mẫu (Tháng 9, 8, 7)
  /// Trong tương lai có thể load từ database
  Widget _buildTrophyRoom(bool isDark) {
    // Danh sách trophy (hardcode)
    final trophies = [
      {'month': 'Tháng 9', 'title': 'Huy chương bạc', 'icon': Icons.military_tech, 'color': const Color(0xFF747C80)},
      {'month': 'Tháng 8', 'title': 'Vương miện vàng', 'icon': Icons.workspace_premium, 'color': const Color(0xFF565D85)},
      {'month': 'Tháng 7', 'title': 'Khiên bậc thầy', 'icon': Icons.emoji_events, 'color': const Color(0xFF49636F)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề section
        const Text(
          'Phòng cúp',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Grid 3 cột hiển thị các trophy
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9, // Tỷ lệ width/height
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
                  // Icon trophy với background màu
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
                  
                  // Tên tháng
                  Text(
                    trophy['month'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  
                  // Tên thành tích
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
