/// Video source models for the AI Video Editor app.
///
/// Models representing uploaded video files and linked videos from platforms.

/// Supported video file extensions.
enum VideoFileExtension {
  mp4,
  mov,
  avi,
  mkv,
  webm,
  flv,
  wmv,
  m4v;

  factory VideoFileExtension.fromString(String value) {
    final normalized = value.toLowerCase().replaceFirst('.', '');
    return VideoFileExtension.values.firstWhere(
      (e) => e.name == normalized,
      orElse: () => VideoFileExtension.mp4,
    );
  }

  String toJson() => name;

  /// Whether this format is widely supported across platforms.
  bool get isWebCompatible => this == mp4 || this == webm;
}

/// Supported video platforms for link imports.
enum VideoPlatform {
  youtube,
  tiktok,
  instagram,
  twitter,
  facebook,
  vimeo,
  twitch,
  bilibili,
  other;

  factory VideoPlatform.fromString(String value) {
    return VideoPlatform.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => VideoPlatform.other,
    );
  }

  String toJson() => name;

  /// Tries to detect the platform from a URL.
  static VideoPlatform detectFromUrl(String url) {
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('youtube.com') || lowerUrl.contains('youtu.be')) {
      return VideoPlatform.youtube;
    }
    if (lowerUrl.contains('tiktok.com')) {
      return VideoPlatform.tiktok;
    }
    if (lowerUrl.contains('instagram.com')) {
      return VideoPlatform.instagram;
    }
    if (lowerUrl.contains('twitter.com') || lowerUrl.contains('x.com')) {
      return VideoPlatform.twitter;
    }
    if (lowerUrl.contains('facebook.com')) {
      return VideoPlatform.facebook;
    }
    if (lowerUrl.contains('vimeo.com')) {
      return VideoPlatform.vimeo;
    }
    if (lowerUrl.contains('twitch.tv')) {
      return VideoPlatform.twitch;
    }
    if (lowerUrl.contains('bilibili.com')) {
      return VideoPlatform.bilibili;
    }
    return VideoPlatform.other;
  }
}

/// Represents an audio stream within a video file.
class AudioStream {
  final String codec;
  final int? sampleRate;
  final int? channels;
  final int? bitrate;
  final String? language;

  const AudioStream({
    required this.codec,
    this.sampleRate,
    this.channels,
    this.bitrate,
    this.language,
  });

  factory AudioStream.fromJson(Map<String, dynamic> json) {
    return AudioStream(
      codec: json['codec'] as String? ?? 'unknown',
      sampleRate: json['sampleRate'] as int?,
      channels: json['channels'] as int?,
      bitrate: json['bitrate'] as int?,
      language: json['language'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codec': codec,
      if (sampleRate != null) 'sampleRate': sampleRate,
      if (channels != null) 'channels': channels,
      if (bitrate != null) 'bitrate': bitrate,
      if (language != null) 'language': language,
    };
  }

  AudioStream copyWith({
    String? codec,
    int? sampleRate,
    int? channels,
    int? bitrate,
    String? language,
    bool clearLanguage = false,
  }) {
    return AudioStream(
      codec: codec ?? this.codec,
      sampleRate: sampleRate ?? this.sampleRate,
      channels: channels ?? this.channels,
      bitrate: bitrate ?? this.bitrate,
      language: clearLanguage ? null : (language ?? this.language),
    );
  }

  @override
  String toString() =>
      'AudioStream(codec: $codec, sampleRate: $sampleRate, channels: $channels)';
}

/// Represents an uploaded video file with its metadata.
class VideoSource {
  final String id;
  final String filePath;
  final VideoFileExtension fileExtension;
  final int fileSize; // in bytes
  final double duration; // in seconds
  final int width;
  final int height;
  final double fps;
  final String codec;
  final List<AudioStream> audioStreams;
  final String? thumbnailUrl;
  final double uploadProgress; // 0.0 to 1.0

  const VideoSource({
    required this.id,
    required this.filePath,
    required this.fileExtension,
    required this.fileSize,
    required this.duration,
    required this.width,
    required this.height,
    required this.fps,
    required this.codec,
    this.audioStreams = const [],
    this.thumbnailUrl,
    this.uploadProgress = 0.0,
  });

