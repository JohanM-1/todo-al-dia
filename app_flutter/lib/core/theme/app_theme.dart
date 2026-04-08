// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color defaultPrimaryColor = Color(0xFF2ECC71);
  static const Color secondaryColor = Color(0xFF6B5CFF);
  static const Color expenseColor = Color(0xFFE0565B);
  static const Color incomeColor = Color(0xFF22B07D);
  static const Color warningColor = Color(0xFFF3A43B);
  static const Color errorColor = Color(0xFFD64B55);

  static const Color budgetWarningColor = warningColor;
  static const Color budgetCriticalColor = expenseColor;
  static const Color budgetSuccessColor = incomeColor;

  static const double radiusSmall = 16;
  static const double radiusMedium = 22;
  static const double radiusLarge = 30;

  static const List<Color> themeColorOptions = [
    Color(0xFF2ECC71),
    Color(0xFF6B5CFF),
    Color(0xFFF39A52),
    Color(0xFFC24D86),
    Color(0xFF138A72),
    Color(0xFF6A5C52),
    Color(0xFF4C6A7D),
  ];

  static const List<Color> categoryColors = [
    Color(0xFF5E8BFF),
    Color(0xFF22B07D),
    Color(0xFFF39A52),
    Color(0xFF8F6CFF),
    Color(0xFFE15D8F),
    Color(0xFF3DBBCF),
    Color(0xFFF06D4F),
    Color(0xFF88715E),
    Color(0xFF5E7A8A),
    Color(0xFFB0C93A),
  ];

  static final Map<int, ThemeData> _lightThemeCache = <int, ThemeData>{};
  static final Map<int, ThemeData> _darkThemeCache = <int, ThemeData>{};

  static ThemeData light({Color? primaryColor}) {
    final color = primaryColor ?? defaultPrimaryColor;
    return _lightThemeCache.putIfAbsent(
      color.toARGB32(),
      () => _buildTheme(
        brightness: Brightness.light,
        primaryColor: color,
      ),
    );
  }

  static ThemeData dark({Color? primaryColor}) {
    final color = primaryColor ?? defaultPrimaryColor;
    return _darkThemeCache.putIfAbsent(
      color.toARGB32(),
      () => _buildTheme(
        brightness: Brightness.dark,
        primaryColor: color,
      ),
    );
  }

  static ThemeData get lightTheme => light(primaryColor: defaultPrimaryColor);
  static ThemeData get darkTheme => dark(primaryColor: defaultPrimaryColor);

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primaryColor,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
      primary: primaryColor,
    );
    final isDark = brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF0D1116) : const Color(0xFFF5F7FB);
    final surfaceHigh =
        isDark ? const Color(0xFF151B22) : const Color(0xFFFFFFFF);
    final outline =
        isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFD8DFEA);
    final subdued =
        isDark ? Colors.white.withValues(alpha: 0.72) : const Color(0xFF607080);
    final textTheme = _textTheme(brightness).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: surface,
      canvasColor: surface,
      splashFactory: InkRipple.splashFactory,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: outline,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: surfaceHigh,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.14 : 0.05),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          side: BorderSide(color: outline),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        selectedColor: scheme.primaryContainer,
        disabledColor: scheme.surfaceContainer,
        secondarySelectedColor: scheme.primaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        labelStyle: textTheme.labelLarge,
        secondaryLabelStyle: textTheme.labelLarge,
        side: BorderSide(color: outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceHigh.withValues(alpha: isDark ? 0.94 : 0.96),
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
        indicatorColor:
            scheme.primaryContainer.withValues(alpha: isDark ? 0.54 : 0.70),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? scheme.onSurface : subdued,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? scheme.primary : subdued,
            size: 22,
          );
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 74,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor:
            scheme.primaryContainer.withValues(alpha: isDark ? 0.56 : 0.74),
        minWidth: 80,
        minExtendedWidth: 228,
        selectedIconTheme: IconThemeData(color: scheme.primary, size: 22),
        unselectedIconTheme: IconThemeData(color: subdued, size: 22),
        selectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        unselectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: subdued,
        ),
        groupAlignment: -0.75,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.92),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: textTheme.bodyMedium?.copyWith(color: subdued),
        labelStyle: textTheme.bodyMedium?.copyWith(color: subdued),
        border: _inputBorder(outline),
        enabledBorder: _inputBorder(outline),
        focusedBorder: _inputBorder(scheme.primary, width: 1.4),
        errorBorder: _inputBorder(scheme.error),
        focusedErrorBorder: _inputBorder(scheme.error, width: 1.4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: outline),
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surfaceHigh,
        contentTextStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: outline),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        iconColor: subdued,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: scheme.surfaceContainerHighest,
      ),
    );
  }

  static TextTheme _textTheme(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? Typography.whiteMountainView
        : Typography.blackMountainView;

    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.7,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      bodyLarge: base.bodyLarge?.copyWith(height: 1.35),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.35),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
