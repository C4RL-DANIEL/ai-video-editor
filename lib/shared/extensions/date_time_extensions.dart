/// Extensions on [DateTime] for convenient operations.
extension DateTimeExtensions on DateTime {
  /// Returns a human-readable "time ago" string.
  ///
  /// Example:
  /// ```dart
  /// DateTime.now().subtract(Duration(hours: 2)).timeAgo; // "2 hours ago"
  /// DateTime.now().subtract(Duration(days: 3)).timeAgo; // "3 days ago"
  /// ```
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = difference.inDays ~/ 7;
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = difference.inDays ~/ 30;
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = difference.inDays ~/ 365;
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Returns a detailed time ago string that includes precise timestamps for recent items.
  ///
  /// Within the last minute returns "just now", within the last hour shows minutes,
  /// otherwise delegates to [timeAgo].
  ///
  /// Example:
  /// ```dart
  /// DateTime.now().subtract(Duration(seconds: 30)).timeAgoPrecise; // "30 seconds ago"
  /// ```
  String get timeAgoPrecise {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      final seconds = difference.inSeconds;
      return '$seconds ${seconds == 1 ? 'second' : 'seconds'} ago';
    }
    return timeAgo;
  }

  /// Formats the date and time in a full, readable format.
  ///
  /// Example:
  /// ```dart
  /// DateTime(2024, 1, 15, 14, 30).formatFull; // "January 15, 2024 at 2:30 PM"
  /// ```
  String get formatFull {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];

    final month = months[month - 1];
    final day = this.day;
    final year = this.year;
    final hour = this.hour > 12 ? this.hour - 12 : (this.hour == 0 ? 12 : this.hour);
    final minute = this.minute.toString().padLeft(2, '0');
    final period = this.hour >= 12 ? 'PM' : 'AM';

    return '$month $day, $year at $hour:$minute $period';
  }

  /// Returns true if the date is today.
  ///
  /// Example:
  /// ```dart
  /// DateTime.now().isToday; // true
  /// ```
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns true if the date was yesterday.
  ///
  /// Example:
  /// ```dart
  /// DateTime.now().subtract(Duration(days: 1)).isYesterday; // true
  /// ```
  bool get isYesterday {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Returns true if the date is tomorrow.
  bool get isTomorrow {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  /// Returns true if the date is within the current week.
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Returns true if the date is within the current month.
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Returns true if the date is within the current year.
  bool get isThisYear {
    final now = DateTime.now();
    return year == now.year;
  }

  /// Formats the date in a short format.
  ///
  /// Example:
  /// ```dart
  /// DateTime(2024, 1, 15).formatShort; // "Jan 15, 2024"
  /// ```
  String get formatShort {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[month - 1]} $day, $year';
  }

  /// Formats only the time portion.
  ///
  /// Example:
  /// ```dart
  /// DateTime(2024, 1, 15, 14, 30).formatTime; // "2:30 PM"
  /// ```
  String get formatTime {
    final hour = this.hour > 12 ? this.hour - 12 : (this.hour == 0 ? 12 : this.hour);
    final minute = this.minute.toString().padLeft(2, '0');
    final period = this.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Returns a smart date string.
  ///
  /// - Today: "Today at 2:30 PM"
  /// - Yesterday: "Yesterday at 2:30 PM"
  /// - This year: "Jan 15 at 2:30 PM"
  /// - Otherwise: "Jan 15, 2024 at 2:30 PM"
  String get smartDate {
    if (isToday) return 'Today at $formatTime';
    if (isYesterday) return 'Yesterday at $formatTime';

    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    if (isThisYear) {
      return '${months[month - 1]} $day at $formatTime';
    }

    return '${months[month - 1]} $day, $year at $formatTime';
  }

  /// Returns the start of the day (00:00:00).
  DateTime get startOfDay => DateTime(year, month, day);

  /// Returns the end of the day (23:59:59.999).
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Returns true if the date is before the other date.
  bool isBeforeDate(DateTime other) {
    return isBefore(DateTime(other.year, other.month, other.day));
  }

  /// Returns true if the date is after the other date.
  bool isAfterDate(DateTime other) {
    return isAfter(DateTime(other.year, other.month, other.day));
  }

  /// Returns true if the date is between two dates (inclusive).
  bool isBetween(DateTime start, DateTime end) {
    return !isBeforeDate(start) && !isAfterDate(end);
  }

  /// Returns the number of days until this date.
  ///
  /// Positive if in the future, negative if in the past.
  int get daysUntil {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(year, month, day);
    return target.difference(today).inDays;
  }

  /// Formats as ISO 8601 string without milliseconds.
  ///
  /// Example:
  /// ```dart
  /// DateTime(2024, 1, 15, 14, 30).toIsoStringCompact; // "2024-01-15T14:30:00"
  /// ```
  String get toIsoStringCompact {
    return '${year.toString().padLeft(4, '0')}-'
        '${month.toString().padLeft(2, '0')}-'
        '${day.toString().padLeft(2, '0')}T'
        '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}:'
        '${second.toString().padLeft(2, '0')}';
  }
}
