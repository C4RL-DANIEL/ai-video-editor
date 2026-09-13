import 'package:appwrite/appwrite.dart';

import '../../config/appwrite_config.dart';

/// Auto-initializes all Appwrite collections, attributes, and storage buckets.
///
/// Call [AppwriteInitializer.initialize] once at app startup. It is safe to
/// call multiple times — every step is wrapped in try/catch so that already-
/// existing resources are silently skipped.
class AppwriteInitializer {
  AppwriteInitializer._();

  /// One-shot bootstrap: creates the database, all collections with their
  /// attributes, and the three storage buckets.
  static Future<void> initialize(Client client) async {
    final databases = Databases(client);
    final storage = Storage(client);

    // ── Database ────────────────────────────────────────────────────────
    await _safe(() => databases.create(
          databaseId: AppwriteConfig.databaseId,
          name: 'AI Video Editor',
        ));

    // ── Collections ─────────────────────────────────────────────────────
    await _createProjectsCollection(databases);
    await _createShortsCollection(databases);
    await _createLongFormsCollection(databases);
    await _createAnalysisCollection(databases);
    await _createMomentsCollection(databases);
    await _createTranscriptsCollection(databases);

    // ── Storage buckets ─────────────────────────────────────────────────
    await _createVideosBucket(storage);
    await _createThumbnailsBucket(storage);
    await _createExportsBucket(storage);
  }

  // ═════════════════════════════════════════════════════════════════════
  //  Collections
  // ═════════════════════════════════════════════════════════════════════

