import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  /// Same modern Ethiopic sans used in the reference mezmur player UI.
  static const String fontFamily = 'NotoSansEthiopic';

  static TextTheme _textTheme() {
    final base = ThemeData.dark().textTheme.apply(
      fontFamily: fontFamily,
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    );
    TextStyle regular(TextStyle? style) =>
        (style ?? const TextStyle()).copyWith(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w400,
        );
    return base.copyWith(
      displayLarge: regular(base.displayLarge),
      displayMedium: regular(base.displayMedium),
      displaySmall: regular(base.displaySmall),
      headlineLarge: regular(base.headlineLarge),
      headlineMedium: regular(base.headlineMedium),
      headlineSmall: regular(base.headlineSmall),
      titleLarge: regular(base.titleLarge),
      titleMedium: regular(base.titleMedium),
      titleSmall: regular(base.titleSmall),
      bodyLarge: regular(base.bodyLarge),
      bodyMedium: regular(base.bodyMedium),
      bodySmall: regular(base.bodySmall),
      labelLarge: regular(base.labelLarge),
      labelMedium: regular(base.labelMedium),
      labelSmall: regular(base.labelSmall),
    );
  }

  static ThemeData dark() {
    final textTheme = _textTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.cardLight,
        onPrimary: AppColors.ink,
        secondary: AppColors.accent,
        surface: AppColors.card,
        onSurface: AppColors.ink,
        error: AppColors.danger,
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.ink,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w400,
          color: AppColors.ink,
          fontSize: 20,
        ),
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.2),
        ),
        hintStyle: const TextStyle(
          fontFamily: fontFamily,
          color: AppColors.inkMuted,
        ),
        labelStyle: const TextStyle(fontFamily: fontFamily),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.cardLight
              : AppColors.border,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.cardLight,
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.cardLight,
        foregroundColor: Colors.white,
      ),
      dividerColor: AppColors.border,
    );
  }

  static ThemeData light() => dark();
}
