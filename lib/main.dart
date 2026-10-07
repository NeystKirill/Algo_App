import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app/router.dart';
import 'app/theme/app_theme.dart';
import 'features/algorithms/algorithms_provider.dart';
import 'features/algorithms/algorithms_repository.dart';
import 'features/settings/settings_provider.dart';

Future<void> main() async {
  final algorithms = await fetchAlgorithms();
  runApp(
    ProviderScope(
      overrides: [algorithmsProvider.overrideWithValue(algorithms)],
      child: AlgoLearningApp(router: buildRouter(algorithms)),
    ),
  );
}

class AlgoLearningApp extends ConsumerWidget {
  const AlgoLearningApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(settingsProvider).themeMode;

    return MaterialApp.router(
      title: 'Algo & DS Learning App',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}
