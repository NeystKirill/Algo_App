import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final ThemeMode themeMode;
  final int animationSpeedMs;
  final String codeLanguage;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.animationSpeedMs = 700,
    this.codeLanguage = 'dart',
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    int? animationSpeedMs,
    String? codeLanguage,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      animationSpeedMs: animationSpeedMs ?? this.animationSpeedMs,
      codeLanguage: codeLanguage ?? this.codeLanguage,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  static const _themeKey = 'settings_theme_mode';
  static const _speedKey = 'settings_animation_speed';
  static const _langKey = 'settings_code_language';

  @override
  SettingsState build() {
    _load();
    return const SettingsState();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    state = SettingsState(
      themeMode: themeIndex != null ? ThemeMode.values[themeIndex] : ThemeMode.system,
      animationSpeedMs: prefs.getInt(_speedKey) ?? 700,
      codeLanguage: prefs.getString(_langKey) ?? 'dart',
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  Future<void> setAnimationSpeed(int ms) async {
    state = state.copyWith(animationSpeedMs: ms);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_speedKey, ms);
  }

  Future<void> setCodeLanguage(String language) async {
    state = state.copyWith(codeLanguage: language);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, language);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
