import 'package:go_router/go_router.dart';
import '../../features/game/presentation/pages/level_selector_page.dart';
import '../../features/game/presentation/pages/game_page.dart';

/// App router configuration
class AppRouter {
  AppRouter._();

  static const String levelSelector = '/';
  static const String game = '/game';

  static final GoRouter router = GoRouter(
    initialLocation: levelSelector,
    routes: [
      GoRoute(
        path: levelSelector,
        name: 'level-selector',
        builder: (context, state) => const LevelSelectorPage(),
      ),
      GoRoute(
        path: game,
        name: 'game',
        builder: (context, state) {
          final level = state.extra as int? ?? 1;
          return GamePage(level: level);
        },
      ),
    ],
  );
}
