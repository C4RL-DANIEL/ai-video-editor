/// Extensions on [String] for convenient operations.
extension StringExtensions on String {
  /// Capitalizes the first letter of the string.
  ///
  /// Example:
  /// ```dart
  /// 'hello'.capitalize; // 'Hello'
  /// ''.capitalize; // ''
  /// ```
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalizes the first letter of each word in the string.
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.capitalizeWords; // 'Hello World'
  /// 'my video project'.capitalizeWords; // 'My Video Project'
  /// ```
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Returns true if the string is a valid email address.
  ///
  /// Example:
  /// ```dart
  /// 'user@example.com'.isValidEmail; // true
  /// 'invalid'.isValidEmail; // false
  /// ```
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Returns true if the string is a valid URL.
  ///
  /// Example:
  /// ```dart
  /// 'https://example.com'.isValidUrl; // true
  /// 'not a url'.isValidUrl; // false
  /// ```
  bool get isValidUrl {
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&//=]*)$',
    );
    return urlRegex.hasMatch(this);
  }

  /// Returns true if the string is a valid video URL.
  ///
  /// Checks for common video file extensions or known video platform URLs.
  ///
  /// Example:
  /// ```dart
  /// 'video.mp4'.isValidVideoUrl; // true (if has extension)
  /// 'https://youtube.com/watch?v=123'.isValidVideoUrl; // true
  /// ```
  bool get isValidVideoUrl {
    final lower = toLowerCase();

    // Check for video extensions
    final videoExtensions = [
      '.mp4', '.avi', '.mov', '.wmv', '.flv', '.mkv',
      '.webm', '.m4v', '.mpg', '.mpeg', '.3gp',
    ];
    if (videoExtensions.any((ext) => lower.endsWith(ext))) {
      return true;
    }

    // Check for platform URLs
    final platformPatterns = [
      RegExp(r'youtube\.com/watch'),
      RegExp(r'youtu\.be/'),
      RegExp(r'vimeo\.com/'),
      RegExp(r'dailymotion\.com/video'),
    ];
    if (platformPatterns.any((p) => p.hasMatch(lower))) {
      return true;
    }

    // Fall back to general URL check
    return isValidUrl;
  }

  /// Truncates the string to the specified length, appending '...' if truncated.
  ///
  /// Example:
  /// ```dart
  /// 'Hello World'.truncate(5); // 'Hello...'
  /// 'Hello'.truncate(10); // 'Hello'
  /// ```
  String truncate(int length) {
    if (this.length <= length) return this;
    return '${substring(0, length)}...';
  }

  /// Truncates the string from the middle, preserving start and end.
  ///
  /// Useful for file paths or long URLs.
  ///
  /// Example:
  /// ```dart
  /// 'https://example.com/very/long/path/video.mp4'.truncateMiddle(30);
  /// // 'https://example.com...video.mp4'
  /// ```
  String truncateMiddle(int maxLength) {
    if (this.length <= maxLength) return this;
    final keepLength = (maxLength - 3) ~/ 2;
    final start = substring(0, keepLength);
    final end = substring(length - keepLength);
    return '$start...$end';
  }

  /// Parses the string as a [Duration].
  ///
  /// Supports formats:
  /// - "HH:MM:SS" (e.g., "01:30:00")
  /// - "MM:SS" (e.g., "05:30")
  /// - "Xh Ym Zs" (e.g., "1h 30m 15s")
  ///
  /// Returns [Duration.zero] if parsing fails.
  ///
  /// Example:
  /// ```dart
  /// '01:30:00'.toDuration; // Duration(hours: 1, minutes: 30)
  /// '5m 30s'.toDuration; // Duration(minutes: 5, seconds: 30)
  /// ```
  Duration get toDuration {
    final trimmed = trim();
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

    // Try human-readable format
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

    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  /// Returns true if the string is a numeric value (integer or decimal).
  ///
  /// Example:
  /// ```dart
  /// '123'.isNumeric; // true
  /// '3.14'.isNumeric; // true
  /// 'abc'.isNumeric; // false
  /// ```
  bool get isNumeric => double.tryParse(this) != null;

  /// Returns true if the string is a valid hex color.
  ///
  /// Example:
  /// ```dart
  /// '#FF5733'.isValidHexColor; // true
  /// 'FF5733'.isValidHexColor; // true
  /// 'not a color'.isValidHexColor; // false
  /// ```
  bool get isValidHexColor {
    final cleaned = replaceFirst('#', '');
    if (cleaned.length != 6 && cleaned.length != 8) return false;
    return RegExp(r'^[0-9A-Fa-f]+$').hasMatch(cleaned);
  }

  /// Removes all whitespace from the string.
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.removeAllWhitespace; // 'helloworld'
  /// ```
  String get removeAllWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Returns the file extension from the string (assumes it's a file path/name).
  ///
  /// Example:
  /// ```dart
  /// 'video.mp4'.fileExtension; // 'mp4'
  /// 'archive.tar.gz'.fileExtension; // 'gz'
  /// ```
  String get fileExtension {
    final lastDot = lastIndexOf('.');
    if (lastDot == -1) return '';
    return substring(lastDot + 1).toLowerCase();
  }

  /// Removes the file extension from the string.
  ///
  /// Example:
  /// ```dart
  /// 'video.mp4'.removeFileExtension; // 'video'
  /// ```
  String get removeFileExtension {
    final lastDot = lastIndexOf('.');
    if (lastDot == -1) return this;
    return substring(0, lastDot);
  }
}