  /// projects – 10 fields
  static Future<void> _createProjectsCollection(Databases databases) async {
    await _safe(() => databases.createCollection(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.projectsCollectionId,
          name: 'Projects',
          permissions: [
            Permission.read(Role.users()),
            Permission.create(Role.users()),
            Permission.update(Role.users()),
            Permission.delete(Role.users()),
          ],
        ));

    final db = AppwriteConfig.databaseId;
    final col = AppwriteConfig.projectsCollectionId;

    // 1. name (String)
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'name', size: 255, required: true,
        ));
    // 2. description (String)
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'description', size: 2000, required: false,
        ));
    // 3. status (String) – enum stored as string
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'status', size: 50, required: true, default_: 'draft',
        ));
    // 4. thumbnail_url (String)
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'thumbnail_url', size: 2048, required: false,
        ));
    // 5. user_id (String) – owner
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'user_id', size: 36, required: true,
        ));
    // 6. shorts_count (Integer)
    await _safe(() => databases.createIntegerAttribute(
          databaseId: db, collectionId: col, key: 'shorts_count', required: false, min: 0, max: 9999,
        ));
    // 7. long_form_count (Integer)
    await _safe(() => databases.createIntegerAttribute(
          databaseId: db, collectionId: col, key: 'long_form_count', required: false, min: 0, max: 9999,
        ));
    // 8. metadata (String) – JSON-encoded map
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'metadata', size: 10000, required: false,
        ));
    // 9. created_at (String) – ISO-8601
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'created_at', size: 30, required: true,
        ));
    // 10. updated_at (String) – ISO-8601
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'updated_at', size: 30, required: false,
        ));
  }

  /// shorts – 11 fields
  static Future<void> _createShortsCollection(Databases databases) async {
    await _safe(() => databases.createCollection(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.shortsCollectionId,
          name: 'Shorts',
          permissions: [
            Permission.read(Role.users()),
            Permission.create(Role.users()),
            Permission.update(Role.users()),
            Permission.delete(Role.users()),
          ],
        ));

    final db = AppwriteConfig.databaseId;
    final col = AppwriteConfig.shortsCollectionId;

    // 1. project_id (String)
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'project_id', size: 36, required: true,
        ));
    // 2. moment_id (String)
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'moment_id', size: 36, required: true,
        ));
    // 3. title (String)
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'title', size: 255, required: true,
        ));
    // 4. duration (Float)
    await _safe(() => databases.createFloatAttribute(
          databaseId: db, collectionId: col, key: 'duration', required: true, min: 0, max: 600,
        ));
    // 5. target_duration (Float)
    await _safe(() => databases.createFloatAttribute(
          databaseId: db, collectionId: col, key: 'target_duration', required: false, min: 15, max: 180,
        ));
    // 6. status (String)
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'status', size: 50, required: true, default_: 'pending',
        ));
    // 7. hook_score (Float)
    await _safe(() => databases.createFloatAttribute(
          databaseId: db, collectionId: col, key: 'hook_score', required: false, min: 0, max: 1,
        ));
    // 8. viral_score (Float)
    await _safe(() => databases.createFloatAttribute(
          databaseId: db, collectionId: col, key: 'viral_score', required: false, min: 0, max: 1,
        ));
    // 9. category (String)
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'category', size: 50, required: false,
        ));
    // 10. source_timestamp (Float)
    await _safe(() => databases.createFloatAttribute(
          databaseId: db, collectionId: col, key: 'source_timestamp', required: true, min: 0,
        ));
    // 11. editing_style (String)
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'editing_style', size: 50, required: false,
        ));
  }

  /// long_forms – 7 fields
  static Future<void> _createLongFormsCollection(Databases databases) async {
    await _safe(() => databases.createCollection(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.longFormsCollectionId,
          name: 'Long Forms',
          permissions: [
            Permission.read(Role.users()),
            Permission.create(Role.users()),
            Permission.update(Role.users()),
            Permission.delete(Role.users()),
          ],
        ));

    final db = AppwriteConfig.databaseId;
    final col = AppwriteConfig.longFormsCollectionId;

    // 1. project_id (String)
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'project_id', size: 36, required: true,
        ));
    // 2. title (String)
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'title', size: 255, required: true,
        ));
    // 3. description (String)
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'description', size: 2000, required: false,
        ));
    // 4. status (String)
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'status', size: 50, required: true, default_: 'draft',
        ));
    // 5. total_duration (Float)
    await _safe(() => databases.createFloatAttribute(
          databaseId: db, collectionId: col, key: 'total_duration', required: false, min: 0,
        ));
    // 6. video_url (String)
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'video_url', size: 2048, required: false,
        ));
    // 7. metadata (String)
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'metadata', size: 10000, required: false,
        ));
  }

  /// analysis – 7 fields
  static Future<void> _createAnalysisCollection(Databases databases) async {
    await _safe(() => databases.createCollection(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.analysisCollectionId,
          name: 'Analysis',
          permissions: [
            Permission.read(Role.users()),
            Permission.create(Role.users()),
            Permission.update(Role.users()),
            Permission.delete(Role.users()),
          ],
        ));

    final db = AppwriteConfig.databaseId;
    final col = AppwriteConfig.analysisCollectionId;

    // 1. project_id (String)
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'project_id', size: 36, required: true,
        ));
    // 2. status (String) – pending | processing | completed | failed
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'status', size: 50, required: true, default_: 'pending',
        ));
    // 3. transcript (String) – full JSON transcript
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'transcript', size: 50000, required: false,
        ));
    // 4. content_map (String) – JSON content map
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'content_map', size: 50000, required: false,
        ));
    // 5. detected_language (String)
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'detected_language', size: 10, required: false,
        ));
    // 6. created_at (String)
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'created_at', size: 30, required: true,
        ));
    // 7. completed_at (String)
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'completed_at', size: 30, required: false,
        ));
  }

  /// moments – 8 fields
  static Future<void> _createMomentsCollection(Databases databases) async {
    await _safe(() => databases.createCollection(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.momentsCollectionId,
          name: 'Moments',
          permissions: [
            Permission.read(Role.users()),
            Permission.create(Role.users()),
            Permission.update(Role.users()),
            Permission.delete(Role.users()),
          ],
        ));

    final db = AppwriteConfig.databaseId;
    final col = AppwriteConfig.momentsCollectionId;

    // 1. project_id (String)
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'project_id', size: 36, required: true,
        ));
    // 2. title (String)
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'title', size: 255, required: true,
        ));
    // 3. description (String)
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'description', size: 2000, required: false,
        ));
    // 4. start_time (Float)
    await _safe(() => databases.createFloatAttribute(
          databaseId: db, collectionId: col, key: 'start_time', required: true, min: 0,
        ));
    // 5. end_time (Float)
    await _safe(() => databases.createFloatAttribute(
          databaseId: db, collectionId: col, key: 'end_time', required: true, min: 0,
        ));
    // 6. virality_score (Float)
    await _safe(() => databases.createFloatAttribute(
          databaseId: db, collectionId: col, key: 'virality_score', required: true, min: 0, max: 1,
        ));
    // 7. tags (String) – JSON-encoded list
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'tags', size: 2000, required: false,
        ));
    // 8. reason (String)
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'reason', size: 2000, required: false,
        ));
  }

  /// transcripts – 5 fields
  static Future<void> _createTranscriptsCollection(Databases databases) async {
    await _safe(() => databases.createCollection(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.transcriptsCollectionId,
          name: 'Transcripts',
          permissions: [
            Permission.read(Role.users()),
            Permission.create(Role.users()),
            Permission.update(Role.users()),
            Permission.delete(Role.users()),
          ],
        ));

    final db = AppwriteConfig.databaseId;
    final col = AppwriteConfig.transcriptsCollectionId;

    // 1. project_id (String)
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'project_id', size: 36, required: true,
        ));
    // 2. text (String) – segment text
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'text', size: 10000, required: true,
        ));
    // 3. start_time (Float)
    await _safe(() => databases.createFloatAttribute(
          databaseId: db, collectionId: col, key: 'start_time', required: true, min: 0,
        ));
    // 4. end_time (Float)
    await _safe(() => databases.createFloatAttribute(
          databaseId: db, collectionId: col, key: 'end_time', required: true, min: 0,
        ));
    // 5. speaker (String)
    await _safe(() => databases.createStringAttribute(
          databaseId: db, collectionId: col, key: 'speaker', size: 100, required: false,
        ));
  }

  // ═════════════════════════════════════════════════════════════════════
  //  Storage buckets
  // ═════════════════════════════════════════════════════════════════════

  /// videos – 2 GB
  static Future<void> _createVideosBucket(Storage storage) async {
    await _safe(() => storage.createBucket(
          bucketId: AppwriteConfig.videosBucketId,
          name: 'Videos',
          permissions: [
            Permission.read(Role.users()),
            Permission.create(Role.users()),
            Permission.update(Role.users()),
            Permission.delete(Role.users()),
          ],
          fileSecurity: true,
          maximumFileSize: 2 * 1024 * 1024, // 2 GB — Appwrite SDK expects bytes
          allowedFileExtensions: ['mp4', 'mov', 'avi', 'mkv', 'webm'],
          compression: 'gzip',
          encryption: true,
        ));
  }

  /// thumbnails – 5 MB
  static Future<void> _createThumbnailsBucket(Storage storage) async {
    await _safe(() => storage.createBucket(
          bucketId: AppwriteConfig.thumbnailsBucketId,
          name: 'Thumbnails',
          permissions: [
            Permission.read(Role.any()), // Public reads for thumbnails
            Permission.create(Role.users()),
            Permission.update(Role.users()),
            Permission.delete(Role.users()),
          ],
          fileSecurity: true,
          maximumFileSize: 5 * 1024 * 1024, // 5 MB
          allowedFileExtensions: ['jpg', 'jpeg', 'png', 'webp'],
          compression: 'gzip',
          encryption: true,
        ));
  }

  /// exports – 2 GB
  static Future<void> _createExportsBucket(Storage storage) async {
    await _safe(() => storage.createBucket(
          bucketId: AppwriteConfig.exportsBucketId,
          name: 'Exports',
          permissions: [
            Permission.read(Role.users()),
            Permission.create(Role.users()),
            Permission.update(Role.users()),
            Permission.delete(Role.users()),
          ],
          fileSecurity: true,
          maximumFileSize: 2 * 1024 * 1024, // 2 GB
          allowedFileExtensions: ['mp4', 'mov', 'avi', 'mkv', 'webm', 'zip'],
          compression: 'gzip',
          encryption: true,
        ));
  }

  // ═════════════════════════════════════════════════════════════════════
  //  Helpers
  // ═════════════════════════════════════════════════════════════════════

  /// Executes [fn] inside a try/catch — if Appwrite returns a 409 (conflict /
  /// already-exists) or any other error, the error is silently ignored so the
  /// bootstrap can continue.
  static Future<void> _safe(Future<void> Function() fn) async {
    try {
      await fn();
    } catch (_) {
      // Collection / attribute / bucket already exists — move on.
    }
  }
}
