/// Data models for video effects used by [VideoEffectsService].

// ---------------------------------------------------------------------------
// Caption
// ---------------------------------------------------------------------------

/// A single caption segment to overlay on the video.
class CaptionSegment {
  /// The text to display.
  final String text;

  /// When the caption appears (in seconds from the start of the clip).
  final double startTime;

  /// When the caption disappears (in seconds).
  final double endTime;

  /// Visual style for this caption.
  final CaptionStyle style;

  const CaptionSegment({
    required this.text,
    required this.startTime,
    required this.endTime,
    this.style = const CaptionStyle(),
  });

  /// Duration of this caption in seconds.
  double get duration => endTime - startTime;

  CaptionSegment copyWith({
    String? text,
    double? startTime,
    double? endTime,
    CaptionStyle? style,
  }) {
    return CaptionSegment(
      text: text ?? this.text,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      style: style ?? this.style,
    );
  }
}

/// Styling options for a caption.
class CaptionStyle {
  /// Font size in pixels (default 28).
  final int fontSize;

  /// Font color as an FFmpeg color string, e.g. `'white'`, `'#FFFFFF'`, `'yellow'`.
  final String fontColor;

  /// Horizontal position as a fraction of width (0.0 – 1.0). Default 0.5 = center.
  final double xPosition;

  /// Vertical position as a fraction of height (0.0 – 1.0). Default 0.9 = near bottom.
  final double yPosition;

  /// Whether to draw a semi-transparent background box behind the text.
  final bool hasBackground;

  /// Background box color (FFmpeg color string).
  final String backgroundColor;

  /// Background box opacity (0.0 – 1.0).
  final double backgroundOpacity;

  /// Border / outline width around text (pixels).
  final int borderWidth;

  /// Border color (FFmpeg color string).
  final String borderColor;

  /// Optional font family path or name. When null, FFmpeg uses its default font.
  final String? fontFamily;

  const CaptionStyle({
    this.fontSize = 28,
    this.fontColor = 'white',
    this.xPosition = 0.5,
    this.yPosition = 0.9,
    this.hasBackground = true,
    this.backgroundColor = 'black@0.6',
    this.backgroundOpacity = 0.6,
    this.borderWidth = 2,
    this.borderColor = 'black',
    this.fontFamily,
  });
}

// ---------------------------------------------------------------------------
// Zoom (Ken Burns)
// ---------------------------------------------------------------------------

/// Direction of the Ken Burns zoom effect.
enum ZoomType { zoomIn, zoomOut }

/// Ken Burns (zoom / pan) effect parameters.
class ZoomEffect {
  /// Whether to zoom in or zoom out.
  final ZoomType type;

  /// Intensity multiplier (1.0 – 5.0). Higher = more dramatic zoom.
  final double intensity;

  /// Duration of the effect in seconds. Should match clip length for full-clip effect.
  final double duration;

  /// Frames per second used for the zoompan filter (default 30).
  final int fps;

  const ZoomEffect({
    this.type = ZoomType.zoomIn,
    this.intensity = 1.5,
    this.duration = 5.0,
    this.fps = 30,
  });
}

// ---------------------------------------------------------------------------
// Color grading
// ---------------------------------------------------------------------------

/// Preset color grading moods.
enum ColorGrade {
  warm,
  cool,
  highContrast,
  vintage,
  cinematic,
}

// ---------------------------------------------------------------------------
// Sound effects
// ---------------------------------------------------------------------------

/// Types of sound effects that can be generated / applied.
enum SFXType {
  whoosh,
  impact,
  ding,
  beep,
  click,
}

/// Describes when and which sound effect to play.
class SFXTiming {
  /// The kind of SFX to generate.
  final SFXType type;

  /// Timestamp (seconds) at which the SFX should start.
  final double timestamp;

  /// Volume multiplier (0.0 – 1.0). Default 0.8.
  final double volume;

  /// Duration of the generated SFX in seconds (default 0.5).
  final double duration;

  const SFXTiming({
    required this.type,
    required this.timestamp,
    this.volume = 0.8,
    this.duration = 0.5,
  });
}

// ---------------------------------------------------------------------------
// Speed
// ---------------------------------------------------------------------------

/// Describes a speed-change segment.
class SpeedEffect {
  /// Playback speed multiplier. < 1 = slow motion, > 1 = fast forward.
  final double speed;

  /// Start of the speed effect in seconds (null = start of clip).
  final double? startTime;

  /// End of the speed effect in seconds (null = end of clip).
  final double? endTime;

  const SpeedEffect({
    required this.speed,
    this.startTime,
    this.endTime,
  });
}

// ---------------------------------------------------------------------------
// Export settings
// ---------------------------------------------------------------------------

/// Quality presets for the final export.
enum ExportQuality { low, medium, high, ultra }

/// Resolution presets.
enum ExportResolution { r480, r720, r1080, rOriginal }

/// Settings that control the final exported video.
class ExportSettings {
  /// Quality preset.
  final ExportQuality quality;

  /// Resolution preset.
  final ExportResolution resolution;

  /// Frames per second (default 30).
  final int fps;

  /// Whether to include audio in the output.
  final bool includeAudio;

  const ExportSettings({
    this.quality = ExportQuality.high,
    this.resolution = ExportResolution.r1080,
    this.fps = 30,
    this.includeAudio = true,
  });

  /// Returns the CRF value for the chosen quality.
  int get crf {
    switch (quality) {
      case ExportQuality.low:
        return 28;
      case ExportQuality.medium:
        return 23;
      case ExportQuality.high:
        return 18;
      case ExportQuality.ultra:
        return 14;
    }
  }

  /// Returns the scale string for FFmpeg (e.g. `'1920:1080'`).
  String get scaleString {
    switch (resolution) {
      case ExportResolution.r480:
        return '854:480';
      case ExportResolution.r720:
        return '1280:720';
      case ExportResolution.r1080:
        return '1920:1080';
      case ExportResolution.rOriginal:
        return '-2: -2'; // preserve aspect ratio
    }
  }
}

// ---------------------------------------------------------------------------
// Intro / Outro
// ---------------------------------------------------------------------------

/// Describes a branded intro or outro segment.
class IntroOutro {
  /// Text to display.
  final String text;

  /// Duration in seconds.
  final double duration;

  /// Background color (FFmpeg color string, e.g. `'0x000000'`).
  final String backgroundColor;

  /// Text color.
  final String textColor;

  /// Font size.
  final int fontSize;

  const IntroOutro({
    required this.text,
    this.duration = 3.0,
    this.backgroundColor = 'black',
    this.textColor = 'white',
    this.fontSize = 48,
  });
}
