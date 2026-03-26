// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Default Colors
  static const Color defaultPrimaryColor = Color(0xFF2ECC71); // Brand green
  static const Color secondaryColor = Color(0xFF702ECC); // Brand purple
  static const Color expenseColor = Color(0xFFE53935); // Red
  static const Color incomeColor = Color(0xFF43A047); // Green
  static const Color warningColor = Color(0xFFCC702E); // Brand orange
  static const Color errorColor = Color(0xFFD32F2F);

  // Budget alert colors
  static const Color budgetWarningColor =
      Color(0xFFCC702E); // Brand orange - 80%
  static const Color budgetCriticalColor = Color(0xFFE53935); // Red - 100%
  static const Color budgetSuccessColor =
      Color(0xFF43A047); // Green - under budget

  // Preset theme colors for color picker
  static const List<Color> themeColorOptions = [
    Color(0xFF2ECC71), // Brand green (default)
    Color(0xFF702ECC), // Brand purple
    Color(0xFFCC702E), // Brand orange
    Color(0xFFC2185B), // Pink
    Color(0xFF00796B), // Teal
    Color(0xFF5D4037), // Brown
    Color(0xFF455A64), // Blue Grey
  ];

  // Category Colors
  static List<Color> get categoryColors => [
        const Color(0xFF2196F3), // Blue
        const Color(0xFF4CAF50), // Green
        const Color(0xFFFF9800), // Orange
        const Color(0xFF9C27B0), // Purple
        const Color(0xFFE91E63), // Pink
        const Color(0xFF00BCD4), // Cyan
        const Color(0xFFFF5722), // Deep Orange
        const Color(0xFF795548), // Brown
        const Color(0xFF607D8B), // Blue Grey
        const Color(0xFFCDDC39), // Lime
      ];

  // Factory to create theme with custom primary color
  static ThemeData light({Color? primaryColor}) {
    final color = primaryColor ?? defaultPrimaryColor;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Factory to create dark theme with custom primary color
  static ThemeData dark({Color? primaryColor}) {
    final color = primaryColor ?? defaultPrimaryColor;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Legacy getters for backward compatibility (use default color)
  static ThemeData get lightTheme => light(primaryColor: defaultPrimaryColor);
  static ThemeData get darkTheme => dark(primaryColor: defaultPrimaryColor);
}
