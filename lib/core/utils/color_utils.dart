import 'package:flutter/material.dart';

/// Utility class for color operations in the AI Video Editor app.
class ColorUtils {
  ColorUtils._();

  /// Converts a score (0-100) to a color.
  ///
  /// - Score < 40: Red (poor quality)
  /// - Score 40-70: Amber (medium quality)
  /// - Score > 70: Green (good quality)
  ///
  /// Example:
  /// ```dart
  /// ColorUtils.scoreToColor(25); // Colors.red
  /// ColorUtils.scoreToColor(55); // Colors.amber
  /// ColorUtils.scoreToColor(85); // Colors.green
  /// ```
  static Color scoreToColor(int score) {
    if (score < 0) return Colors.red;
    if (score < 40) {
      // Red gradient from dark to light based on score
      final factor = score / 40.0;
      return Color.lerp(Colors.red.shade900, Colors.red.shade400, factor)!;
    } else if (score <= 70) {
      // Amber gradient
      final factor = (score - 40) / 30.0;
      return Color.lerp(Colors.amber.shade700, Colors.amber.shade400, factor)!;
    } else {
      // Green gradient
      final factor = ((score - 70) / 30.0).clamp(0.0, 1.0);
      return Color.lerp(Colors.green.shade600, Colors.green.shade400, factor)!;
    }
  }

  /// Converts a status string to a color.
  ///
  /// Supported statuses:
  /// - "pending", "waiting": Gray
  /// - "processing", "encoding", "rendering": Blue
  /// - "completed", "done", "success": Green
  /// - "error", "failed": Red
  /// - "warning": Amber
  /// - "exporting", "uploading": Purple
  ///
  /// Example:
  /// ```dart
  /// ColorUtils.statusToColor("completed"); // Colors.green
  /// ColorUtils.statusToColor("error"); // Colors.red
  /// ```
  static Color statusToColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'waiting':
        return Colors.grey;
      case 'processing':
      case 'encoding':
      case 'rendering':
        return Colors.blue;
      case 'completed':
      case 'done':
      case 'success':
        return Colors.green;
      case 'error':
      case 'failed':
        return Colors.red;
      case 'warning':
        return Colors.amber;
      case 'exporting':
      case 'uploading':
        return Colors.purple;
      case 'cancelled':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// Returns a color with the specified opacity, with better null safety.
  ///
  /// This is a convenience method that handles null opacity gracefully.
  ///
  /// Example:
  /// ```dart
  /// ColorUtils.withAlpha(Colors.blue, 0.5); // Colors.blue.withOpacity(0.5)
  /// ```
  static Color withAlpha(Color color, double opacity) {
    return color.withOpacity(opacity.clamp(0.0, 1.0));
  }

  /// Blends two colors together.
  ///
  /// [t] is the blend factor (0.0 = color1, 1.0 = color2).
  ///
  /// Example:
  /// ```dart
  /// ColorUtils.blend(Colors.red, Colors.blue, 0.5); // Purple-ish color
  /// ```
  static Color blend(Color color1, Color color2, double t) {
    return Color.lerp(color1, color2, t.clamp(0.0, 1.0))!;
  }

  /// Returns a contrasting text color (black or white) for a given background color.
  ///
  /// Uses the luminance formula to determine readability.
  ///
  /// Example:
  /// ```dart
  /// ColorUtils.contrastTextColor(Colors.white); // Colors.black
  /// ColorUtils.contrastTextColor(Colors.black); // Colors.white
  /// ```
  static Color contrastTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Converts a hex string to a Color.
  ///
  /// Supports formats:
  /// - "#RRGGBB" or "#AARRGGBB"
  /// - Without "#" prefix
  ///
  /// Example:
  /// ```dart
  /// ColorUtils.fromHex("#FF5733"); // Color(0xFFFF5733)
  /// ColorUtils.fromHex("33FF57"); // Color(0xFF33FF57)
  /// ```
  static Color? fromHex(String hex) {
    String cleaned = hex.replaceFirst('#', '');

    if (cleaned.length == 6) {
      cleaned = 'FF$cleaned';
    }

    if (cleaned.length != 8) return null;

    final colorValue = int.tryParse(cleaned, radix: 16);
    if (colorValue == null) return null;

    return Color(colorValue);
  }

  /// Converts a Color to a hex string.
  ///
  /// Returns format "#AARRGGBB".
  ///
  /// Example:
  /// ```dart
  /// ColorUtils.toHex(Colors.blue); // "#FF2196F3"
  /// ```
  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  /// Lightens a color by a percentage.
  ///
  /// [amount] should be between 0.0 and 1.0.
  ///
  /// Example:
  /// ```dart
  /// ColorUtils.lighten(Colors.blue, 0.2); // 20% lighter blue
  /// ```
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightened = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return lightened.toColor();
  }

  /// Darkens a color by a percentage.
  ///
  /// [amount] should be between 0.0 and 1.0.
  ///
  /// Example:
  /// ```dart
  /// ColorUtils.darken(Colors.blue, 0.2); // 20% darker blue
  /// ```
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final darkened = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darkened.toColor();
  }
}
