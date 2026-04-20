/**
 * GAME PAGE - Màn hình chơi game chính
 * 
 * Đây là màn hình quan trọng nhất của app, nơi người chơi chơi Sudoku.
 * 
 * Chức năng chính:
 * - Hiển thị bàn Sudoku 9x9
 * - Cho phép người chơi điền số
 * - Undo/Redo
 * - Ghi chú (Notes)
 * - Gợi ý (Hint)
 * - Đếm thời gian
 * - Đếm số lần sai
 * - Auto-save tiến trình
 * - Resume game đã lưu
 * - Kiểm tra thắng/thua
 * 
 * Luồng hoạt động:
 * 1. Nhận sudokuString từ SelectGamePage
 * 2. Kiểm tra có tiến trình đã lưu không
 * 3. Nếu có → Resume game
 * 4. Nếu không → Start new game
 * 5. Người chơi điền số
 * 6. Kiểm tra thắng → Hiện WinDialog
 * 7. Kiểm tra thua (3 lần sai) → Hiện GameOverDialog
 * 8. Khi thoát → Auto-save tiến trình
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/cell.dart';
import '../../../../core/engine/sudoku_solver.dart';
import '../../../../core/engine/sudoku_utility.dart';
import '../../../../core/services/game_history_service.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/services/level_service.dart';
import '../providers/game_provider.dart';
import '../providers/sudoku_provider.dart';
import '../providers/timer_provider.dart';
import '../widgets/sudoku_board_new.dart';
import '../widgets/game_controls.dart';
import '../widgets/number_pad.dart';
import '../widgets/win_dialog.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/level_up_dialog.dart';
import '../widgets/bottom_nav_bar.dart';

class GamePage extends StatefulWidget {
  // Chuỗi Sudoku (81 ký tự, 0 = ô trống)
  // Ví dụ: "530070000600195000098000060..."
  final String? sudokuString;
  
  // Độ khó: Easy, Medium, Hard, Expert, Evil
  final String? difficulty;
  
  // Có phải daily challenge không
  // Daily challenge không được auto-save
  final bool isDaily;

  const GamePage({
    super.key,
    this.sudokuString,
    this.difficulty,
    this.isDaily = false,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  // Service để lưu lịch sử và tiến trình game
  final GameHistoryService _historyService = GameHistoryService();
  
  // Lưu references của các providers để dùng trong dispose
  // Cần lưu vì dispose không có access vào context.read
  SudokuProvider? _sudokuProvider;
  TimerProvider? _timerProvider;
  GameProvider? _gameProvider;

  @override
  void initState() {
    super.initState();
    
    // Lắng nghe thay đổi settings để rebuild UI
    // Ví dụ: Khi tắt timer, UI sẽ tự động ẩn timer
    SettingsService.instance.addListener(_onSettingsChanged);
    
    // Khởi tạo game sau khi build xong
    // Dùng addPostFrameCallback để đảm bảo context đã sẵn sàng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initGame();
    });
  }
  
  /// Callback khi settings thay đổi
  /// Force rebuild để cập nhật UI theo settings mới
  void _onSettingsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Lưu references của providers
    // Cần lưu vì dispose không có access vào context.read
    _sudokuProvider = context.read<SudokuProvider>();
    _timerProvider = context.read<TimerProvider>();
    _gameProvider = context.read<GameProvider>();
  }

  @override
  void dispose() {
    // Xóa listener để tránh memory leak
    SettingsService.instance.removeListener(_onSettingsChanged);
    
    // Auto-save tiến trình game khi thoát
    _autoSaveGame();
    
    super.dispose();
  }

  /// Auto-save tiến trình game khi người chơi thoát
  /// 
  /// Điều kiện lưu:
  /// - Có sudokuString (không phải null)
  /// - Không phải daily challenge
  /// - Game đang chơi (running)
  /// - Chưa thắng
  /// 
  /// Dữ liệu lưu:
  /// - Tất cả 81 cells (x, y, number, solution, initial, notes)
  /// - Thời gian đã chơi (seconds)
  /// - Số lần sai (mistakes)
  Future<void> _autoSaveGame() async {
    // Kiểm tra điều kiện
    if (widget.sudokuString == null || widget.isDaily) return;
    if (_sudokuProvider == null || _timerProvider == null || _gameProvider == null) return;
    
    // Chỉ lưu nếu game đang chơi và chưa thắng
    if (_gameProvider!.state != GameState.running || _gameProvider!.won) return;
    
    // Chuyển cells thành JSON để lưu
    final cellsData = _sudokuProvider!.cells.map((c) => {
      'x': c.x,
      'y': c.y,
      'number': c.number,
      'solution': c.solution,
      'initial': c.initial,
      'notes': c.notes,
    }).toList();
    
    // Lưu vào SharedPreferences
    await _historyService.saveGameProgress(
      sudokuKey: widget.sudokuString!,
      difficulty: widget.difficulty ?? 'Unknown',
      cells: cellsData,
      secondsPlayed: _timerProvider!.seconds,
      mistakes: _sudokuProvider!.mistakes,
      hintsUsed: _sudokuProvider!.hintsUsed,
    );
  }

  /// Khởi tạo game
  /// 
  /// Luồng:
  /// 1. Kiểm tra có tiến trình đã lưu không
  /// 2. Nếu có và không phải daily → Resume game
  /// 3. Nếu không → Start new game
  void _initGame() async {
    if (widget.sudokuString == null) return;

    try {
      // Thử load tiến trình đã lưu
      final progress = await _historyService.loadGameProgress(widget.sudokuString!);
      
      if (progress != null && !widget.isDaily) {
        // Có tiến trình → Resume game
        _resumeGame(progress);
      } else {
        // Không có tiến trình → Start new game
        _startNewGame();
      }
    } catch (e) {
      _showError('Lỗi: $e');
    }
  }

  /// Bắt đầu game mới
  /// 
  /// Các bước:
  /// 1. Parse chuỗi Sudoku thành grid 9x9
  /// 2. Giải Sudoku để lấy đáp án
  /// 3. Tạo 81 Cell objects
  /// 4. Khởi tạo SudokuProvider với cells
  /// 5. Start GameProvider
  /// 6. Start TimerProvider từ 0 giây
  void _startNewGame() {
    // Bước 1: Parse chuỗi Sudoku thành grid 9x9
    // Input: "530070000..." (81 ký tự)
    // Output: [[5,3,0,...], [6,0,0,...], ...] (9x9 array)
    final grid = SudokuUtility.parseSudoku(widget.sudokuString!);

    // Bước 2: Giải Sudoku để lấy đáp án
    // Dùng thuật toán Backtracking
    final result = SudokuSolver.solve(grid);
    if (result.sudoku == null) {
      _showError('Không thể giải Sudoku này');
      return;
    }

    // Bước 3: Tạo 81 Cell objects
    // Mỗi Cell có: x, y, number, solution, initial, notes
    // initial = true nếu ô có số ban đầu (không được sửa)
    final cells = SudokuUtility.simpleSudokuToCells(grid, result.sudoku);

    // Bước 4-6: Khởi tạo providers
    final sudokuProvider = context.read<SudokuProvider>();
    final gameProvider = context.read<GameProvider>();
    final timerProvider = context.read<TimerProvider>();

    sudokuProvider.initSudoku(cells);
    gameProvider.startGame(widget.sudokuString!);
    timerProvider.start(0); // Bắt đầu từ 0 giây
  }

  /// Resume game từ tiến trình đã lưu
  /// 
  /// Các bước:
  /// 1. Parse cells từ JSON
  /// 2. Khởi tạo SudokuProvider với cells đã lưu
  /// 3. Start GameProvider
  /// 4. Start TimerProvider từ thời gian đã lưu
  /// 5. Restore số lần sai và số lần gợi ý
  void _resumeGame(Map<String, dynamic> progress) {
    // Bước 1: Parse cells từ JSON
    final cellsData = progress['cells'] as List<dynamic>;
    final cells = cellsData.map((data) {
      return Cell(
        x: data['x'],
        y: data['y'],
        number: data['number'],
        solution: data['solution'],
        initial: data['initial'],
        notes: List<int>.from(data['notes'] ?? []),
      );
    }).toList();

    // Bước 2-4: Khởi tạo providers
    final sudokuProvider = context.read<SudokuProvider>();
    final gameProvider = context.read<GameProvider>();
    final timerProvider = context.read<TimerProvider>();

    sudokuProvider.initSudoku(cells);
    gameProvider.startGame(widget.sudokuString!);
    timerProvider.start(progress['secondsPlayed'] ?? 0); // Resume từ thời gian đã lưu
    
    // Bước 5: Restore số lần sai và số lần gợi ý
    if (progress['mistakes'] != null) {
      sudokuProvider.setMistakes(progress['mistakes']);
    }
    if (progress['hintsUsed'] != null) {
      sudokuProvider.setHintsUsed(progress['hintsUsed']);
    }
  }

  /// Hiển thị thông báo lỗi
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // Background color theo theme
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FB),
      
      // ===== APP BAR: Hiển thị độ khó, timer, mistakes counter =====
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FB),
        elevation: 0,
        
        // Nút back
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF005BC1),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        
        // Tiêu đề: Hiển thị độ khó
        title: Text(
          widget.difficulty ?? 'Sudoku',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        
        actions: [
          // ===== MISTAKES COUNTER =====
          // Chỉ hiển thị khi bật "Giới hạn sai" trong settings
          // Consumer2 để lắng nghe cả SudokuProvider và SettingsService
          Consumer2<SudokuProvider, SettingsService>(
            builder: (context, sudoku, settings, _) {
              // Nếu tắt "Giới hạn sai" → Ẩn counter
              if (!settings.mistakesLimit) return const SizedBox();
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Label "SAI"
                    Text(
                      'SAI',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: isDark ? Colors.grey[400] : const Color(0xFF747C80),
                      ),
                    ),
                    // Số lần sai / Tối đa (0/3)
                    Text(
                      '${sudoku.mistakes}/${sudoku.maxMistakes}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        // Đỏ nếu đã sai 3 lần, cam nếu chưa
                        color: sudoku.mistakes >= sudoku.maxMistakes
                            ? Colors.red
                            : const Color(0xFFF97316),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // ===== TIMER =====
          // Chỉ hiển thị khi bật "Hiển thị đồng hồ" trong settings
          // Consumer2 để lắng nghe cả TimerProvider và SettingsService
          Consumer2<TimerProvider, SettingsService>(
            builder: (context, timer, settings, _) {
              // Nếu tắt "Hiển thị đồng hồ" → Ẩn timer
              if (!settings.timerDisplay) return const SizedBox();
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Label "TIMER"
                    Text(
                      'TIMER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: isDark ? Colors.grey[400] : const Color(0xFF747C80),
                      ),
                    ),
                    // Thời gian (MM:SS)
                    Text(
                      timer.formattedTime,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF005BC1),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Nút Settings
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            color: const Color(0xFF005BC1),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      
      // ===== BODY: Bàn Sudoku + Controls + Number Pad =====
      // Consumer4 để lắng nghe tất cả providers cần thiết
      body: Consumer4<SudokuProvider, GameProvider, TimerProvider, SettingsService>(
        builder: (context, sudoku, game, timer, settings, _) {
          
          // ===== KIỂM TRA GAME OVER =====
          // Chỉ kiểm tra khi:
          // - Game đang chơi (running)
          // - Chưa thắng
          // - Bật "Giới hạn sai"
          // - Đã sai 3 lần
          if (game.state == GameState.running && 
              !game.won && 
              settings.mistakesLimit &&
              sudoku.isGameOver) {
            // Dùng addPostFrameCallback để tránh setState trong build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              game.pauseGame();
              timer.stop();
              _showGameOverDialog();
            });
          }
          
          // ===== KIỂM TRA THẮNG =====
          // Kiểm tra khi:
          // - Game đang chơi (running)
          // - Chưa thắng
          // - Có ít nhất 1 ô đã điền
          if (game.state == GameState.running && 
              !game.won && 
              sudoku.cells.isNotEmpty &&
              sudoku.cells.any((c) => !c.initial && c.number != 0)) {
            
            // Kiểm tra tất cả ô đã điền đúng chưa
            if (sudoku.isWon()) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                // Đánh dấu đã thắng
                game.wonGame();
                timer.stop();
                
                // Lưu lịch sử game với Hive
                // saveGameHistory sẽ tự động:
                // - Lưu vào database
                // - Cộng XP
                // - Kiểm tra level up
                // - Trả về true nếu level up
                final leveledUp = await _historyService.saveGameHistory(
                  difficulty: widget.difficulty ?? 'Unknown',
                  timeSeconds: timer.seconds,
                  completed: true,
                  mistakes: sudoku.mistakes,
                  hintsUsed: sudoku.hintsUsed,
                  isDaily: widget.isDaily,
                  sudokuKey: widget.sudokuString, // Lưu sudokuKey để track level cụ thể
                );
                
                // Hiện Win Dialog
                if (context.mounted) {
                  await _showWinDialog();
                  
                  // Nếu level up, hiện Level Up Dialog
                  if (leveledUp && context.mounted) {
                    final levelInfo = await LevelService().getLevelInfo();
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => LevelUpDialog(newLevel: levelInfo.level),
                      );
                    }
                  }
                }
              });
            }
          }

          // Cập nhật thời gian trong GameProvider
          if (game.state == GameState.running) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              game.updateTime(timer.seconds);
            });
          }

          // ===== UI LAYOUT =====
          return Column(
            children: [
              // ===== BÀN SUDOKU 9x9 =====
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Center(
                    // AspectRatio 1:1 để bàn cờ luôn vuông
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: SudokuBoardNew(cells: sudoku.cells),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // ===== GAME CONTROLS =====
              // Undo, Redo, Erase, Notes, Hint
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GameControls(
                  // Undo: Chỉ enable khi có thể undo
                  onUndo: sudoku.canUndo ? () => sudoku.undo() : null,
                  // Redo: Chỉ enable khi có thể redo
                  onRedo: sudoku.canRedo ? () => sudoku.redo() : null,
                  // Erase: Xóa ô đang chọn
                  onErase: () => sudoku.eraseCell(),
                  // Notes: Bật/tắt chế độ ghi chú
                  onToggleNotes: () => sudoku.toggleNotesMode(),
                  // Hint: Điền đáp án cho ô đang chọn
                  // Chỉ enable khi còn lượt gợi ý
                  onHint: sudoku.hintsRemaining > 0 ? () => sudoku.giveHint() : null,
                  // Trạng thái notes mode (để highlight nút)
                  notesMode: sudoku.notesMode,
                  // Số lượt gợi ý còn lại
                  hintsRemaining: sudoku.hintsRemaining,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // ===== NUMBER PAD =====
              // Bàn phím số 1-9
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: NumberPad(
                  // Callback khi chọn số
                  onNumberSelected: (number) {
                    sudoku.setNumber(number);
                  },
                  // Số đang chọn (để highlight)
                  selectedNumber: sudoku.selectedCell?.number ?? 0,
                ),
              ),
              
              const SizedBox(height: 8),
            ],
          );
        },
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: const BottomNavBar(currentRoute: 'game'),
    );
  }

  /// Hiển thị Win Dialog khi thắng
  Future<void> _showWinDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false, // Không cho đóng bằng cách tap ra ngoài
      builder: (context) => WinDialog(
        sudokuString: widget.sudokuString,
        difficulty: widget.difficulty,
      ),
    );
  }

  /// Hiển thị Game Over Dialog khi thua (sai 3 lần)
  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Không cho đóng bằng cách tap ra ngoài
      builder: (context) => GameOverDialog(
        sudokuString: widget.sudokuString,
        difficulty: widget.difficulty,
      ),
    );
  }
}