  /// Creates a VideoSource from JSON.
  factory VideoSource.fromJson(Map<String, dynamic> json) {
    return VideoSource(
      id: json['id'] as String? ?? '',
      filePath: json['filePath'] as String? ?? '',
      fileExtension: json['fileExtension'] != null
          ? VideoFileExtension.fromString(json['fileExtension'] as String)
          : VideoFileExtension.mp4,
      fileSize: json['fileSize'] as int? ?? 0,
      duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
      fps: (json['fps'] as num?)?.toDouble() ?? 30.0,
      codec: json['codec'] as String? ?? 'unknown',
      audioStreams: (json['audioStreams'] as List<dynamic>?)
              ?.map((s) => AudioStream.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      thumbnailUrl: json['thumbnailUrl'] as String?,
      uploadProgress: (json['uploadProgress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'fileExtension': fileExtension.toJson(),
      'fileSize': fileSize,
      'duration': duration,
      'width': width,
      'height': height,
      'fps': fps,
      'codec': codec,
      'audioStreams': audioStreams.map((s) => s.toJson()).toList(),
      'thumbnailUrl': thumbnailUrl,
      'uploadProgress': uploadProgress,
    };
  }

  VideoSource copyWith({
    String? id,
    String? filePath,
    VideoFileExtension? fileExtension,
    int? fileSize,
    double? duration,
    int? width,
    int? height,
    double? fps,
    String? codec,
    List<AudioStream>? audioStreams,
    String? thumbnailUrl,
    double? uploadProgress,
    bool clearThumbnailUrl = false,
  }) {
    return VideoSource(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileExtension: fileExtension ?? this.fileExtension,
      fileSize: fileSize ?? this.fileSize,
      duration: duration ?? this.duration,
      width: width ?? this.width,
      height: height ?? this.height,
      fps: fps ?? this.fps,
      codec: codec ?? this.codec,
      audioStreams: audioStreams ?? this.audioStreams,
      thumbnailUrl:
          clearThumbnailUrl ? null : (thumbnailUrl ?? this.thumbnailUrl),
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  /// Video resolution as a formatted string (e.g., "1920x1080").
  String get resolution => '${width}x$height';

  /// Human-readable file size (e.g., "1.5 GB").
  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Human-readable duration (e.g., "1:23:45").
  String get durationFormatted {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = (duration % 60).toInt();
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Whether the upload is complete.
  bool get isUploadComplete => uploadProgress >= 1.0;

  /// Whether the video has audio tracks.
  bool get hasAudio => audioStreams.isNotEmpty;

  /// Aspect ratio as a string (e.g., "16:9").
  String get aspectRatio {
    final gcd = _gcd(width, height);
    return '${width ~/ gcd}:${height ~/ gcd}';
  }

  int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  @override
  String toString() =>
      'VideoSource(id: $id, resolution: $resolution, duration: $durationFormatted)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoSource &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Represents a video linked from an external platform.
class UploadLink {
  final String id;
  final String url;
  final VideoPlatform platform;
  final String? title;
  final String? thumbnailUrl;
  final double? duration; // in seconds

  const UploadLink({
    required this.id,
    required this.url,
    required this.platform,
    this.title,
    this.thumbnailUrl,
    this.duration,
  });

  /// Creates an UploadLink from JSON.
  factory UploadLink.fromJson(Map<String, dynamic> json) {
    return UploadLink(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      platform: json['platform'] != null
          ? VideoPlatform.fromString(json['platform'] as String)
          : VideoPlatform.detectFromUrl(json['url'] as String? ?? ''),
      title: json['title'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      duration: (json['duration'] as num?)?.toDouble(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'platform': platform.toJson(),
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
    };
  }

  UploadLink copyWith({
    String? id,
    String? url,
    VideoPlatform? platform,
    String? title,
    String? thumbnailUrl,
    double? duration,
    bool clearTitle = false,
    bool clearThumbnailUrl = false,
    bool clearDuration = false,
  }) {
    return UploadLink(
      id: id ?? this.id,
      url: url ?? this.url,
      platform: platform ?? this.platform,
      title: clearTitle ? null : (title ?? this.title),
      thumbnailUrl:
          clearThumbnailUrl ? null : (thumbnailUrl ?? this.thumbnailUrl),
      duration: clearDuration ? null : (duration ?? this.duration),
    );
  }

  @override
  String toString() =>
      'UploadLink(id: $id, platform: $platform, title: $title)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadLink &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
