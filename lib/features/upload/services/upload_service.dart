import 'dart:io';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';

/// Represents a video source after upload or link ingestion.
class VideoSource {
  const VideoSource({
    required this.id,
    required this.url,
    required this.type,
    this.duration,
    this.width,
    this.height,
    this.thumbnailUrl,
    this.fileSize,
  });

  factory VideoSource.fromJson(Map<String, dynamic> json) {
    return VideoSource(
      id: json['id'] as String,
      url: json['url'] as String,
      type: VideoSourceType.fromString(json['type'] as String? ?? 'file'),
      duration: (json['duration'] as num?)?.toDouble(),
      width: json['width'] as int?,
      height: json['height'] as int?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      fileSize: json['fileSize'] as int?,
    );
  }

  final String id;
  final String url;
  final VideoSourceType type;
  final double? duration;
  final int? width;
  final int? height;
  final String? thumbnailUrl;
  final int? fileSize;
}

enum VideoSourceType {
  file('file'),
  link('link');

  const VideoSourceType(this.value);

  final String value;

  factory VideoSourceType.fromString(String value) {
    return VideoSourceType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => VideoSourceType.file,
    );
  }
}

/// Callback for upload progress (0.0 – 1.0).
typedef UploadProgressCallback = void Function(double progress);

/// Handles video file uploads and link ingestion.
class UploadService {
  UploadService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  /// Supported file extensions (lowercase, without dot).
  static const List<String> _supportedFormats = [
    'mp4',
    'mov',
    'avi',
    'mkv',
    'webm',
    'flv',
    'wmv',
    'm4v',
  ];

  /// Maximum file size: 2 GB.
  static const int _maxFileSizeBytes = 2 * 1024 * 1024 * 1024;

  /// Returns the list of supported video file formats.
  List<String> getSupportedFormats() => List.unmodifiable(_supportedFormats);

  /// Validates that [file] is eligible for upload.
  ///
  /// Returns `true` if the file extension is supported and its size is within
  /// the allowed limit.
  bool validateFile(File file) {
    // Check extension.
    final path = file.path.toLowerCase();
    final ext = path.contains('.') ? path.split('.').last : '';
    if (!_supportedFormats.contains(ext)) return false;

    // Check file size.
    try {
      final size = file.lengthSync();
      if (size > _maxFileSizeBytes) return false;
    } catch (_) {
      return false;
    }

    return true;
  }

  /// Uploads a video file to the backend, streaming progress via [onProgress].
  ///
  /// Returns the resulting [VideoSource] on success.
  Future<ApiResponse<VideoSource>> uploadFile(
    File file, {
    UploadProgressCallback? onProgress,
  }) async {
    try {
      if (!validateFile(file)) {
        return ApiResponse.error(
          'Unsupported file format or file exceeds the 2 GB limit.',
          statusCode: 400,
        );
      }

      final fileName = file.path.split(Platform.pathSeparator).last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await _api.post<VideoSource>(
        '/uploads/video',
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) {
            onProgress?.call(sent / total);
          }
        },
        fromJson: (data) => VideoSource.fromJson(data as Map<String, dynamic>),
      );

      return response;
    } catch (e) {
      return ApiResponse.error('Upload failed: $e');
    }
  }

  /// Ingests a video from a remote [url] (e.g. YouTube, Vimeo).
  Future<ApiResponse<VideoSource>> uploadLink(String url) async {
    try {
      if (url.isEmpty) {
        return ApiResponse.error('URL cannot be empty.', statusCode: 400);
      }

      return _api.post<VideoSource>(
        '/uploads/link',
        data: {'url': url},
        fromJson: (data) => VideoSource.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.error('Link ingestion failed: $e');
    }
  }
}
