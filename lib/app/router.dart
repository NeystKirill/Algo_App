import 'package:go_router/go_router.dart';

import '../features/algorithms/registry.dart';
import '../features/catalog/category_screen.dart';
import '../features/home/home_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/topic/topic_screen.dart';
import '../core/models/algorithm_info.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/category/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final category = AlgoCategory.values.firstWhere((c) => c.name == id);
        return CategoryScreen(category: category);
      },
    ),
    GoRoute(
      path: '/topic/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final algorithm = algorithmRegistry.firstWhere((a) => a.id == id);
        return TopicScreen(algorithm: algorithm);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
