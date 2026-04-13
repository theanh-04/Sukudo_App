import 'package:go_router/go_router.dart';
import '../features/game/presentation/pages/game_page.dart';
import '../features/game/presentation/pages/select_game_page.dart';
import '../features/game/presentation/pages/stats_page.dart';
import '../features/game/presentation/pages/daily_page.dart';
import '../features/game/presentation/pages/settings_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/select',
    routes: [
      GoRoute(
        path: '/select',
        builder: (context, state) => const SelectGamePage(),
      ),
      GoRoute(
        path: '/game',
        builder: (context, state) {
          final sudokuString = state.uri.queryParameters['sudoku'];
          final difficulty = state.uri.queryParameters['difficulty'];
          final isDaily = state.uri.queryParameters['isDaily'] == 'true';
          return GamePage(
            sudokuString: sudokuString,
            difficulty: difficulty,
            isDaily: isDaily,
          );
        },
      ),
      GoRoute(
        path: '/stats',
        builder: (context, state) => const StatsPage(),
      ),
      GoRoute(
        path: '/daily',
        builder: (context, state) => const DailyPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
}
