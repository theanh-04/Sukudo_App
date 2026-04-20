import 'package:hive/hive.dart';

part 'settings_hive.g.dart';

/// Hive Model cho Settings
/// 
/// @HiveType: Đánh dấu class này là Hive model
/// typeId: ID duy nhất cho model này (0-223)
@HiveType(typeId: 1)
class SettingsHive extends HiveObject {
  @HiveField(0)
  String theme;

  @HiveField(1)
  bool soundEffects;

  @HiveField(2)
  bool timerDisplay;

  @HiveField(3)
  bool mistakesLimit;

  @HiveField(4)
  bool highlightDuplicates;

  SettingsHive({
    this.theme = 'light',
    this.soundEffects = true,
    this.timerDisplay = true,
    this.mistakesLimit = false,
    this.highlightDuplicates = true,
  });

  @override
  String toString() {
    return 'SettingsHive(theme: $theme, soundEffects: $soundEffects, timerDisplay: $timerDisplay, mistakesLimit: $mistakesLimit, highlightDuplicates: $highlightDuplicates)';
  }
}
