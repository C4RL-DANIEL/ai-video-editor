/// Short video models for the AI Video Editor app.
///
/// Models representing generated short-form videos (YouTube Shorts, TikTok, etc.)

/// The status of a short video generation.
enum ShortVideoStatus {
  pending,
  generating,
  editing,
  rendering,
  completed,
  failed;

  factory ShortVideoStatus.fromString(String value) {
    return ShortVideoStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ShortVideoStatus.pending,
    );
  }

  String toJson() => name;
}

/// The category/genre of a short video.
enum ShortCategory {
  comedy,
  informative,
  storyTime,
  reaction,
  tutorial,
  highlights,
  motivational,
  horror,
  gaming,
  news,
  other;

  factory ShortCategory.fromString(String value) {
    return ShortCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ShortCategory.other,
    );
  }

  String toJson() => name;
}

/// The editing style applied to a short video.
enum EditingStyle {
  minimal,
  dynamic,
  cinematic,
  meme,
  documentary,
  podcast,
  sports,
  musicVideo;

  factory EditingStyle.fromString(String value) {
    return EditingStyle.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EditingStyle.dynamic,
    );
  }

  String toJson() => name;
}

/// A caption/subtitle entry in the short video.
class CaptionEntry {
  final String text;
  final double startTime;
  final double endTime;
  final CaptionPosition position;
  final CaptionStyle style;
  final List<String> keywords;
  final bool isEmphasized;

  const CaptionEntry({
    required this.text,
    required this.startTime,
    required this.endTime,
    this.position = CaptionPosition.bottom,
    this.style = const CaptionStyle(),
    this.keywords = const [],
    this.isEmphasized = false,
  });

  factory CaptionEntry.fromJson(Map<String, dynamic> json) {
    return CaptionEntry(
      text: json['text'] as String? ?? '',
      startTime: (json['startTime'] as num?)?.toDouble() ?? 0.0,
      endTime: (json['endTime'] as num?)?.toDouble() ?? 0.0,
      position: json['position'] != null
          ? CaptionPosition.fromString(json['position'] as String)
          : CaptionPosition.bottom,
      style: json['style'] != null
          ? CaptionStyle.fromJson(json['style'] as Map<String, dynamic>)
          : const CaptionStyle(),
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((k) => k as String)
              .toList() ??
          [],
      isEmphasized: json['isEmphasized'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'startTime': startTime,
      'endTime': endTime,
      'position': position.toJson(),
      'style': style.toJson(),
      'keywords': keywords,
      'isEmphasized': isEmphasized,
    };
  }

  CaptionEntry copyWith({
    String? text,
    double? startTime,
    double? endTime,
    CaptionPosition? position,
    CaptionStyle? style,
    List<String>? keywords,
    bool? isEmphasized,
  }) {
    return CaptionEntry(
      text: text ?? this.text,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      position: position ?? this.position,
      style: style ?? this.style,
      keywords: keywords ?? this.keywords,
      isEmphasized: isEmphasized ?? this.isEmphasized,
    );
  }

  double get duration => endTime - startTime;

  @override
  String toString() =>
      'CaptionEntry("$text", ${startTime.toStringAsFixed(1)}-${endTime.toStringAsFixed(1)})';
}

/// Caption position on screen.
enum CaptionPosition {
  top,
  center,
  bottom,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight;

  factory CaptionPosition.fromString(String value) {
    return CaptionPosition.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CaptionPosition.bottom,
    );
  }

  String toJson() => name;
}

/// Visual style for a caption.
class CaptionStyle {
  final String? fontFamily;
  final double fontSize;
  final String? color;
  final String? backgroundColor;
  final double? backgroundOpacity;
  final bool isBold;
  final bool isItalic;
  final double? shadowBlur;
  final String? shadowColor;

  const CaptionStyle({
    this.fontFamily,
    this.fontSize = 24.0,
    this.color = '#FFFFFF',
    this.backgroundColor,
    this.backgroundOpacity,
    this.isBold = true,
    this.isItalic = false,
    this.shadowBlur,
    this.shadowColor = '#000000',
  });

