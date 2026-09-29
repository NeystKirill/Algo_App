import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'app/theme/app_theme.dart';
import 'features/settings/settings_provider.dart';

void main() {
  runApp(const ProviderScope(child: AlgoLearningApp()));
}

class AlgoLearningApp extends ConsumerWidget {
  const AlgoLearningApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(settingsProvider).themeMode;

    return MaterialApp.router(
      title: 'Algo & DS Learning App',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: appRouter,
    );
  }
}
