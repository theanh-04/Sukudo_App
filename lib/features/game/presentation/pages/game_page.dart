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
  final String? sudokuString;
  final String? difficulty;
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
  final GameHistoryService _historyService = GameHistoryService();
  
  // Lưu references để dùng trong dispose
  SudokuProvider? _sudokuProvider;
  TimerProvider? _timerProvider;
  GameProvider? _gameProvider;

  @override
  void initState() {
    super.initState();
    
    // Listen to settings changes
    SettingsService.instance.addListener(_onSettingsChanged);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initGame();
    });
  }
  
  void _onSettingsChanged() {
    // Force rebuild when settings change
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lưu references an toàn
    _sudokuProvider = context.read<SudokuProvider>();
    _timerProvider = context.read<TimerProvider>();
    _gameProvider = context.read<GameProvider>();
  }

  @override
  void dispose() {
    // Remove settings listener
    SettingsService.instance.removeListener(_onSettingsChanged);
    
    // Auto-save khi thoát
    _autoSaveGame();
    super.dispose();
  }

  Future<void> _autoSaveGame() async {
    if (widget.sudokuString == null || widget.isDaily) return;
    if (_sudokuProvider == null || _timerProvider == null || _gameProvider == null) return;
    
    // Chỉ lưu nếu game đang chơi và chưa thắng
    if (_gameProvider!.state != GameState.running || _gameProvider!.won) return;
    
    final cellsData = _sudokuProvider!.cells.map((c) => {
      'x': c.x,
      'y': c.y,
      'number': c.number,
      'solution': c.solution,
      'initial': c.initial,
      'notes': c.notes,
    }).toList();
    
    await _historyService.saveGameProgress(
      sudokuKey: widget.sudokuString!,
      difficulty: widget.difficulty ?? 'Unknown',
      cells: cellsData,
      secondsPlayed: _timerProvider!.seconds,
      mistakes: _sudokuProvider!.mistakes,
    );
  }

  void _initGame() async {
    if (widget.sudokuString == null) return;

    try {
      // Thử load progress trước
      final progress = await _historyService.loadGameProgress(widget.sudokuString!);
      
      if (progress != null && !widget.isDaily) {
        // Có progress - resume game
        _resumeGame(progress);
      } else {
        // Không có progress - start new game
        _startNewGame();
      }
    } catch (e) {
      _showError('Lỗi: $e');
    }
  }

  void _startNewGame() {
    // Parse Sudoku
    final grid = SudokuUtility.parseSudoku(widget.sudokuString!);

    // Giải để lấy đáp án
    final result = SudokuSolver.solve(grid);
    if (result.sudoku == null) {
      _showError('Không thể giải Sudoku này');
      return;
    }

    // Tạo cells - CHỈ các ô có số mới là initial
    final cells = SudokuUtility.simpleSudokuToCells(grid, result.sudoku);

    // Khởi tạo game
    final sudokuProvider = context.read<SudokuProvider>();
    final gameProvider = context.read<GameProvider>();
    final timerProvider = context.read<TimerProvider>();

    sudokuProvider.initSudoku(cells);
    gameProvider.startGame(widget.sudokuString!);
    timerProvider.start(0);
  }

  void _resumeGame(Map<String, dynamic> progress) {
    // Restore cells từ progress
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

    // Khởi tạo game với progress
    final sudokuProvider = context.read<SudokuProvider>();
    final gameProvider = context.read<GameProvider>();
    final timerProvider = context.read<TimerProvider>();

    sudokuProvider.initSudoku(cells);
    gameProvider.startGame(widget.sudokuString!);
    timerProvider.start(progress['secondsPlayed'] ?? 0);
    
    // Restore mistakes
    if (progress['mistakes'] != null) {
      sudokuProvider.setMistakes(progress['mistakes']);
    }
  }

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
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF005BC1),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.difficulty ?? 'Sudoku',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          // Mistakes counter
          Consumer2<SudokuProvider, SettingsService>(
            builder: (context, sudoku, settings, _) {
              if (!settings.mistakesLimit) return const SizedBox();
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SAI',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: isDark ? Colors.grey[400] : const Color(0xFF747C80),
                      ),
                    ),
                    Text(
                      '${sudoku.mistakes}/${sudoku.maxMistakes}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
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
          Consumer2<TimerProvider, SettingsService>(
            builder: (context, timer, settings, _) {
              if (!settings.timerDisplay) return const SizedBox();
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'TIMER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: isDark ? Colors.grey[400] : const Color(0xFF747C80),
                      ),
                    ),
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
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            color: const Color(0xFF005BC1),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: Consumer4<SudokuProvider, GameProvider, TimerProvider, SettingsService>(
        builder: (context, sudoku, game, timer, settings, _) {
          // Kiểm tra game over (chỉ khi bật giới hạn sai)
          if (game.state == GameState.running && 
              !game.won && 
              settings.mistakesLimit &&
              sudoku.isGameOver) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              game.pauseGame();
              timer.stop();
              _showGameOverDialog();
            });
          }
          
          // Kiểm tra thắng
          if (game.state == GameState.running && 
              !game.won && 
              sudoku.cells.isNotEmpty &&
              sudoku.cells.any((c) => !c.initial && c.number != 0)) {
            if (sudoku.isWon()) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                game.wonGame();
                timer.stop();
                
                // Lưu lịch sử (sẽ tự động cộng XP và trả về có level up không)
                final leveledUp = await _historyService.saveGameHistory(
                  GameHistory(
                    sudokuKey: widget.sudokuString!,
                    difficulty: widget.difficulty ?? 'Unknown',
                    timeInSeconds: timer.seconds,
                    completedAt: DateTime.now(),
                    isCompleted: true,
                  ),
                );
                
                // Nếu là daily challenge, đánh dấu hoàn thành
                if (widget.isDaily) {
                  await _historyService.completeDailyChallenge(DateTime.now());
                }
                
                // Hiện win dialog
                if (context.mounted) {
                  await _showWinDialog();
                  
                  // Nếu level up, hiện level up dialog
                  if (leveledUp && context.mounted) {
                    final levelInfo = await LevelService().getLevelInfo();
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => LevelUpDialog(newLevel: levelInfo.level),
                    );
                  }
                }
              });
            }
          }

          // Cập nhật thời gian
          if (game.state == GameState.running) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              game.updateTime(timer.seconds);
            });
          }

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: SudokuBoardNew(cells: sudoku.cells),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12), // Khoảng cách nhỏ
              // Game Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GameControls(
                  onUndo: sudoku.canUndo ? () => sudoku.undo() : null,
                  onRedo: sudoku.canRedo ? () => sudoku.redo() : null,
                  onErase: () => sudoku.eraseCell(),
                  onToggleNotes: () => sudoku.toggleNotesMode(),
                  onHint: () => sudoku.giveHint(),
                  notesMode: sudoku.notesMode,
                ),
              ),
              const SizedBox(height: 8),
              // Number Pad - compact
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: NumberPad(
                  onNumberSelected: (number) {
                    sudoku.setNumber(number);
                  },
                  selectedNumber: sudoku.selectedCell?.number ?? 0,
                ),
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentRoute: 'game'),
    );
  }

  Future<void> _showWinDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WinDialog(
        sudokuString: widget.sudokuString,
        difficulty: widget.difficulty,
      ),
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverDialog(
        sudokuString: widget.sudokuString,
        difficulty: widget.difficulty,
      ),
    );
  }
}