  factory CaptionStyle.fromJson(Map<String, dynamic> json) {
    return CaptionStyle(
      fontFamily: json['fontFamily'] as String?,
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 24.0,
      color: json['color'] as String? ?? '#FFFFFF',
      backgroundColor: json['backgroundColor'] as String?,
      backgroundOpacity: (json['backgroundOpacity'] as num?)?.toDouble(),
      isBold: json['isBold'] as bool? ?? true,
      isItalic: json['isItalic'] as bool? ?? false,
      shadowBlur: (json['shadowBlur'] as num?)?.toDouble(),
      shadowColor: json['shadowColor'] as String? ?? '#000000',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (fontFamily != null) 'fontFamily': fontFamily,
      'fontSize': fontSize,
      'color': color,
      if (backgroundColor != null) 'backgroundColor': backgroundColor,
      if (backgroundOpacity != null) 'backgroundOpacity': backgroundOpacity,
      'isBold': isBold,
      'isItalic': isItalic,
      if (shadowBlur != null) 'shadowBlur': shadowBlur,
      if (shadowColor != null) 'shadowColor': shadowColor,
    };
  }

  CaptionStyle copyWith({
    String? fontFamily,
    double? fontSize,
    String? color,
    String? backgroundColor,
    double? backgroundOpacity,
    bool? isBold,
    bool? isItalic,
    double? shadowBlur,
    String? shadowColor,
    bool clearFontFamily = false,
    bool clearBackgroundColor = false,
    bool clearBackgroundOpacity = false,
    bool clearShadowBlur = false,
    bool clearShadowColor = false,
  }) {
    return CaptionStyle(
      fontFamily: clearFontFamily ? null : (fontFamily ?? this.fontFamily),
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      backgroundColor: clearBackgroundColor
          ? null
          : (backgroundColor ?? this.backgroundColor),
      backgroundOpacity: clearBackgroundOpacity
          ? null
          : (backgroundOpacity ?? this.backgroundOpacity),
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      shadowBlur: clearShadowBlur ? null : (shadowBlur ?? this.shadowBlur),
      shadowColor:
          clearShadowColor ? null : (shadowColor ?? this.shadowColor),
    );
  }

  @override
  String toString() => 'CaptionStyle(font: $fontFamily, size: $fontSize, bold: $isBold)';
}

/// Audio configuration for the short video.
class AudioConfig {
  final double commentaryVolume; // 0.0 to 1.0
  final double musicVolume; // 0.0 to 1.0
  final double sfxVolume; // 0.0 to 1.0
  final bool duckingEnabled;

  const AudioConfig({
    this.commentaryVolume = 1.0,
    this.musicVolume = 0.3,
    this.sfxVolume = 0.5,
    this.duckingEnabled = true,
  });

  factory AudioConfig.fromJson(Map<String, dynamic> json) {
    return AudioConfig(
      commentaryVolume:
          (json['commentaryVolume'] as num?)?.toDouble() ?? 1.0,
      musicVolume: (json['musicVolume'] as num?)?.toDouble() ?? 0.3,
      sfxVolume: (json['sfxVolume'] as num?)?.toDouble() ?? 0.5,
      duckingEnabled: json['duckingEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commentaryVolume': commentaryVolume,
      'musicVolume': musicVolume,
      'sfxVolume': sfxVolume,
      'duckingEnabled': duckingEnabled,
    };
  }

  AudioConfig copyWith({
    double? commentaryVolume,
    double? musicVolume,
    double? sfxVolume,
    bool? duckingEnabled,
  }) {
    return AudioConfig(
      commentaryVolume: commentaryVolume ?? this.commentaryVolume,
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      duckingEnabled: duckingEnabled ?? this.duckingEnabled,
    );
  }

  @override
  String toString() =>
      'AudioConfig(commentary: $commentaryVolume, music: $musicVolume, sfx: $sfxVolume)';
}

/// An edit decision applied during rendering.
class EditDecisionEntry {
  final String type;
  final double startTime;
  final double endTime;
  final Map<String, dynamic>? params;

