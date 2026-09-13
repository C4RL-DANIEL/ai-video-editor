import 'package:appwrite/appwrite.dart';

/// Appwrite client configuration.
///
/// Free tier: 75K monthly active users, 10GB storage, 50GB bandwidth.
/// Self-hostable at https://appwrite.io
abstract final class AppwriteConfig {
  /// Your Appwrite project endpoint.
  /// For Appwrite Cloud: 'https://cloud.appwrite.io/v1'
  /// For self-hosted: 'http://YOUR_SERVER:80/v1'
  static const String endpoint = String.fromEnvironment(
    'APPWRITE_ENDPOINT',
    defaultValue: 'https://cloud.appwrite.io/v1',
  );

  /// Your Appwrite project ID from the console.
  static const String projectId = String.fromEnvironment(
    'APPWRITE_PROJECT_ID',
    defaultValue: '',
  );

  /// Database ID for the app's main database.
  static const String databaseId = String.fromEnvironment(
    'APPWRITE_DATABASE_ID',
    defaultValue: 'ai_video_editor',
  );

  /// Storage bucket IDs
  static const String videosBucketId = 'videos';
  static const String thumbnailsBucketId = 'thumbnails';
  static const String exportsBucketId = 'exports';

  /// Collection IDs
  static const String projectsCollectionId = 'projects';
  static const String shortsCollectionId = 'shorts';
  static const String longFormsCollectionId = 'long_forms';
  static const String analysisCollectionId = 'analysis';
  static const String momentsCollectionId = 'moments';
  static const String transcriptsCollectionId = 'transcripts';
  static const String editDecisionsCollectionId = 'edit_decisions';
}

/// Creates a configured Appwrite [Client] instance.
Client createAppwriteClient() {
  return Client()
    ..setEndpoint(AppwriteConfig.endpoint)
    ..setProject(AppwriteConfig.projectId)
    ..setSelfSigned(status: true); // Only for self-hosted; remove for cloud
}
