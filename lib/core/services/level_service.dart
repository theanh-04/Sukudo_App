import 'package:shared_preferences/shared_preferences.dart';

class LevelService {
  static final LevelService _instance = LevelService._internal();
  factory LevelService() => _instance;
  LevelService._internal();

  static const String _keyTotalXP = 'total_xp';
  static const String _keyInitialized = 'level_initialized';
  
  // Khởi tạo lần đầu
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final isInitialized = prefs.getBool(_keyInitialized) ?? false;
    
    if (!isInitialized) {
      // Set giá trị mặc định - bắt đầu từ 0 XP (Level 1)
      await prefs.setInt(_keyTotalXP, 0);
      await prefs.setBool(_keyInitialized, true);
    }
  }
  
  // Reset level (dùng cho testing hoặc reset progress)
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTotalXP, 0);
  }

  // XP cần để lên level (tăng dần)
  static int xpForLevel(int level) {
    return 100 + (level - 1) * 50; // Level 1: 100 XP, Level 2: 150 XP, Level 3: 200 XP...
  }

  // Tổng XP cần để đạt level
  static int totalXpForLevel(int level) {
    int total = 0;
    for (int i = 1; i < level; i++) {
      total += xpForLevel(i);
    }
    return total;
  }

  // Lấy tổng XP
  Future<int> getTotalXP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTotalXP) ?? 0;
  }

  // Lấy level hiện tại
  Future<int> getCurrentLevel() async {
    final totalXP = await getTotalXP();
    return _calculateLevel(totalXP);
  }

  // Tính level từ tổng XP
  int _calculateLevel(int totalXP) {
    int level = 1;
    int xpNeeded = 0;
    
    while (xpNeeded <= totalXP) {
      xpNeeded += xpForLevel(level);
      if (xpNeeded <= totalXP) {
        level++;
      }
    }
    
    return level;
  }

  // Lấy XP hiện tại trong level (progress)
  Future<int> getCurrentLevelXP() async {
    final totalXP = await getTotalXP();
    final level = await getCurrentLevel();
    final previousLevelTotalXP = totalXpForLevel(level);
    return totalXP - previousLevelTotalXP;
  }

  // Lấy XP cần để lên level tiếp theo
  Future<int> getXPNeededForNextLevel() async {
    final level = await getCurrentLevel();
    return xpForLevel(level);
  }

  // Thêm XP và trả về có level up không
  Future<bool> addXP(int xp) async {
    final prefs = await SharedPreferences.getInstance();
    final oldTotalXP = await getTotalXP();
    final oldLevel = await getCurrentLevel();
    
    final newTotalXP = oldTotalXP + xp;
    await prefs.setInt(_keyTotalXP, newTotalXP);
    
    final newLevel = _calculateLevel(newTotalXP);
    
    // Trả về true nếu level up
    return newLevel > oldLevel;
  }

  // Lấy progress % trong level hiện tại
  Future<double> getLevelProgress() async {
    final currentXP = await getCurrentLevelXP();
    final xpNeeded = await getXPNeededForNextLevel();
    return currentXP / xpNeeded;
  }

  // Lấy thông tin level đầy đủ
  Future<LevelInfo> getLevelInfo() async {
    final totalXP = await getTotalXP();
    final level = await getCurrentLevel();
    final currentLevelXP = await getCurrentLevelXP();
    final xpNeeded = await getXPNeededForNextLevel();
    final progress = await getLevelProgress();
    
    return LevelInfo(
      level: level,
      totalXP: totalXP,
      currentLevelXP: currentLevelXP,
      xpNeededForNextLevel: xpNeeded,
      progress: progress,
    );
  }

  // Achievements dựa trên level
  List<Achievement> getAchievements(int level) {
    return _allAchievements.where((a) => level >= a.requiredLevel).toList();
  }

  // Achievements chưa đạt được
  List<Achievement> getLockedAchievements(int level) {
    return _allAchievements.where((a) => level < a.requiredLevel).toList();
  }

  // Danh sách achievements
  static final List<Achievement> _allAchievements = [
    Achievement(
      id: 'beginner',
      title: 'Người mới',
      description: 'Đạt level 5',
      requiredLevel: 5,
      icon: '🌱',
    ),
    Achievement(
      id: 'intermediate',
      title: 'Trung cấp',
      description: 'Đạt level 10',
      requiredLevel: 10,
      icon: '⭐',
    ),
    Achievement(
      id: 'advanced',
      title: 'Cao cấp',
      description: 'Đạt level 20',
      requiredLevel: 20,
      icon: '🔥',
    ),
    Achievement(
      id: 'expert',
      title: 'Chuyên gia',
      description: 'Đạt level 30',
      requiredLevel: 30,
      icon: '💎',
    ),
    Achievement(
      id: 'master',
      title: 'Bậc thầy',
      description: 'Đạt level 50',
      requiredLevel: 50,
      icon: '👑',
    ),
    Achievement(
      id: 'legend',
      title: 'Huyền thoại',
      description: 'Đạt level 100',
      requiredLevel: 100,
      icon: '🏆',
    ),
  ];
}

class LevelInfo {
  final int level;
  final int totalXP;
  final int currentLevelXP;
  final int xpNeededForNextLevel;
  final double progress;

  LevelInfo({
    required this.level,
    required this.totalXP,
    required this.currentLevelXP,
    required this.xpNeededForNextLevel,
    required this.progress,
  });
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final int requiredLevel;
  final String icon;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredLevel,
    required this.icon,
  });
}
