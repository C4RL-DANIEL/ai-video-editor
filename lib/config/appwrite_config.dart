import 'package:appwrite/appwrite.dart';

/// Appwrite client configuration.
///
/// Free tier: 75K monthly active users, 10GB storage, 50GB bandwidth.
/// Self-hostable at https://appwrite.io
abstract final class AppwriteConfig {
  /// Your Appwrite project endpoint.
  /// For Appwrite Cloud: 'https://cloud.appwrite.io/v1'
  /// For self-hosted: 'http://YOUR_SERVER:80/v1'
  static const String endpoint = 'https://sgp.cloud.appwrite.io/v1';
  static const String projectId = '6aa6c23100337d473370';
  static const String databaseId = '6aa6c27e000c9c9ccc71';

  /// Storage bucket IDs (free tier: 1 bucket, so all use 'videos')
  static const String videosBucketId = 'videos';
  static const String thumbnailsBucketId = 'videos';
  static const String exportsBucketId = 'videos';

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
    ..setProject(AppwriteConfig.projectId);
}
