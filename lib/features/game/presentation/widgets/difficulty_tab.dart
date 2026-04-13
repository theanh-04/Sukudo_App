import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/difficulty.dart';

class DifficultyTab extends StatefulWidget {
  final Difficulty difficulty;

  const DifficultyTab({super.key, required this.difficulty});

  @override
  State<DifficultyTab> createState() => _DifficultyTabState();
}

class _DifficultyTabState extends State<DifficultyTab> {
  List<String> _sudokus = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSudokus();
  }

  Future<void> _loadSudokus() async {
    try {
      final content = await rootBundle.loadString(
        'assets/sudokus/${widget.difficulty.value}.txt',
      );
      final lines = content
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty && line.length == 81)
          .toList();
      
      if (lines.isEmpty) {
        throw Exception('Không tìm thấy Sudoku hợp lệ trong file');
      }
      
      setState(() {
        _sudokus = lines;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải Sudoku: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_sudokus.isEmpty) {
      return const Center(
        child: Text('Không có Sudoku nào'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _sudokus.length,
      itemBuilder: (context, index) {
        return _buildSudokuCard(index);
      },
    );
  }

  Widget _buildSudokuCard(int index) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.go(
            '/game?sudoku=${_sudokus[index]}&difficulty=${widget.difficulty.displayName}',
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#${index + 1}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.difficulty.displayName,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
