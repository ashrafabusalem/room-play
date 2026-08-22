import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// Shared sizing constants. The mockup uses a consistent 20px radius on cards
/// and 16px screen gutters.
class AppSizes {
  AppSizes._();

  static const gutter = 16.0;
  static const cardRadius = 20.0;
  static const chipRadius = 14.0;
  static const tileRadius = 16.0;
  static const gapXs = 4.0;
  static const gapS = 8.0;
  static const gapM = 12.0;
  static const gapL = 16.0;
  static const gapXl = 24.0;
  static const bottomNavHeight = 64.0;
}

/// The Latin typeface, matching the mockup.
const kFontFamily = 'Inter';

/// Fallback chain for every text style in the app. Order matters.
///
/// Inter covers Latin only — it has **no Arabic glyphs**, so Arabic would
/// render as boxes without Cairo behind it. Listing Cairo as a fallback rather
/// than swapping the family per locale means mixed strings work too: an Arabic
/// room name next to an English username picks the right face per character.
///
/// The emoji faces are here for the same reason: Android and iOS fall back on
/// their own, but web, desktop and the golden renderer need telling.
const kFontFallback = <String>[
  'Cairo',
  'Segoe UI Emoji',
  'Apple Color Emoji',
  'Noto Color Emoji',
];

class AppTheme {
  AppTheme._();

  static const _fontFamily = kFontFamily;

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      canvasColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.danger,
      ),
      textTheme: _textTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontFamilyFallback: kFontFallback,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontFamilyFallback: kFontFallback,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        hintStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontFamilyFallback: kFontFallback,
          color: AppColors.textTertiary,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: AppColors.primary, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.bgElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    TextStyle s(
      double size,
      FontWeight weight, {
      Color color = AppColors.textPrimary,
      double? height,
    }) => TextStyle(
      fontFamily: _fontFamily,
      fontFamilyFallback: kFontFallback,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );

    return base.copyWith(
      displaySmall: s(28, FontWeight.w800),
      headlineMedium: s(24, FontWeight.w700),
      headlineSmall: s(20, FontWeight.w700),
      titleLarge: s(17, FontWeight.w600),
      titleMedium: s(15, FontWeight.w600),
      titleSmall: s(14, FontWeight.w600),
      bodyLarge: s(15, FontWeight.w400),
      bodyMedium: s(14, FontWeight.w400),
      bodySmall: s(12, FontWeight.w400, color: AppColors.textSecondary),
      labelLarge: s(14, FontWeight.w600),
      labelMedium: s(12, FontWeight.w500, color: AppColors.textSecondary),
      labelSmall: s(11, FontWeight.w500, color: AppColors.textTertiary),
    );
  }
}
