import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressState {
  final Set<String> completed;
  final Set<String> favorites;

  const ProgressState({this.completed = const {}, this.favorites = const {}});

  ProgressState copyWith({Set<String>? completed, Set<String>? favorites}) {
    return ProgressState(
      completed: completed ?? this.completed,
      favorites: favorites ?? this.favorites,
    );
  }

  double completionRate(List<String> algorithmIds) {
    if (algorithmIds.isEmpty) return 0;
    final done = algorithmIds.where(completed.contains).length;
    return done / algorithmIds.length;
  }
}

class ProgressNotifier extends Notifier<ProgressState> {
  static const _completedKey = 'progress_completed';
  static const _favoritesKey = 'progress_favorites';

  @override
  ProgressState build() {
    _load();
    return const ProgressState();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = ProgressState(
      completed: (prefs.getStringList(_completedKey) ?? []).toSet(),
      favorites: (prefs.getStringList(_favoritesKey) ?? []).toSet(),
    );
  }

  Future<void> toggleFavorite(String algorithmId) async {
    final favorites = Set<String>.from(state.favorites);
    if (favorites.contains(algorithmId)) {
      favorites.remove(algorithmId);
    } else {
      favorites.add(algorithmId);
    }
    state = state.copyWith(favorites: favorites);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favorites.toList());
  }

  Future<void> markCompleted(String algorithmId) async {
    if (state.completed.contains(algorithmId)) return;
    final completed = Set<String>.from(state.completed)..add(algorithmId);
    state = state.copyWith(completed: completed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_completedKey, completed.toList());
  }

  bool isFavorite(String algorithmId) => state.favorites.contains(algorithmId);

  bool isCompleted(String algorithmId) => state.completed.contains(algorithmId);
}

final progressProvider = NotifierProvider<ProgressNotifier, ProgressState>(ProgressNotifier.new);
