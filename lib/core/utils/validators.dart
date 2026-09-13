/// Form validation utilities for the AI Video Editor app.
class Validators {
  Validators._();

  /// Validates an email address.
  ///
  /// Returns null if valid, or an error message if invalid.
  ///
  /// Example:
  /// ```dart
  /// Validators.validateEmail("user@example.com"); // null
  /// Validators.validateEmail("invalid"); // "Please enter a valid email address"
  /// ```
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates a password.
  ///
  /// Requirements:
  /// - At least 8 characters
  /// - Contains at least one uppercase letter
  /// - Contains at least one lowercase letter
  /// - Contains at least one number
  ///
  /// Returns null if valid, or an error message if invalid.
  ///
  /// Example:
  /// ```dart
  /// Validators.validatePassword("MyPass123"); // null
  /// Validators.validatePassword("weak"); // "Password must be at least 8 characters"
  /// ```
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Validates a URL.
  ///
  /// Returns null if valid, or an error message if invalid.
  ///
  /// Example:
  /// ```dart
  /// Validators.validateUrl("https://example.com"); // null
  /// Validators.validateUrl("not a url"); // "Please enter a valid URL"
  /// ```
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL is required';
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value.trim())) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Validates a project name.
  ///
  /// Requirements:
  /// - Not empty
  /// - Between 3 and 100 characters
  /// - Only alphanumeric characters, spaces, hyphens, and underscores
  ///
  /// Returns null if valid, or an error message if invalid.
  ///
  /// Example:
  /// ```dart
  /// Validators.validateProjectName("My Project"); // null
  /// Validators.validateProjectName("ab"); // "Project name must be at least 3 characters"
  /// ```
  static String? validateProjectName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Project name is required';
    }

    final trimmed = value.trim();

    if (trimmed.length < 3) {
      return 'Project name must be at least 3 characters';
    }

    if (trimmed.length > 100) {
      return 'Project name must be less than 100 characters';
    }

    final nameRegex = RegExp(r'^[a-zA-Z0-9\s\-_]+$');
    if (!nameRegex.hasMatch(trimmed)) {
      return 'Project name can only contain letters, numbers, spaces, hyphens, and underscores';
    }

    return null;
  }

  /// Validates a video URL.
  ///
  /// Accepts URLs ending with common video extensions or from known platforms.
  ///
  /// Returns null if valid, or an error message if invalid.
  ///
  /// Example:
  /// ```dart
  /// Validators.validateVideoUrl("https://example.com/video.mp4"); // null
  /// Validators.validateVideoUrl("not a video"); // "Please enter a valid video URL"
  /// ```
  static String? validateVideoUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Video URL is required';
    }

    final trimmed = value.trim().toLowerCase();

    // Check for common video file extensions
    final videoExtensions = [
      '.mp4', '.avi', '.mov', '.wmv', '.flv', '.mkv',
      '.webm', '.m4v', '.mpg', '.mpeg', '.3gp',
    ];

    final hasVideoExtension = videoExtensions.any(
      (ext) => trimmed.endsWith(ext),
    );

    // Check for known video platform URLs
    final platformPatterns = [
      RegExp(r'youtube\.com/watch'),
      RegExp(r'youtu\.be/'),
      RegExp(r'vimeo\.com/'),
      RegExp(r'dailymotion\.com/video'),
      RegExp(r'wistia\.com/medias/'),
    ];

    final isPlatformUrl = platformPatterns.any(
      (pattern) => pattern.hasMatch(trimmed),
    );

    // Also validate as a general URL
    final urlError = validateUrl(value);
    if (urlError != null) {
      return 'Please enter a valid video URL';
    }

    if (!hasVideoExtension && !isPlatformUrl) {
      return 'Please enter a valid video URL (supports MP4, AVI, MOV, YouTube, Vimeo, etc.)';
    }

    return null;
  }
}
