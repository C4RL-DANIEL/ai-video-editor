/// API endpoint definitions, base URLs, and request configuration
/// for the AI Video Editor backend services.
abstract final class ApiConstants {
  ApiConstants._(); // prevent instantiation

  // ---------------------------------------------------------------------------
  // Base URLs
  // ---------------------------------------------------------------------------

  /// Production API base URL.
  static const String baseUrlProd = 'https://api.aivideoeditor.com/v1';

  /// Staging API base URL.
  static const String baseUrlStaging = 'https://staging-api.aivideoeditor.com/v1';

  /// Local development URL.
  static const String baseUrlDev = 'http://localhost:3000/v1';

  /// WebSocket base URL (production).
  static const String wsBaseUrlProd = 'wss://api.aivideoeditor.com/v1/ws';

  /// WebSocket base URL (staging).
  static const String wsBaseUrlStaging = 'wss://staging-api.aivideoeditor.com/v1/ws';

  /// CDN base URL for static assets & exported files.
  static const String cdnBaseUrl = 'https://cdn.aivideoeditor.com';

  // ---------------------------------------------------------------------------
  // HTTP Configuration
  // ---------------------------------------------------------------------------
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 30000;
  static const int sendTimeoutMs = 60000; // longer for large uploads

  static const String contentTypeJson = 'application/json';
  static const String contentTypeMultipart = 'multipart/form-data';
  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';

  // ---------------------------------------------------------------------------
  // Authentication
  // ---------------------------------------------------------------------------
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authResetPassword = '/auth/reset-password';
  static const String authVerifyEmail = '/auth/verify-email';
  static const String authGoogle = '/auth/google';
  static const String authApple = '/auth/apple';

  // ---------------------------------------------------------------------------
  // User / Profile
  // ---------------------------------------------------------------------------
  static const String userMe = '/users/me';
  static const String userProfile = '/users/me/profile';
  static const String userAvatar = '/users/me/avatar';
  static const String userPreferences = '/users/me/preferences';
  static const String userSubscription = '/users/me/subscription';
  static const String userUsage = '/users/me/usage';

  // ---------------------------------------------------------------------------
  // Projects
  // ---------------------------------------------------------------------------
  static const String projects = '/projects';
  static String projectById(String id) => '/projects/$id';
  static String projectDuplicate(String id) => '/projects/$id/duplicate';
  static String projectExport(String id) => '/projects/$id/export';
  static String projectShare(String id) => '/projects/$id/share';
  static String projectCollaborators(String id) =>
      '/projects/$id/collaborators';
  static String projectTimeline(String id) => '/projects/$id/timeline';
  static String projectThumbnails(String id) => '/projects/$id/thumbnails';

  // ---------------------------------------------------------------------------
  // Media / Upload
  // ---------------------------------------------------------------------------
  static const String mediaUpload = '/media/upload';
  static const String mediaUploadInit = '/media/upload/init';
  static const String mediaUploadComplete = '/media/upload/complete';
  static String mediaById(String id) => '/media/$id';
  static String mediaThumbnail(String id) => '/media/$id/thumbnail';
  static String mediaTranscode(String id) => '/media/$id/transcode';
  static const String mediaBatch = '/media/batch';
  static const String mediaSearch = '/media/search';

  // ---------------------------------------------------------------------------
  // AI Processing Pipeline
  // ---------------------------------------------------------------------------
  static const String aiAnalyze = '/ai/analyze';
  static String aiJobStatus(String jobId) => '/ai/jobs/$jobId';
  static String aiJobCancel(String jobId) => '/ai/jobs/$jobId/cancel';
  static const String aiJobsBulk = '/ai/jobs/bulk';

  /// AI-powered auto-edit generation.
  static const String aiAutoEdit = '/ai/auto-edit';

  /// Smart cut suggestions.
  static const String aiSmartCuts = '/ai/smart-cuts';

  /// B-roll suggestion engine.
  static const String aiBroll = '/ai/broll';

