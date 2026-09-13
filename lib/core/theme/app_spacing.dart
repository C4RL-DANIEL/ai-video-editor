/// Consistent spacing & sizing tokens for the AI Video Editor.
///
/// Follows an 8px baseline grid. All values are logical pixels.
abstract final class AppSpacing {
  AppSpacing._(); // prevent instantiation

  // ---------------------------------------------------------------------------
  // Base Spacing Scale (8px grid)
  // ---------------------------------------------------------------------------
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double xxxxl = 48;
  static const double xxxxxl = 64;

  // ---------------------------------------------------------------------------
  // Semantic Spacing
  // ---------------------------------------------------------------------------
  static const double pagePadding = xl;
  static const double sectionGap = xxl;
  static const double cardPadding = base;
  static const double listItemPadding = base;
  static const double inlineGap = sm;
  static const double fieldGap = md;
  static const double buttonPaddingH = xl;
  static const double buttonPaddingV = md;

  // ---------------------------------------------------------------------------
  // Border Radii
  // ---------------------------------------------------------------------------
  static const double radiusXs = 4;
  static const double radiusSm = 6;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;
  static const double radiusXxl = 20;
  static const double radiusFull = 9999;

  // ---------------------------------------------------------------------------
  // Icon Sizes
  // ---------------------------------------------------------------------------
  static const double iconXs = 12;
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;
  static const double iconXxl = 48;

  // ---------------------------------------------------------------------------
  // Touch Targets (accessibility minimum: 44x44)
  // ---------------------------------------------------------------------------
  static const double touchTargetMin = 44;
  static const double touchTargetSmall = 32;
  static const double touchTargetDefault = 48;

  // ---------------------------------------------------------------------------
  // Component Heights
  // ---------------------------------------------------------------------------
  static const double heightButton = 44;
  static const double heightButtonSmall = 32;
  static const double heightInput = 44;
  static const double heightAppBar = 56;
  static const double heightTabBar = 44;
  static const double heightBottomBar = 64;
  static const double heightToolbar = 48;
  static const double heightTimeline = 120;
  static const double heightMiniPlayer = 64;

  // ---------------------------------------------------------------------------
  // Editor-specific Sizing
  // ---------------------------------------------------------------------------
  static const double timelineTrackHeight = 36;
  static const double timelineClipMinWidth = 60;
  static const double timelinePlayheadWidth = 2;
  static const double timelineHandleWidth = 8;
  static const double timelineHeaderHeight = 28;
  static const double timelineZoomHandleHeight = 16;
  static const double previewAspectRatio = 16 / 9;
  static const double waveformHeight = 40;
}
