import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import '../network/api_response.dart';

/// Metadata about a file stored in Firebase Storage.
class FileMetadata {
  const FileMetadata({
    required this.name,
    required this.fullPath,
    required this.size,
    required this.timeCreated,
    required this.updated,
    this.downloadUrl,
  });

  /// Human-readable file name (e.g. `video_abc.mp4`).
  final String name;

  /// Full storage path (e.g. `projects/proj_123/videos/video_abc.mp4`).
  final String fullPath;

  /// File size in bytes.
  final int size;

  /// When the file was first uploaded.
  final DateTime timeCreated;

  /// When the file was last modified.
  final DateTime updated;

  /// Pre-fetched download URL (populated by [FirebaseStorageService.listFiles]).
  final String? downloadUrl;
}

/// Service for uploading, downloading, and managing files in Firebase Storage.
///
/// Files are organized under `projects/{projectId}/` with sub-directories
/// for `videos/` and `thumbnails/`.
class FirebaseStorageService {
  FirebaseStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  // ---------------------------------------------------------------------------
  // Upload – Video
  // ---------------------------------------------------------------------------

  /// Upload a video [file] for the given [projectId].
  ///
  /// The file is stored at `projects/{projectId}/videos/{filename}`.
  /// An optional [onProgress] callback receives values in the range `0.0 – 1.0`.
  ///
  /// Returns an [ApiResponse] wrapping the public download URL on success.
  Future<ApiResponse<String>> uploadVideo(
    String projectId,
    File file, {
    Function(double)? onProgress,
  }) async {
    try {
      final fileName = _uniqueFileName(file.path);
      final ref = _storage.ref('projects/$projectId/videos/$fileName');

      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: _videoContentType(file.path)),
      );

      // Attach progress listener if requested.
      StreamSubscription<TaskSnapshot>? sub;
      if (onProgress != null) {
        sub = uploadTask.snapshotEvents.listen((event) {
          final progress =
              event.bytesTransferred / (event.totalBytes > 0 ? event.totalBytes : 1);
          onProgress(progress.clamp(0.0, 1.0));
        });
      }

      final snapshot = await uploadTask;
      await sub?.cancel();

      final url = await snapshot.ref.getDownloadURL();
      return ApiResponse.success(url);
    } on FirebaseException catch (e) {
      return ApiResponse.error('Upload failed: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error during upload: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Upload – Thumbnail
  // ---------------------------------------------------------------------------

  /// Upload a thumbnail [file] for the given [projectId].
  ///
  /// The file is stored at `projects/{projectId}/thumbnails/{filename}`.
  Future<ApiResponse<String>> uploadThumbnail(
    String projectId,
    File file,
  ) async {
    try {
      final fileName = _uniqueFileName(file.path);
      final ref = _storage.ref('projects/$projectId/thumbnails/$fileName');

      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(contentType: _imageContentType(file.path)),
      );

      final url = await uploadTask.ref.getDownloadURL();
      return ApiResponse.success(url);
    } on FirebaseException catch (e) {
      return ApiResponse.error('Thumbnail upload failed: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error during thumbnail upload: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Download URL
  // ---------------------------------------------------------------------------

  /// Get the download URL for an existing file at [path].
  Future<ApiResponse<String>> getVideoUrl(String path) async {
    try {
      final ref = _storage.ref(path);
      final url = await ref.getDownloadURL();
      return ApiResponse.success(url);
    } on FirebaseException catch (e) {
      return ApiResponse.error('Failed to get URL: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  /// Delete the file at [path].
  Future<ApiResponse<void>> deleteFile(String path) async {
    try {
      final ref = _storage.ref(path);
      await ref.delete();
      return ApiResponse.success(null);
    } on FirebaseException catch (e) {
      return ApiResponse.error('Delete failed: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error during delete: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // List files
  // ---------------------------------------------------------------------------

  /// List all files under [prefix] (e.g. `projects/proj_123/videos/`).
  ///
  /// Returns an [ApiResponse] wrapping a list of [FileMetadata].
  Future<ApiResponse<List<FileMetadata>>> listFiles(String prefix) async {
    try {
      final ref = _storage.ref(prefix);
      final result = await ref.listAll();

      final metadataList = <FileMetadata>[];
      for (final item in result.items) {
        final meta = await item.getMetadata();
        String? downloadUrl;
        try {
          downloadUrl = await item.getDownloadURL();
        } catch (_) {
          // Some items may not have a public download URL.
        }

        metadataList.add(
          FileMetadata(
            name: item.name,
            fullPath: item.fullPath,
            size: meta.size ?? 0,
            timeCreated: meta.timeCreated ?? DateTime(0),
            updated: meta.updated ?? DateTime(0),
            downloadUrl: downloadUrl,
          ),
        );
      }

      return ApiResponse.success(metadataList);
    } on FirebaseException catch (e) {
      return ApiResponse.error('Failed to list files: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Generates a unique file name based on a timestamp and the original name.
  String _uniqueFileName(String path) {
    final name = path.split(Platform.pathSeparator).last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${timestamp}_$name';
  }

  /// Returns a content-type string for common video formats.
  String _videoContentType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      case 'mkv':
        return 'video/x-matroska';
      case 'webm':
        return 'video/webm';
      default:
        return 'video/mp4';
    }
  }

  /// Returns a content-type string for common image formats.
  String _imageContentType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }
}
