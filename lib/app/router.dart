import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/models/algorithm_info.dart';
import '../features/auth/auth_provider.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/profile_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/catalog/category_screen.dart';
import '../features/home/home_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/topic/topic_screen.dart';

GoRouter buildRouter(
  List<AlgorithmInfo> algorithms, {
  required WidgetRef ref,
  required Listenable refreshListenable,
}) =>
    GoRouter(
      initialLocation: '/',
      refreshListenable: refreshListenable,
      redirect: (context, state) {
        final authState = ref.read(authProvider);
        final goingToAuthPages =
            state.matchedLocation == '/login' || state.matchedLocation == '/register';

        if (authState is AuthSessionSignedOut && state.matchedLocation == '/profile') {
          return '/login';
        }
        if (authState is AuthSessionSignedIn && goingToAuthPages) {
          return '/profile';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
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
            final algorithm = algorithms.firstWhere((a) => a.id == id);
            return TopicScreen(algorithm: algorithm);
          },
        ),
        GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
        GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      ],
    );