  const EditDecisionEntry({
    required this.type,
    required this.startTime,
    required this.endTime,
    this.params,
  });

  factory EditDecisionEntry.fromJson(Map<String, dynamic> json) {
    return EditDecisionEntry(
      type: json['type'] as String? ?? '',
      startTime: (json['startTime'] as num?)?.toDouble() ?? 0.0,
      endTime: (json['endTime'] as num?)?.toDouble() ?? 0.0,
      params: json['params'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'startTime': startTime,
      'endTime': endTime,
      'params': params,
    };
  }

  @override
  String toString() =>
      'EditDecisionEntry(type: $type, ${startTime.toStringAsFixed(1)}-${endTime.toStringAsFixed(1)})';
}

/// A version of a short video (for A/B testing and iteration).
class ShortVersion {
  final int versionNumber;
  final String? videoUrl;
  final List<EditDecisionEntry> editDecisions;
  final double? score;
  final DateTime createdAt;

  const ShortVersion({
    required this.versionNumber,
    this.videoUrl,
    this.editDecisions = const [],
    this.score,
    required this.createdAt,
  });

  factory ShortVersion.fromJson(Map<String, dynamic> json) {
    return ShortVersion(
      versionNumber: json['versionNumber'] as int? ?? 1,
      videoUrl: json['videoUrl'] as String?,
      editDecisions: (json['editDecisions'] as List<dynamic>?)
              ?.map((e) =>
                  EditDecisionEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      score: (json['score'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'versionNumber': versionNumber,
      'videoUrl': videoUrl,
      'editDecisions': editDecisions.map((e) => e.toJson()).toList(),
      'score': score,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ShortVersion copyWith({
    int? versionNumber,
    String? videoUrl,
    List<EditDecisionEntry>? editDecisions,
    double? score,
    DateTime? createdAt,
    bool clearVideoUrl = false,
    bool clearScore = false,
  }) {
    return ShortVersion(
      versionNumber: versionNumber ?? this.versionNumber,
      videoUrl: clearVideoUrl ? null : (videoUrl ?? this.videoUrl),
      editDecisions: editDecisions ?? this.editDecisions,
      score: clearScore ? null : (score ?? this.score),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;

  @override
  String toString() =>
      'ShortVersion(v$versionNumber, score: ${score?.toStringAsFixed(2) ?? "N/A"})';
}

/// A generated short-form video.
class ShortVideo {
  final String id;
  final String projectId;
  final String momentId;
  final String title;
  final double duration;
  final double targetDuration;
  final String? hookText;
  final ShortVideoStatus status;
  final double hookScore;
  final double viralScore;
  final ShortCategory category;
  final double sourceTimestamp;
  final EditingStyle editingStyle;
  final double estimatedRetention;
  final List<ShortVersion> versions;
  final List<CaptionEntry> captions;
  final String? commentaryText;
  final AudioConfig audioConfig;
  final String? thumbnailUrl;

  const ShortVideo({
    required this.id,
    required this.projectId,
    required this.momentId,
    required this.title,
    required this.duration,
    required this.targetDuration,
    this.hookText,
    required this.status,
    this.hookScore = 0.0,
    this.viralScore = 0.0,
    required this.category,
    required this.sourceTimestamp,
    required this.editingStyle,
    this.estimatedRetention = 0.0,
    this.versions = const [],
    this.captions = const [],
    this.commentaryText,
    this.audioConfig = const AudioConfig(),
    this.thumbnailUrl,
  });

  /// Creates a ShortVideo from JSON.
  factory ShortVideo.fromJson(Map<String, dynamic> json) {
    return ShortVideo(
      id: json['id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      momentId: json['momentId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
      targetDuration: (json['targetDuration'] as num?)?.toDouble() ?? 60.0,
      hookText: json['hookText'] as String?,
      status: json['status'] != null
          ? ShortVideoStatus.fromString(json['status'] as String)
          : ShortVideoStatus.pending,
      hookScore: (json['hookScore'] as num?)?.toDouble() ?? 0.0,
      viralScore: (json['viralScore'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] != null
          ? ShortCategory.fromString(json['category'] as String)
          : ShortCategory.other,
      sourceTimestamp:
          (json['sourceTimestamp'] as num?)?.toDouble() ?? 0.0,
      editingStyle: json['editingStyle'] != null
          ? EditingStyle.fromString(json['editingStyle'] as String)
          : EditingStyle.dynamic,
      estimatedRetention:
          (json['estimatedRetention'] as num?)?.toDouble() ?? 0.0,
      versions: (json['versions'] as List<dynamic>?)
              ?.map((v) => ShortVersion.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      captions: (json['captions'] as List<dynamic>?)
              ?.map((c) => CaptionEntry.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      commentaryText: json['commentaryText'] as String?,
      audioConfig: json['audioConfig'] != null
          ? AudioConfig.fromJson(json['audioConfig'] as Map<String, dynamic>)
          : const AudioConfig(),
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'momentId': momentId,
      'title': title,
      'duration': duration,
      'targetDuration': targetDuration,
      'hookText': hookText,
      'status': status.toJson(),
      'hookScore': hookScore,
      'viralScore': viralScore,
      'category': category.toJson(),
      'sourceTimestamp': sourceTimestamp,
      'editingStyle': editingStyle.toJson(),
      'estimatedRetention': estimatedRetention,
      'versions': versions.map((v) => v.toJson()).toList(),
      'captions': captions.map((c) => c.toJson()).toList(),
      'commentaryText': commentaryText,
      'audioConfig': audioConfig.toJson(),
      'thumbnailUrl': thumbnailUrl,
    };
  }

  /// Creates a copy with selective field updates.
  ShortVideo copyWith({
    String? id,
    String? projectId,
    String? momentId,
    String? title,
    double? duration,
    double? targetDuration,
    String? hookText,
    ShortVideoStatus? status,
    double? hookScore,
    double? viralScore,
    ShortCategory? category,
    double? sourceTimestamp,
    EditingStyle? editingStyle,
    double? estimatedRetention,
    List<ShortVersion>? versions,
    List<CaptionEntry>? captions,
    String? commentaryText,
    AudioConfig? audioConfig,
    String? thumbnailUrl,
    bool clearHookText = false,
    bool clearCommentaryText = false,
    bool clearThumbnailUrl = false,
  }) {
    return ShortVideo(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      momentId: momentId ?? this.momentId,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      targetDuration: targetDuration ?? this.targetDuration,
      hookText: clearHookText ? null : (hookText ?? this.hookText),
      status: status ?? this.status,
      hookScore: hookScore ?? this.hookScore,
      viralScore: viralScore ?? this.viralScore,
      category: category ?? this.category,
      sourceTimestamp: sourceTimestamp ?? this.sourceTimestamp,
      editingStyle: editingStyle ?? this.editingStyle,
      estimatedRetention: estimatedRetention ?? this.estimatedRetention,
      versions: versions ?? this.versions,
      captions: captions ?? this.captions,
      commentaryText:
          clearCommentaryText ? null : (commentaryText ?? this.commentaryText),
      audioConfig: audioConfig ?? this.audioConfig,
      thumbnailUrl:
          clearThumbnailUrl ? null : (thumbnailUrl ?? this.thumbnailUrl),
    );
  }

  /// Number of versions generated.
  int get versionCount => versions.length;

  /// The latest version.
  ShortVersion? get latestVersion =>
      versions.isEmpty ? null : versions.last;

  /// The best-scoring version.
  ShortVersion? get bestVersion {
    if (versions.isEmpty) return null;
    return versions.where((v) => v.score != null).toList()
      ..sort((a, b) => b.score!.compareTo(a.score!));
  }

  /// Duration formatted as mm:ss.
  String get durationFormatted {
    final minutes = duration ~/ 60;
    final seconds = (duration % 60).toInt();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  String toString() =>
      'ShortVideo(id: $id, title: $title, status: ${status.name}, viralScore: ${viralScore.toStringAsFixed(2)})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShortVideo &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
