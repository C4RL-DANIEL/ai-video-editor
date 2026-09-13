/// General-purpose application constants for the AI Video Editor.
abstract final class AppConstants {
  AppConstants._(); // prevent instantiation

  // ---------------------------------------------------------------------------
  // App Identity
  // ---------------------------------------------------------------------------
  static const String appName = 'AI Video Editor';
  static const String appTagline = 'Create. Edit. Share.';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;
  static const String bundleId = 'com.aivideoeditor.app';

  // ---------------------------------------------------------------------------
  // Storage Keys
  // ---------------------------------------------------------------------------
  static const String keyThemeMode = 'theme_mode';
  static const String keyLocale = 'locale';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyAuthTokens = 'auth_tokens';
  static const String keyUserPreferences = 'user_preferences';
  static const String keyRecentProjects = 'recent_projects';
  static const String keyCacheQuota = 'cache_quota_bytes';
  static const String keyFirstLaunchDate = 'first_launch_date';

  // ---------------------------------------------------------------------------
  // Limits & Thresholds
  // ---------------------------------------------------------------------------

  /// Maximum number of video clips per project.
  static const int maxClipsPerProject = 500;

  /// Maximum duration of a single clip (seconds).
  static const int maxClipDurationSeconds = 60 * 60; // 1 hour

  /// Maximum total project duration (seconds).
  static const int maxProjectDurationSeconds = 6 * 60 * 60; // 6 hours

  /// Maximum number of audio tracks per project.
  static const int maxAudioTracks = 20;

  /// Maximum number of text/caption layers.
  static const int maxTextLayers = 50;

  /// Maximum project file upload size (bytes): 10 GB.
  static const int maxUploadSizeBytes = 10 * 1024 * 1024 * 1024;

  /// Maximum thumbnail cache size (bytes): 500 MB.
  static const int maxThumbnailCacheBytes = 500 * 1024 * 1024;

  /// Maximum number of recent projects shown in the dashboard.
  static const int maxRecentProjects = 20;

  /// Auto-save interval (seconds).
  static const int autoSaveIntervalSeconds = 30;

  /// Debounce delay for search inputs (milliseconds).
  static const int searchDebounceMs = 300;

  /// Maximum retry count for failed network requests.
  static const int maxRetries = 3;

  /// Delay between retry attempts (milliseconds).
  static const int retryDelayMs = 1000;

  // ---------------------------------------------------------------------------
  // Video Defaults
  // ---------------------------------------------------------------------------
  static const int defaultVideoWidth = 1920;
  static const int defaultVideoHeight = 1080;
  static const double defaultFrameRate = 30.0;
  static const int defaultBitrate = 8000000; // 8 Mbps
  static const String defaultAudioCodec = 'aac';
  static const int defaultAudioBitrate = 192000; // 192 kbps
  static const int defaultAudioSampleRate = 48000;

  // ---------------------------------------------------------------------------
  // Animation Durations (milliseconds)
  // ---------------------------------------------------------------------------
  static const int durationFast = 150;
  static const int durationNormal = 300;
  static const int durationSlow = 500;
  static const int durationVerySlow = 800;

  // ---------------------------------------------------------------------------
  // Platform Channels
  // ---------------------------------------------------------------------------
  static const String channelVideoProcessor = 'com.aivideoeditor/video_processor';
  static const String channelExportService = 'com.aivideoeditor/export_service';
  static const String channelAnalytics = 'com.aivideoeditor/analytics';

  // ---------------------------------------------------------------------------
  // Feature Flags
  // ---------------------------------------------------------------------------
  static const String featureFlagAiCaptioning = 'ai_captioning';
  static const String featureFlagSmartCuts = 'smart_cuts';
  static const String featureFlagAutoColorGrade = 'auto_color_grade';
  static const String featureFlagBrollSuggestions = 'broll_suggestions';
  static const String featureFlagVoiceCloning = 'voice_cloning';
  static const String featureFlagCollaborativeEditing = 'collab_editing';

  // ---------------------------------------------------------------------------
  // Deep Links
  // ---------------------------------------------------------------------------
  static const String deepLinkScheme = 'aivideoeditor';
  static const String deepLinkHost = 'app';
  static const String deepLinkNewProject = '$deepLinkScheme://$deepLinkHost/new-project';
  static const String deepLinkImport = '$deepLinkScheme://$deepLinkHost/import';
}