  /// Auto color grading.
  static const String aiColorGrade = '/ai/color-grade';

  /// Caption / subtitle generation.
  static const String aiCaptions = '/ai/captions';

  /// Audio noise removal & enhancement.
  static const String aiAudioEnhance = '/ai/audio-enhance';

  /// Scene detection & segmentation.
  static const String aiSceneDetection = '/ai/scene-detection';

  /// Moment / highlight detection for short-form content.
  static const String aiMomentDetection = '/ai/moment-detection';

  /// Content analysis (sentiment, objects, topics).
  static const String aiContentAnalysis = '/ai/content-analysis';

  /// Speech-to-text transcription.
  static const String aiTranscription = '/ai/transcription';

  /// Text-to-speech for voiceover generation.
  static const String aiTextToSpeech = '/ai/text-to-speech';

  /// Style transfer (apply visual styles to video).
  static const String aiStyleTransfer = '/ai/style-transfer';

  /// AI-generated background music.
  static const String aiMusicGeneration = '/ai/music';

  // ---------------------------------------------------------------------------
  // Export / Rendering
  // ---------------------------------------------------------------------------
  static const String exportStart = '/export/start';
  static String exportStatus(String exportId) => '/export/$exportId/status';
  static String exportDownload(String exportId) => '/export/$exportId/download';
  static String exportCancel(String exportId) => '/export/$exportId/cancel';
  static const String exportPresets = '/export/presets';
  static String exportPresetById(String id) => '/export/presets/$id';

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------
  static const String templates = '/templates';
  static String templateById(String id) => '/templates/$id';
  static const String templateCategories = '/templates/categories';
  static String templateByCategory(String category) =>
      '/templates?category=$category';

  // ---------------------------------------------------------------------------
  // Stock Media
  // ---------------------------------------------------------------------------
  static const String stockVideos = '/stock/videos';
  static const String stockAudio = '/stock/audio';
  static const String stockImages = '/stock/images';
  static String stockSearch(String type) => '/stock/$type/search';

  // ---------------------------------------------------------------------------
  // Collaboration
  // ---------------------------------------------------------------------------
  static String collabInvite(String projectId) =>
      '/collaboration/$projectId/invite';
  static String collabAccept(String token) =>
      '/collaboration/accept/$token';
  static String collabMembers(String projectId) =>
      '/collaboration/$projectId/members';
  static String collabComments(String projectId) =>
      '/collaboration/$projectId/comments';
  static String collabActivity(String projectId) =>
      '/collaboration/$projectId/activity';

  // ---------------------------------------------------------------------------
  // Notifications
  // ---------------------------------------------------------------------------
  static const String notifications = '/notifications';
  static const String notificationsRead = '/notifications/read';
  static const String notificationsReadAll = '/notifications/read-all';
  static const String notificationsPreferences = '/notifications/preferences';

  // ---------------------------------------------------------------------------
  // Analytics & Telemetry
  // ---------------------------------------------------------------------------
  static const String analyticsEvents = '/analytics/events';
  static const String analyticsSession = '/analytics/session';

  // ---------------------------------------------------------------------------
  // WebSocket Events
  // ---------------------------------------------------------------------------
  static const String wsProjectUpdate = 'project:update';
  static const String wsExportProgress = 'export:progress';
  static const String wsAiJobUpdate = 'ai:job:update';
  static const String wsCollabCursor = 'collab:cursor';
  static const String wsCollabEdit = 'collab:edit';
  static const String wsNotification = 'notification';

  // ---------------------------------------------------------------------------
  // Query Parameter Keys
  // ---------------------------------------------------------------------------
  static const String queryPage = 'page';
  static const String queryLimit = 'limit';
  static const String querySort = 'sort';
  static const String queryOrder = 'order';
  static const String querySearch = 'search';
  static const String queryFilter = 'filter';
  static const String queryFormat = 'format';
  static const String queryQuality = 'quality';
  static const String queryInclude = 'include';
}
