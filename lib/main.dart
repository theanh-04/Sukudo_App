import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/services/storage_service.dart';
import 'core/services/level_service.dart';
import 'core/services/settings_service.dart';
import 'core/services/hive_service.dart';
import 'core/theme/app_theme.dart';
import 'features/game/presentation/providers/game_provider.dart';
import 'features/game/presentation/providers/sudoku_provider.dart';
import 'features/game/presentation/providers/timer_provider.dart';
import 'routes/app_router.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Hive (chạy trên Web + Mobile + Desktop)
  await HiveService.instance.init();
  
  // Khởi tạo storage (vẫn cần cho một số dữ liệu tạm thời)
  await StorageService.instance.init();
  
  // Khởi tạo level service
  await LevelService().initialize();
  
  // Khởi tạo settings từ Hive
  await SettingsService.instance.loadSettings();
  
  // Khóa màn hình dọc
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: SettingsService.instance),
        ChangeNotifierProvider(create: (_) => SudokuProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
      ],
      child: Consumer<SettingsService>(
        builder: (context, settings, _) {
          return MaterialApp.router(
            title: 'Super Sudoku',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: _getThemeMode(settings.theme),
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }

  ThemeMode _getThemeMode(String theme) {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
