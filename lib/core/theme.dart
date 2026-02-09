import 'package:flutter/material.dart';

abstract class AppTheme {
  static const _seedColor = Color(0xFF2E7D32);

  static final light = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: _seedColor,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(centerTitle: true),
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  // Risk level colors
  static const safeColor = Color(0xFF2E7D32);
  static const cautionColor = Color(0xFFF57F17);
  static const dangerColor = Color(0xFFC62828);

  static const safeBg = Color(0xFFE8F5E9);
  static const cautionBg = Color(0xFFFFF9C4);
  static const dangerBg = Color(0xFFFFEBEE);
}
