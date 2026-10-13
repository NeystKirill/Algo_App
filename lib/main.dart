import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/router.dart';
import 'app/theme/app_theme.dart';
import 'core/api_config.dart';
import 'core/models/algorithm_info.dart';
import 'features/algorithms/algorithms_provider.dart';
import 'features/algorithms/algorithms_repository.dart';
import 'features/auth/auth_provider.dart';
import 'features/settings/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final algorithms = await fetchAlgorithms();
  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);
  runApp(
    ProviderScope(
      overrides: [algorithmsProvider.overrideWithValue(algorithms)],
      child: AlgoLearningApp(algorithms: algorithms),
    ),
  );
}

/// Notifies [GoRouter] to re-run its `redirect` callback whenever the
/// auth state changes (sign in / sign out), without rebuilding the router
/// (and therefore without resetting navigation state) on every widget build.
class _GoRouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

class AlgoLearningApp extends ConsumerStatefulWidget {
  const AlgoLearningApp({super.key, required this.algorithms});

  final List<AlgorithmInfo> algorithms;

  @override
  ConsumerState<AlgoLearningApp> createState() => _AlgoLearningAppState();
}

class _AlgoLearningAppState extends ConsumerState<AlgoLearningApp> {
  final _refreshNotifier = _GoRouterRefreshNotifier();
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = buildRouter(
      widget.algorithms,
      ref: ref,
      refreshListenable: _refreshNotifier,
    );
  }

  @override
  void dispose() {
    _refreshNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ref.listen must be called from build (not initState) per Riverpod's
    // debugDoingBuild assertion; it re-runs the router's redirect callback
    // whenever auth state changes, e.g. kicking a signed-out user off /profile.
    ref.listen(authProvider, (previous, next) => _refreshNotifier.refresh());
    final themeMode = ref.watch(settingsProvider).themeMode;
    return MaterialApp.router(
      title: 'Algo & DS Learning App',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: _router,
    );
  }
}
