import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../config/appwrite_config.dart';
import '../../core/network/api_response.dart';

/// File storage service using Appwrite (free tier: 10GB storage).
class AppwriteStorageService {
  final Storage _storage;

  AppwriteStorageService(Client client) : _storage = Storage(client);

  /// Upload a video file with progress tracking.
  ///
  /// Returns the file ID on success.
  Future<ApiResponse<String>> uploadVideo({
    required String projectId,
    required File file,
    Function(double progress)? onProgress,
  }) async {
    try {
      final fileName = _generateFileName(file.path);
      final fileId = ID.unique();

      // Report initial progress
      onProgress?.call(0.0);

      final file = await _storage.createFile(
        bucketId: AppwriteConfig.videosBucketId,
        fileId: fileId,
        file: InputFile(
          path: file.path,
          filename: fileName,
        ),
        onProgress: (progress) {
          onProgress?.call(progress);
        },
      );

      return ApiResponse.success(data: file.$id);
    } on AppwriteException catch (e) {
      debugPrint('Appwrite uploadVideo error: ${e.message}');
      return ApiResponse.error(
        statusCode: e.code ?? 500,
        message: 'Failed to upload video: ${e.message}',
      );
    }
  }

  /// Upload a thumbnail image.
  Future<ApiResponse<String>> uploadThumbnail({
    required String projectId,
    required File file,
  }) async {
    try {
      final fileName = _generateFileName(file.path, prefix: 'thumb');

      final result = await _storage.createFile(
        bucketId: AppwriteConfig.thumbnailsBucketId,
        fileId: ID.unique(),
        file: InputFile(
          path: file.path,
          filename: fileName,
        ),
      );

      return ApiResponse.success(data: result.$id);
    } on AppwriteException catch (e) {
      debugPrint('Appwrite uploadThumbnail error: ${e.message}');
      return ApiResponse.error(
        statusCode: e.code ?? 500,
        message: 'Failed to upload thumbnail: ${e.message}',
      );
    }
  }

  /// Get a temporary file view URL (for playback).
  Future<ApiResponse<String>> getFileView({
    required String bucketId,
    required String fileId,
  }) async {
    try {
      final url = _storage.getFileView(
        bucketId: bucketId,
        fileId: fileId,
      );
      return ApiResponse.success(data: url.toString());
    } catch (e) {
      return ApiResponse.error(
        statusCode: 500,
        message: 'Failed to get file URL: $e',
      );
    }
  }

  /// Get a temporary file download URL.
  Future<ApiResponse<String>> getFileDownload({
    required String bucketId,
    required String fileId,
  }) async {
    try {
      final url = _storage.getFileDownload(
        bucketId: bucketId,
        fileId: fileId,
      );
      return ApiResponse.success(data: url.toString());
    } catch (e) {
      return ApiResponse.error(
        statusCode: 500,
        message: 'Failed to get download URL: $e',
      );
    }
  }

  /// Delete a file from storage.
  Future<ApiResponse<void>> deleteFile({
    required String bucketId,
    required String fileId,
  }) async {
    try {
      await _storage.deleteFile(
        bucketId: bucketId,
        fileId: fileId,
      );
      return ApiResponse.success(data: null);
    } on AppwriteException catch (e) {
      debugPrint('Appwrite deleteFile error: ${e.message}');
      return ApiResponse.error(
        statusCode: e.code ?? 500,
        message: 'Failed to delete file: ${e.message}',
      );
    }
  }

  /// List files in a bucket with optional search.
  Future<ApiResponse<List<models.File>>> listFiles({
    required String bucketId,
    String? search,
    int limit = 25,
    int offset = 0,
  }) async {
    try {
      final result = await _storage.listFiles(
        bucketId: bucketId,
        search: search,
        limit: limit,
        offset: offset,
      );
      return ApiResponse.success(data: result.files);
    } on AppwriteException catch (e) {
      debugPrint('Appwrite listFiles error: ${e.message}');
      return ApiResponse.error(
        statusCode: e.code ?? 500,
        message: 'Failed to list files: ${e.message}',
      );
    }
  }

  /// Generate a unique filename preserving extension.
  String _generateFileName(String path, {String? prefix}) {
    final ext = p.extension(path);
    final base = prefix ?? 'file';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${base}_$timestamp$ext';
  }
}
