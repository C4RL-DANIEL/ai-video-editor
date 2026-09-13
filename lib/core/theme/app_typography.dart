import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Premium typography system for the AI Video Editor.
///
/// Uses Inter as the primary typeface for its exceptional readability
/// at both small UI sizes and large display sizes — a hallmark of
/// professional creative tools.
abstract final class AppTypography {
  // ---------------------------------------------------------------------------
  // Font Family
  // ---------------------------------------------------------------------------

  static const String _fontFamily = 'Inter';

  /// Base [TextStyle] with the Inter font family pre-applied.
  static TextStyle _base({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    double letterSpacing = 0,
    double height = 1.5,
    Color color = AppColors.textPrimary,
    TextDecoration? decoration,
    TextDecorationStyle? decorationStyle,
    Color? decorationColor,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
      decoration: decoration,
      decorationStyle: decorationStyle,
      decorationColor: decorationColor,
    );
  }

  // ---------------------------------------------------------------------------
  // Display — Hero / Splash screen large text
  // ---------------------------------------------------------------------------

  /// 56sp / Bold / -1.5 tracking
  static TextStyle get displayLarge => _base(
        fontSize: 56,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        height: 1.1,
      );

  /// 48sp / Bold / -1.25 tracking
  static TextStyle get displayMedium => _base(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.25,
        height: 1.15,
      );

  /// 40sp / SemiBold / -1 tracking
  static TextStyle get displaySmall => _base(
        fontSize: 40,
        fontWeight: FontWeight.w600,
        letterSpacing: -1.0,
        height: 1.2,
      );

  // ---------------------------------------------------------------------------
  // Headings — Section & page titles
  // ---------------------------------------------------------------------------

  /// 32sp / SemiBold / -0.75 tracking
  static TextStyle get headlineLarge => _base(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.75,
        height: 1.25,
      );

  /// 28sp / SemiBold / -0.5 tracking
  static TextStyle get headlineMedium => _base(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        height: 1.3,
      );

  /// 24sp / SemiBold / -0.25 tracking
  static TextStyle get headlineSmall => _base(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        height: 1.35,
      );

  // ---------------------------------------------------------------------------
  // Titles — Card titles, toolbar labels
  // ---------------------------------------------------------------------------

  /// 20sp / SemiBold / 0 tracking
  static TextStyle get titleLarge => _base(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
      );

  /// 18sp / Medium / 0 tracking
  static TextStyle get titleMedium => _base(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.4,
      );

  /// 16sp / Medium / 0.1 tracking
  static TextStyle get titleSmall => _base(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
      );

  // ---------------------------------------------------------------------------
  // Body — Primary content text
  // ---------------------------------------------------------------------------

  /// 16sp / Regular / 0.15 tracking
  static TextStyle get bodyLarge => _base(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.5,
      );

  /// 14sp / Regular / 0.25 tracking — **default body**
  static TextStyle get bodyMedium => _base(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.5,
      );

  /// 12sp / Regular / 0.4 tracking
  static TextStyle get bodySmall => _base(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.5,
      );

  // ---------------------------------------------------------------------------
  // Labels — Buttons, badges, chips, input labels
  // ---------------------------------------------------------------------------

  /// 14sp / Medium / 0.1 tracking — buttons, primary labels
  static TextStyle get labelLarge => _base(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
      );

  /// 12sp / Medium / 0.5 tracking — chips, badges, secondary labels
  static TextStyle get labelMedium => _base(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.4,
      );

  /// 10sp / Medium / 0.5 tracking — fine print, captions, metadata
  static TextStyle get labelSmall => _base(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.4,
      );

  // ---------------------------------------------------------------------------
  // Captions & Overlays — Video timeline labels, timecodes
  // ---------------------------------------------------------------------------

  /// 11sp / Regular / 0.3 tracking — timeline clip labels
  static TextStyle get caption => _base(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        height: 1.4,
      );

  /// Monospace-style caption for timecodes (uses Inter's tabular figures).
  static TextStyle get timecode => _base(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.8,
        height: 1.4,
      );

  // ---------------------------------------------------------------------------
  // Overline — Section overlines, category labels
  // ---------------------------------------------------------------------------

  /// 10sp / SemiBold / 1.5 tracking / uppercase
  static TextStyle get overline => _base(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        height: 1.4,
      );

  // ---------------------------------------------------------------------------
  // Helpers — Colored text variants
  // ---------------------------------------------------------------------------

  /// [bodyMedium] colored with [AppColors.textSecondary].
  static TextStyle get bodyMediumSecondary =>
      bodyMedium.copyWith(color: AppColors.textSecondary);

  /// [bodySmall] colored with [AppColors.textTertiary].
  static TextStyle get bodySmallTertiary =>
      bodySmall.copyWith(color: AppColors.textTertiary);

  /// [labelLarge] colored with [AppColors.accent].
  static TextStyle get labelLargeAccent =>
      labelLarge.copyWith(color: AppColors.accent);

  /// [caption] colored with [AppColors.textTertiary].
  static TextStyle get captionTertiary =>
      caption.copyWith(color: AppColors.textTertiary);

  // ---------------------------------------------------------------------------
  // Material TextTheme — plug directly into ThemeData
  // ---------------------------------------------------------------------------

  /// Light-on-dark [TextTheme] for the primary dark theme.
  static TextTheme get darkTextTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );

  /// Dark-on-light [TextTheme] for the optional light theme.
  static TextTheme get lightTextTheme => TextTheme(
        displayLarge: displayLarge.copyWith(color: AppColors.gray950),
        displayMedium: displayMedium.copyWith(color: AppColors.gray950),
        displaySmall: displaySmall.copyWith(color: AppColors.gray950),
        headlineLarge: headlineLarge.copyWith(color: AppColors.gray950),
        headlineMedium: headlineMedium.copyWith(color: AppColors.gray950),
        headlineSmall: headlineSmall.copyWith(color: AppColors.gray950),
        titleLarge: titleLarge.copyWith(color: AppColors.gray950),
        titleMedium: titleMedium.copyWith(color: AppColors.gray950),
        titleSmall: titleSmall.copyWith(color: AppColors.gray950),
        bodyLarge: bodyLarge.copyWith(color: AppColors.gray900),
        bodyMedium: bodyMedium.copyWith(color: AppColors.gray800),
        bodySmall: bodySmall.copyWith(color: AppColors.gray600),
        labelLarge: labelLarge.copyWith(color: AppColors.gray900),
        labelMedium: labelMedium.copyWith(color: AppColors.gray700),
        labelSmall: labelSmall.copyWith(color: AppColors.gray600),
      );
}
