/// Extensions on [double] for convenient operations.
extension DoubleExtensions on double {
  /// Converts the value to a percentage string.
  ///
  /// Example:
  /// ```dart
  /// 0.75.toPercentage; // "75.0%"
  /// (75.0).toPercentage; // "75.0%"
  /// ```
  String get toPercentage => '${(this * 100).toStringAsFixed(1)}%';

  /// Converts the value to a percentage string without decimal places.
  ///
  /// Example:
  /// ```dart
  /// 0.75.toPercentageCompact; // "75%"
  /// ```
  String get toPercentageCompact => '${(this * 100).round()}%';

  /// Formats the double to a string with fixed number of decimal places.
  ///
  /// Example:
  /// ```dart
  /// 3.14159.toFixed(2); // "3.14"
  /// 5.0.toFixed(0); // "5"
  /// ```
  String toFixed(int decimals) => toStringAsFixed(decimals);

  /// Converts bytes to a human-readable file size string.
  ///
  /// Uses binary units (KB, MB, GB, TB).
  ///
  /// Example:
  /// ```dart
  /// (1024 * 1024).toDouble().toFileSize; // "1.0 MB"
  /// 1073741824.0.toFileSize; // "1.0 GB"
  /// ```
  String get toFileSize {
    if (this <= 0) return '0 B';

    const units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
    int unitIndex = 0;
    double size = this;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    if (unitIndex == 0) {
      return '${toInt()} B';
    }

    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  /// Converts the value to a compact string representation.
  ///
  /// Example:
  /// ```dart
  /// 1500.0.toCompact; // "1.5K"
  /// 1500000.0.toCompact; // "1.5M"
  /// 1500000000.0.toCompact; // "1.5B"
  /// ```
  String get toCompact {
    if (this.abs() >= 1000000000) {
      return '${(this / 1000000000).toStringAsFixed(1)}B';
    } else if (this.abs() >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this.abs() >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toStringAsFixed(1);
  }

  /// Clamps the value between min and max.
  ///
  /// Example:
  /// ```dart
  /// 150.0.clampValue(0, 100); // 100.0
  /// 50.0.clampValue(0, 100); // 50.0
  /// ```
  double clampValue(double min, double max) => clamp(min, max);

  /// Returns true if the value is approximately equal to another value.
  ///
  /// Uses an epsilon comparison for floating-point precision.
  ///
  /// Example:
  /// ```dart
  /// 0.1.isApproximately(0.1000000001); // true
  /// 1.0.isApproximately(2.0); // false
  /// ```
  bool isApproximately(double other, [double epsilon = 0.0001]) {
    return (this - other).abs() < epsilon;
  }

  /// Converts degrees to radians.
  ///
  /// Example:
  /// ```dart
  /// 180.0.toRadians; // π
  /// ```
  double get toRadians => this * (3.141592653589793 / 180);

  /// Converts radians to degrees.
  ///
  /// Example:
  /// ```dart
  /// 3.141592653589793.toDegrees; // 180.0
  /// ```
  double get toDegrees => this * (180 / 3.141592653589793);

  /// Formats as a time duration in seconds.
  ///
  /// Example:
  /// ```dart
  /// 85.0.toDurationString; // "01:25"
  /// 3661.0.toDurationString; // "01:01:01"
  /// ```
  String get toDurationString {
    final totalSeconds = floor();
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Returns the value as a string with at most [maxDecimals] decimal places,
  /// removing trailing zeros.
  ///
  /// Example:
  /// ```dart
  /// 3.1400.toTrimmedFixed(2); // "3.14"
  /// 5.0000.toTrimmedFixed(2); // "5"
  /// ```
  String toTrimmedFixed(int maxDecimals) {
    final result = toStringAsFixed(maxDecimals);
    return result.contains('.') ? result.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '') : result;
  }
}

/// Extensions on [int] for convenient operations.
extension IntExtensions on int {
  /// Converts bytes to a human-readable file size string.
  ///
  /// Example:
  /// ```dart
  /// (1024 * 1024).toFileSize; // "1.0 MB"
  /// ```
  String get toFileSize {
    return toDouble().toFileSize;
  }

  /// Converts to a compact string representation.
  ///
  /// Example:
  /// ```dart
  /// 1500.toCompact; // "1.5K"
  /// 1500000.toCompact; // "1.5M"
  /// ```
  String get toCompact => toDouble().toCompact;

  /// Formats as a two-digit string with leading zero if needed.
  ///
  /// Example:
  /// ```dart
  /// 5.toTwoDigits; // "05"
  /// 12.toTwoDigits; // "12"
  /// ```
  String get toTwoDigits => toString().padLeft(2, '0');

  /// Formats as a three-digit string with leading zeros if needed.
  ///
  /// Example:
  /// ```dart
  /// 5.toThreeDigits; // "005"
  /// 123.toThreeDigits; // "123"
  /// ```
  String get toThreeDigits => toString().padLeft(3, '0');
}
