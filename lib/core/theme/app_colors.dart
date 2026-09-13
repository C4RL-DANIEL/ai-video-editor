import 'package:flutter/material.dart';

/// Premium professional color palette for the AI Video Editor.
///
/// Inspired by Adobe Premiere meets modern SaaS design language.
/// Dark theme is the primary design mode.
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // Backgrounds (darkest → lightest)
  // ---------------------------------------------------------------------------
  static const Color backgroundPrimary = Color(0xFF0D0D0F);
  static const Color backgroundSecondary = Color(0xFF141418);
  static const Color backgroundTertiary = Color(0xFF1A1A1F);
  static const Color backgroundQuaternary = Color(0xFF222228);

  // ---------------------------------------------------------------------------
  // Surface / Cards
  // ---------------------------------------------------------------------------
  static const Color surface = Color(0xFF141418);
  static const Color surfaceHover = Color(0xFF1A1A1F);
  static const Color surfaceActive = Color(0xFF222228);
  static const Color surfaceElevated = Color(0xFF1E1E24);
  static const Color surfaceOverlay = Color(0x80000000); // rgba(0,0,0,0.5)

  // ---------------------------------------------------------------------------
  // Borders & Dividers
  // ---------------------------------------------------------------------------
  static const Color border = Color(0xFF2A2A32);
  static const Color borderSubtle = Color(0xFF222228);
  static const Color borderStrong = Color(0xFF3A3A44);
  static const Color divider = Color(0xFF222228);

  // ---------------------------------------------------------------------------
  // Accent — Blue (primary brand)
  // ---------------------------------------------------------------------------
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color blue800 = Color(0xFF1E40AF);
  static const Color blue900 = Color(0xFF1E3A8A);

  /// Primary accent — used for CTAs, active states, focused elements.
  static const Color accent = blue500;
  static const Color accentHover = blue400;
  static const Color accentPressed = blue600;

  // ---------------------------------------------------------------------------
  // Accent — Purple (secondary creative accent)
  // ---------------------------------------------------------------------------
  static const Color purple50 = Color(0xFFF5F3FF);
  static const Color purple100 = Color(0xFFEDE9FE);
  static const Color purple200 = Color(0xFFDDD6FE);
  static const Color purple300 = Color(0xFFC4B5FD);
  static const Color purple400 = Color(0xFFA78BFA);
  static const Color purple500 = Color(0xFF8B5CF6);
  static const Color purple600 = Color(0xFF7C3AED);
  static const Color purple700 = Color(0xFF6D28D9);
  static const Color purple800 = Color(0xFF5B21B6);
  static const Color purple900 = Color(0xFF4C1D95);

  /// Secondary accent — used for creative/AI features, badges, highlights.
  static const Color accentSecondary = purple500;
  static const Color accentSecondaryHover = purple400;
  static const Color accentSecondaryPressed = purple600;

  // ---------------------------------------------------------------------------
  // Semantic — Success (Green)
  // ---------------------------------------------------------------------------
  static const Color green50 = Color(0xFFF0FDF4);
  static const Color green100 = Color(0xFFDCFCE7);
  static const Color green200 = Color(0xFFBBF7D0);
  static const Color green300 = Color(0xFF86EFAC);
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green500 = Color(0xFF22C55E);
  static const Color green600 = Color(0xFF16A34A);
  static const Color green700 = Color(0xFF15803D);
  static const Color green800 = Color(0xFF166534);
  static const Color green900 = Color(0xFF14532D);

  static const Color success = green500;
  static const Color successLight = green400;
  static const Color successDark = green600;
  static const Color successSurface = Color(0x1A22C55E); // 10% opacity

  // ---------------------------------------------------------------------------
  // Semantic — Warning (Amber)
  // ---------------------------------------------------------------------------
  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);
  static const Color amber800 = Color(0xFF92400E);
  static const Color amber900 = Color(0xFF78350F);

  static const Color warning = amber500;
  static const Color warningLight = amber400;
  static const Color warningDark = amber600;
  static const Color warningSurface = Color(0x1AF59E0B); // 10% opacity

  // ---------------------------------------------------------------------------
  // Semantic — Error / Danger (Red)
  // ---------------------------------------------------------------------------
  static const Color red50 = Color(0xFFFEF2F2);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red200 = Color(0xFFFECACA);
  static const Color red300 = Color(0xFFFCA5A5);
  static const Color red400 = Color(0xFFF87171);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red700 = Color(0xFFB91C1C);
  static const Color red800 = Color(0xFF991B1B);
  static const Color red900 = Color(0xFF7F1D1D);

  static const Color error = red500;
  static const Color errorLight = red400;
  static const Color errorDark = red600;
  static const Color errorSurface = Color(0x1AEF4444); // 10% opacity

  // ---------------------------------------------------------------------------
  // Neutrals / Text
  // ---------------------------------------------------------------------------
  static const Color white = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color textTertiary = Color(0xFF6B6B6B);
  static const Color textDisabled = Color(0xFF4A4A4A);
  static const Color textInverse = Color(0xFF0D0D0F);

  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFE5E5E5);
  static const Color gray300 = Color(0xFFD4D4D4);
  static const Color gray400 = Color(0xFFA3A3A3);
  static const Color gray500 = Color(0xFF737373);
  static const Color gray600 = Color(0xFF525252);
  static const Color gray700 = Color(0xFF404040);
  static const Color gray800 = Color(0xFF262626);
  static const Color gray900 = Color(0xFF171717);
  static const Color gray950 = Color(0xFF0D0D0D);

  // ---------------------------------------------------------------------------
  // Timeline / Editor-specific
  // ---------------------------------------------------------------------------
  static const Color timelineBackground = Color(0xFF111115);
  static const Color timelineTrack = Color(0xFF1A1A20);
  static const Color timelinePlayhead = blue500;
  static const Color timelineSelection = Color(0x333B82F6); // 20% blue
  static const Color timelineClip = Color(0xFF2A2A32);
  static const Color timelineClipBorder = Color(0xFF3A3A44);
  static const Color timelineWaveform = Color(0xFF4A4A54);

  // ---------------------------------------------------------------------------
  // Scrubber / Progress
  // ---------------------------------------------------------------------------
  static const Color progressTrack = Color(0xFF2A2A32);
  static const Color progressFill = blue500;
  static const Color progressBuffered = Color(0xFF3A3A44);

  // ---------------------------------------------------------------------------
  // Gradients
  // ---------------------------------------------------------------------------
  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [blue600, blue500],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientPurple = LinearGradient(
    colors: [purple600, purple500],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientCreative = LinearGradient(
    colors: [blue500, purple500],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientDarkOverlay = LinearGradient(
    colors: [Colors.transparent, backgroundPrimary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient gradientSurface = LinearGradient(
    colors: [
      Color(0x0FFFFFFF), // rgba(255,255,255,0.06)
      Color(0x05FFFFFF), // rgba(255,255,255,0.02)
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ---------------------------------------------------------------------------
  // Utility: Convert to Material ColorSwatch
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // Convenience aliases (used by feature screens)
  // ---------------------------------------------------------------------------
  static const Color background = backgroundPrimary;
  static const Color textMuted = textTertiary;
  static const Color card = backgroundTertiary;
  static const Color timelineVideo = blue500;
  static const Color timelineAudio = purple500;
  static const Color timelineCaption = green500;
  static const Color timelineEffect = amber500;
  static const Color timelineSfx = Color(0xFF06B6D4);
  static const Color playhead = blue500;

  /// Returns a [MaterialColor] swatch derived from the primary blue accent.
  static MaterialColor get blueSwatch => const MaterialColor(
        0xFF3B82F6,
        <int, Color>{
          50: blue50,
          100: blue100,
          200: blue200,
          300: blue300,
          400: blue400,
          500: blue500,
          600: blue600,
          700: blue700,
          800: blue800,
          900: blue900,
        },
      );
}
