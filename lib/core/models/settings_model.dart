/// Model cho settings trong database
/// 
/// Lưu các cài đặt người dùng:
/// - Theme (light/dark)
/// - Sound effects
/// - Timer display
/// - Mistakes limit
/// - Highlight duplicates
class SettingsModel {
  final int id; // Luôn là 1 (chỉ có 1 row settings)
  final String theme;
  final bool soundEffects;
  final bool timerDisplay;
  final bool mistakesLimit;
  final bool highlightDuplicates;

  SettingsModel({
    this.id = 1,
    required this.theme,
    required this.soundEffects,
    required this.timerDisplay,
    required this.mistakesLimit,
    required this.highlightDuplicates,
  });

  /// Chuyển từ Map (database) sang Model
  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      id: map['id'] as int,
      theme: map['theme'] as String,
      soundEffects: (map['sound_effects'] as int) == 1,
      timerDisplay: (map['timer_display'] as int) == 1,
      mistakesLimit: (map['mistakes_limit'] as int) == 1,
      highlightDuplicates: (map['highlight_duplicates'] as int) == 1,
    );
  }

  /// Chuyển từ Model sang Map (để update database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'theme': theme,
      'sound_effects': soundEffects ? 1 : 0,
      'timer_display': timerDisplay ? 1 : 0,
      'mistakes_limit': mistakesLimit ? 1 : 0,
      'highlight_duplicates': highlightDuplicates ? 1 : 0,
    };
  }

  /// Copy with - tạo bản sao với một số field thay đổi
  SettingsModel copyWith({
    int? id,
    String? theme,
    bool? soundEffects,
    bool? timerDisplay,
    bool? mistakesLimit,
    bool? highlightDuplicates,
  }) {
    return SettingsModel(
      id: id ?? this.id,
      theme: theme ?? this.theme,
      soundEffects: soundEffects ?? this.soundEffects,
      timerDisplay: timerDisplay ?? this.timerDisplay,
      mistakesLimit: mistakesLimit ?? this.mistakesLimit,
      highlightDuplicates: highlightDuplicates ?? this.highlightDuplicates,
    );
  }

  @override
  String toString() {
    return 'SettingsModel(theme: $theme, soundEffects: $soundEffects, timerDisplay: $timerDisplay, mistakesLimit: $mistakesLimit, highlightDuplicates: $highlightDuplicates)';
  }
}
