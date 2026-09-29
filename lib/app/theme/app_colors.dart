import 'package:flutter/material.dart';

class AppColors {
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color primary;
  final Color onPrimary;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color compare;
  final Color swap;
  final Color sorted;
  final Color marker;
  final Color success;
  final Color error;

  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.primary,
    required this.onPrimary,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.compare,
    required this.swap,
    required this.sorted,
    required this.marker,
    required this.success,
    required this.error,
  });

  static const light = AppColors(
    background: Color(0xFFF5F6FA),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFECEEF5),
    primary: Color(0xFF3D5AFE),
    onPrimary: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF1B1D28),
    textSecondary: Color(0xFF6B6F80),
    border: Color(0xFFDFE2ED),
    compare: Color(0xFFFFA726),
    swap: Color(0xFFEF5350),
    sorted: Color(0xFF4CAF50),
    marker: Color(0xFF3D5AFE),
    success: Color(0xFF4CAF50),
    error: Color(0xFFEF5350),
  );

  static const dark = AppColors(
    background: Color(0xFF12131A),
    surface: Color(0xFF1C1E29),
    surfaceVariant: Color(0xFF262838),
    primary: Color(0xFF7C8CFF),
    onPrimary: Color(0xFF12131A),
    textPrimary: Color(0xFFF2F3F8),
    textSecondary: Color(0xFFA5A8B8),
    border: Color(0xFF34364A),
    compare: Color(0xFFFFB74D),
    swap: Color(0xFFEF6B68),
    sorted: Color(0xFF66BB6A),
    marker: Color(0xFF7C8CFF),
    success: Color(0xFF66BB6A),
    error: Color(0xFFEF6B68),
  );
}

extension AppColorsContext on BuildContext {
  AppColors get colors =>
      Theme.of(this).brightness == Brightness.dark ? AppColors.dark : AppColors.light;
}
