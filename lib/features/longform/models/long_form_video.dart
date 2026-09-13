/// Long-form video models for the AI Video Editor app.
///
/// Models representing generated long-form videos with chapters and commentary.

/// The status of a long-form video generation.
enum LongFormStatus {
  pending,
  generating,
  editing,
  rendering,
  completed,
  failed;

  factory LongFormStatus.fromString(String value) {
    return LongFormStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LongFormStatus.pending,
    );
  }

  String toJson() => name;
}

/// The type of transition between chapters.
enum TransitionType {
  cut,
  dissolve,
  fade,
  wipe,
  zoom,
  morph;

  factory TransitionType.fromString(String value) {
    return TransitionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransitionType.cut,
    );
  }

  String toJson() => name;
}

/// An event within a chapter (e.g., a scene change, speaker switch, etc.).
class ChapterEvent {
  final String id;
  final String type;
  final double timestamp;
  final String? description;
  final Map<String, dynamic>? metadata;

  const ChapterEvent({
    required this.id,
    required this.type,
    required this.timestamp,
    this.description,
    this.metadata,
  });

  factory ChapterEvent.fromJson(Map<String, dynamic> json) {
    return ChapterEvent(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      timestamp: (json['timestamp'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'timestamp': timestamp,
      'description': description,
      'metadata': metadata,
    };
  }

  ChapterEvent copyWith({
    String? id,
    String? type,
    double? timestamp,
    String? description,
    Map<String, dynamic>? metadata,
    bool clearDescription = false,
    bool clearMetadata = false,
  }) {
    return ChapterEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      description: clearDescription ? null : (description ?? this.description),
      metadata: clearMetadata ? null : (metadata ?? this.metadata),
    );
  }

  @override
  String toString() =>
      'ChapterEvent(id: $id, type: $type, ${timestamp.toStringAsFixed(1)}s)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChapterEvent && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// A chapter in the long-form video.
class Chapter {
  final String id;
  final String title;
  final String description;
  final double startTime;
  final double endTime;
  final List<ChapterEvent> events;
  final TransitionType transitionType;
  final String? commentary;

  const Chapter({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.events = const [],
    this.transitionType = TransitionType.cut,
    this.commentary,
  });

  /// Creates a Chapter from JSON.
  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      startTime: (json['startTime'] as num?)?.toDouble() ?? 0.0,
      endTime: (json['endTime'] as num?)?.toDouble() ?? 0.0,
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => ChapterEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      transitionType: json['transitionType'] != null
          ? TransitionType.fromString(json['transitionType'] as String)
          : TransitionType.cut,
      commentary: json['commentary'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'events': events.map((e) => e.toJson()).toList(),
      'transitionType': transitionType.toJson(),
      'commentary': commentary,
    };
  }

  /// Creates a copy with selective field updates.
  Chapter copyWith({
    String? id,
    String? title,
    String? description,
    double? startTime,
    double? endTime,
    List<ChapterEvent>? events,
    TransitionType? transitionType,
    String? commentary,
    bool clearCommentary = false,
  }) {
    return Chapter(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      events: events ?? this.events,
      transitionType: transitionType ?? this.transitionType,
      commentary: clearCommentary ? null : (commentary ?? this.commentary),
    );
  }

  /// Duration of this chapter in seconds.
  double get duration => endTime - startTime;

  /// Number of events in this chapter.
  int get eventCount => events.length;

  /// Formatted duration as mm:ss.
  String get durationFormatted {
    final minutes = duration ~/ 60;
    final seconds = (duration % 60).toInt();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Formatted time range (e.g., "5:23 - 10:45").
  String get timeRangeFormatted {
    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  String _formatTime(double seconds) {
    final mins = seconds ~/ 60;
    final secs = (seconds % 60).toInt();
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  @override
  String toString() =>
      'Chapter(id: $id, title: $title, ${startTime.toStringAsFixed(1)}-${endTime.toStringAsFixed(1)})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Chapter && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// A version of a long-form video (for iteration).
class LongFormVersion {
  final int versionNumber;
  final String? videoUrl;
  final DateTime createdAt;
  final double? score;

  const LongFormVersion({
    required this.versionNumber,
    this.videoUrl,
    required this.createdAt,
    this.score,
  });

  factory LongFormVersion.fromJson(Map<String, dynamic> json) {
    return LongFormVersion(
      versionNumber: json['versionNumber'] as int? ?? 1,
      videoUrl: json['videoUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      score: (json['score'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'versionNumber': versionNumber,
      'videoUrl': videoUrl,
      'createdAt': createdAt.toIso8601String(),
      'score': score,
    };
  }

  LongFormVersion copyWith({
    int? versionNumber,
    String? videoUrl,
    DateTime? createdAt,
    double? score,
    bool clearVideoUrl = false,
    bool clearScore = false,
  }) {
    return LongFormVersion(
      versionNumber: versionNumber ?? this.versionNumber,
      videoUrl: clearVideoUrl ? null : (videoUrl ?? this.videoUrl),
      createdAt: createdAt ?? this.createdAt,
      score: clearScore ? null : (score ?? this.score),
    );
  }

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;

  @override
  String toString() =>
      'LongFormVersion(v$versionNumber, score: ${score?.toStringAsFixed(2) ?? "N/A"})';
}

/// A generated long-form video.
class LongFormVideo {
  final String id;
  final String projectId;
  final String title;
  final double targetDuration;
  final double actualDuration;
  final List<Chapter> chapters;
  final LongFormStatus status;
  final String? commentaryNarration;
  final String? thumbnailUrl;
  final List<LongFormVersion> versions;

  const LongFormVideo({
    required this.id,
    required this.projectId,
    required this.title,
    required this.targetDuration,
    required this.actualDuration,
    this.chapters = const [],
    required this.status,
    this.commentaryNarration,
    this.thumbnailUrl,
    this.versions = const [],
  });

  /// Creates a LongFormVideo from JSON.
  factory LongFormVideo.fromJson(Map<String, dynamic> json) {
    return LongFormVideo(
      id: json['id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      targetDuration: (json['targetDuration'] as num?)?.toDouble() ?? 0.0,
      actualDuration: (json['actualDuration'] as num?)?.toDouble() ?? 0.0,
      chapters: (json['chapters'] as List<dynamic>?)
              ?.map((c) => Chapter.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      status: json['status'] != null
          ? LongFormStatus.fromString(json['status'] as String)
          : LongFormStatus.pending,
      commentaryNarration: json['commentaryNarration'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      versions: (json['versions'] as List<dynamic>?)
              ?.map((v) => LongFormVersion.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'targetDuration': targetDuration,
      'actualDuration': actualDuration,
      'chapters': chapters.map((c) => c.toJson()).toList(),
      'status': status.toJson(),
      'commentaryNarration': commentaryNarration,
      'thumbnailUrl': thumbnailUrl,
      'versions': versions.map((v) => v.toJson()).toList(),
    };
  }

  /// Creates a copy with selective field updates.
  LongFormVideo copyWith({
    String? id,
    String? projectId,
    String? title,
    double? targetDuration,
    double? actualDuration,
    List<Chapter>? chapters,
    LongFormStatus? status,
    String? commentaryNarration,
    String? thumbnailUrl,
    List<LongFormVersion>? versions,
    bool clearCommentaryNarration = false,
    bool clearThumbnailUrl = false,
  }) {
    return LongFormVideo(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      targetDuration: targetDuration ?? this.targetDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      chapters: chapters ?? this.chapters,
      status: status ?? this.status,
      commentaryNarration: clearCommentaryNarration
          ? null
          : (commentaryNarration ?? this.commentaryNarration),
      thumbnailUrl:
          clearThumbnailUrl ? null : (thumbnailUrl ?? this.thumbnailUrl),
      versions: versions ?? this.versions,
    );
  }

  /// Number of chapters.
  int get chapterCount => chapters.length;

  /// Number of versions.
  int get versionCount => versions.length;

  /// The latest version.
  LongFormVersion? get latestVersion =>
      versions.isEmpty ? null : versions.last;

  /// Actual duration formatted as HH:MM:SS or MM:SS.
  String get durationFormatted {
    final hours = actualDuration ~/ 3600;
    final minutes = (actualDuration % 3600) ~/ 60;
    final seconds = (actualDuration % 60).toInt();
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Whether the video meets the target duration (within 10%).
  bool get meetsTargetDuration {
    final diff = (actualDuration - targetDuration).abs();
    return diff / targetDuration <= 0.1;
  }

  @override
  String toString() =>
      'LongFormVideo(id: $id, title: $title, status: ${status.name}, chapters: $chapterCount)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LongFormVideo &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
