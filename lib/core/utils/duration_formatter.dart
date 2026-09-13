/// Utility class for formatting durations, file sizes, and timestamps.
class DurationFormatter {
  DurationFormatter._();

  /// Formats a [Duration] into a time string.
  ///
  /// Returns "HH:MM:SS" if the duration is one hour or more,
  /// otherwise returns "MM:SS".
  ///
  /// Example:
  /// ```dart
  /// DurationFormatter.formatDuration(Duration(minutes: 5, seconds: 30)); // "05:30"
  /// DurationFormatter.formatDuration(Duration(hours: 1, minutes: 15, seconds: 45)); // "01:15:45"
  /// ```
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Formats a [Duration] into a short human-readable string.
  ///
  /// Returns "Xh Ym" for hours, "Xm Ys" for minutes, or "Xs" for seconds.
  ///
  /// Example:
  /// ```dart
  /// DurationFormatter.formatDurationShort(Duration(seconds: 45)); // "45s"
  /// DurationFormatter.formatDurationShort(Duration(minutes: 1, seconds: 23)); // "1m 23s"
  /// DurationFormatter.formatDurationShort(Duration(hours: 2, minutes: 15)); // "2h 15m"
  /// ```
  static String formatDurationShort(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      }
      return '${hours}h';
    }
    if (minutes > 0) {
      if (seconds > 0) {
        return '${minutes}m ${seconds}s';
      }
      return '${minutes}m';
    }
    return '${seconds}s';
  }

  /// Formats a file size in bytes to a human-readable string.
  ///
  /// Uses binary units (KB, MB, GB, TB).
  ///
  /// Example:
  /// ```dart
  /// DurationFormatter.formatFileSize(1234567); // "1.2 MB"
  /// DurationFormatter.formatFileSize(1073741824); // "1.0 GB"
  /// ```
  static String formatFileSize(int bytes) {
    if (bytes < 0) return '0 B';

    const units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
    int unitIndex = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    if (unitIndex == 0) {
      return '${bytes} B';
    }

    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  /// Formats a timestamp in seconds to "HH:MM:SS" format.
  ///
  /// Example:
  /// ```dart
  /// DurationFormatter.formatTimestamp(85.5); // "01:25"
  /// DurationFormatter.formatTimestamp(3661.0); // "01:01:01"
  /// ```
  static String formatTimestamp(double seconds) {
    final totalSeconds = seconds.floor();
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final secs = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  /// Parses a duration string into a [Duration].
  ///
  /// Supports formats:
  /// - "HH:MM:SS" (e.g., "01:30:00")
  /// - "MM:SS" (e.g., "05:30")
  /// - "Xh Ym Zs" (e.g., "1h 30m 15s")
  /// - "Xm Ys" (e.g., "5m 30s")
  /// - "Xs" (e.g., "30s")
  ///
  /// Returns [Duration.zero] if the string cannot be parsed.
  ///
  /// Example:
  /// ```dart
  /// DurationFormatter.parseDuration("01:30:00"); // Duration(hours: 1, minutes: 30)
  /// DurationFormatter.parseDuration("5m 30s"); // Duration(minutes: 5, seconds: 30)
  /// ```
  static Duration parseDuration(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return Duration.zero;

    // Try HH:MM:SS or MM:SS format
    final colonParts = trimmed.split(':');
    if (colonParts.length == 3) {
      final hours = int.tryParse(colonParts[0]) ?? 0;
      final minutes = int.tryParse(colonParts[1]) ?? 0;
      final seconds = int.tryParse(colonParts[2]) ?? 0;
      return Duration(hours: hours, minutes: minutes, seconds: seconds);
    }
    if (colonParts.length == 2) {
      final minutes = int.tryParse(colonParts[0]) ?? 0;
      final seconds = int.tryParse(colonParts[1]) ?? 0;
      return Duration(minutes: minutes, seconds: seconds);
    }

    // Try human-readable format like "1h 30m 15s"
    int hours = 0;
    int minutes = 0;
    int seconds = 0;

    final regex = RegExp(r'(\d+)\s*(h|m|s)');
    final matches = regex.allMatches(trimmed.toLowerCase());

    for (final match in matches) {
      final value = int.tryParse(match.group(1) ?? '0') ?? 0;
      final unit = match.group(2);
      switch (unit) {
        case 'h':
          hours = value;
          break;
        case 'm':
          minutes = value;
          break;
        case 's':
          seconds = value;
          break;
      }
    }

    if (hours == 0 && minutes == 0 && seconds == 0) {
      // Try parsing as plain seconds
      final plainSeconds = int.tryParse(trimmed);
      if (plainSeconds != null) {
        return Duration(seconds: plainSeconds);
      }
    }

    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }
}
