/// Edit decision models for the AI Video Editor app.
///
/// Models representing edit decisions, timeline tracks, and clips
/// used in the video editing pipeline.

/// The type of edit decision.
enum EditDecisionType {
  cut,
  zoom,
  overlay,
  speed,
  caption,
  sfx,
  transition,
  effect;

  factory EditDecisionType.fromString(String value) {
    return EditDecisionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EditDecisionType.cut,
    );
  }

  String toJson() => name;
}

/// Typed parameters for different edit types.
class EditParams {
  /// Cut: trim points
  final double? trimStart;
  final double? trimEnd;

  /// Zoom: zoom level and position
  final double? zoomLevel;
  final double? zoomX;
  final double? zoomY;

  /// Overlay: position, size, opacity
  final String? overlayType;
  final String? overlayUrl;
  final double? overlayX;
  final double? overlayY;
  final double? overlayWidth;
  final double? overlayHeight;
  final double? overlayOpacity;

  /// Speed: playback speed
  final double? speedMultiplier;

  /// Caption: text and formatting
  final String? captionText;
  final String? captionFont;
  final double? captionFontSize;
  final String? captionColor;

  /// SFX: sound effect properties
  final String? sfxType;
  final String? sfxUrl;
  final double? sfxVolume;

  /// Transition: type and duration
  final String? transitionType;
  final double? transitionDuration;

  /// Effect: generic key-value parameters
  final Map<String, dynamic>? effectParams;

  const EditParams({
    this.trimStart,
    this.trimEnd,
    this.zoomLevel,
    this.zoomX,
    this.zoomY,
    this.overlayType,
    this.overlayUrl,
    this.overlayX,
    this.overlayY,
    this.overlayWidth,
    this.overlayHeight,
    this.overlayOpacity,
    this.speedMultiplier,
    this.captionText,
    this.captionFont,
    this.captionFontSize,
    this.captionColor,
    this.sfxType,
    this.sfxUrl,
    this.sfxVolume,
    this.transitionType,
    this.transitionDuration,
    this.effectParams,
  });

  factory EditParams.fromJson(Map<String, dynamic> json) {
    return EditParams(
      trimStart: (json['trimStart'] as num?)?.toDouble(),
      trimEnd: (json['trimEnd'] as num?)?.toDouble(),
      zoomLevel: (json['zoomLevel'] as num?)?.toDouble(),
      zoomX: (json['zoomX'] as num?)?.toDouble(),
      zoomY: (json['zoomY'] as num?)?.toDouble(),
      overlayType: json['overlayType'] as String?,
      overlayUrl: json['overlayUrl'] as String?,
      overlayX: (json['overlayX'] as num?)?.toDouble(),
      overlayY: (json['overlayY'] as num?)?.toDouble(),
      overlayWidth: (json['overlayWidth'] as num?)?.toDouble(),
      overlayHeight: (json['overlayHeight'] as num?)?.toDouble(),
      overlayOpacity: (json['overlayOpacity'] as num?)?.toDouble(),
      speedMultiplier: (json['speedMultiplier'] as num?)?.toDouble(),
      captionText: json['captionText'] as String?,
      captionFont: json['captionFont'] as String?,
      captionFontSize: (json['captionFontSize'] as num?)?.toDouble(),
      captionColor: json['captionColor'] as String?,
      sfxType: json['sfxType'] as String?,
      sfxUrl: json['sfxUrl'] as String?,
      sfxVolume: (json['sfxVolume'] as num?)?.toDouble(),
      transitionType: json['transitionType'] as String?,
      transitionDuration: (json['transitionDuration'] as num?)?.toDouble(),
      effectParams: json['effectParams'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (trimStart != null) 'trimStart': trimStart,
      if (trimEnd != null) 'trimEnd': trimEnd,
      if (zoomLevel != null) 'zoomLevel': zoomLevel,
      if (zoomX != null) 'zoomX': zoomX,
      if (zoomY != null) 'zoomY': zoomY,
      if (overlayType != null) 'overlayType': overlayType,
      if (overlayUrl != null) 'overlayUrl': overlayUrl,
      if (overlayX != null) 'overlayX': overlayX,
      if (overlayY != null) 'overlayY': overlayY,
      if (overlayWidth != null) 'overlayWidth': overlayWidth,
      if (overlayHeight != null) 'overlayHeight': overlayHeight,
      if (overlayOpacity != null) 'overlayOpacity': overlayOpacity,
      if (speedMultiplier != null) 'speedMultiplier': speedMultiplier,
      if (captionText != null) 'captionText': captionText,
      if (captionFont != null) 'captionFont': captionFont,
      if (captionFontSize != null) 'captionFontSize': captionFontSize,
      if (captionColor != null) 'captionColor': captionColor,
      if (sfxType != null) 'sfxType': sfxType,
      if (sfxUrl != null) 'sfxUrl': sfxUrl,
      if (sfxVolume != null) 'sfxVolume': sfxVolume,
      if (transitionType != null) 'transitionType': transitionType,
      if (transitionDuration != null) 'transitionDuration': transitionDuration,
      if (effectParams != null) 'effectParams': effectParams,
    };
  }

  EditParams copyWith({
    double? trimStart,
    double? trimEnd,
    double? zoomLevel,
    double? zoomX,
    double? zoomY,
    String? overlayType,
    String? overlayUrl,
    double? overlayX,
    double? overlayY,
    double? overlayWidth,
    double? overlayHeight,
    double? overlayOpacity,
    double? speedMultiplier,
    String? captionText,
    String? captionFont,
    double? captionFontSize,
    String? captionColor,
    String? sfxType,
    String? sfxUrl,
    double? sfxVolume,
    String? transitionType,
    double? transitionDuration,
    Map<String, dynamic>? effectParams,
    bool clearTrimStart = false,
    bool clearTrimEnd = false,
    bool clearZoomLevel = false,
    bool clearOverlayUrl = false,
    bool clearCaptionText = false,
    bool clearSfxUrl = false,
    bool clearTransitionType = false,
    bool clearTransitionDuration = false,
    bool clearEffectParams = false,
  }) {
    return EditParams(
      trimStart: clearTrimStart ? null : (trimStart ?? this.trimStart),
      trimEnd: clearTrimEnd ? null : (trimEnd ?? this.trimEnd),
      zoomLevel: clearZoomLevel ? null : (zoomLevel ?? this.zoomLevel),
      zoomX: zoomX ?? this.zoomX,
      zoomY: zoomY ?? this.zoomY,
      overlayType: overlayType ?? this.overlayType,
      overlayUrl: clearOverlayUrl ? null : (overlayUrl ?? this.overlayUrl),
      overlayX: overlayX ?? this.overlayX,
      overlayY: overlayY ?? this.overlayY,
      overlayWidth: overlayWidth ?? this.overlayWidth,
      overlayHeight: overlayHeight ?? this.overlayHeight,
      overlayOpacity: overlayOpacity ?? this.overlayOpacity,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      captionText: clearCaptionText ? null : (captionText ?? this.captionText),
      captionFont: captionFont ?? this.captionFont,
      captionFontSize: captionFontSize ?? this.captionFontSize,
      captionColor: captionColor ?? this.captionColor,
      sfxType: sfxType ?? this.sfxType,
      sfxUrl: clearSfxUrl ? null : (sfxUrl ?? this.sfxUrl),
      sfxVolume: sfxVolume ?? this.sfxVolume,
      transitionType:
          clearTransitionType ? null : (transitionType ?? this.transitionType),
      transitionDuration: clearTransitionDuration
          ? null
          : (transitionDuration ?? this.transitionDuration),
      effectParams:
          clearEffectParams ? null : (effectParams ?? this.effectParams),
    );
  }

  @override
  String toString() => 'EditParams(${toJson()})';
}

/// An edit decision to be applied to the video.
class EditDecision {
  final String id;
  final EditDecisionType type;
  final double startTime;
  final double endTime;
  final EditParams params;
  final double confidence;
  final String reasoning;

  const EditDecision({
    required this.id,
    required this.type,
    required this.startTime,
    required this.endTime,
    this.params = const EditParams(),
    this.confidence = 1.0,
    this.reasoning = '',
  });

  /// Creates an EditDecision from JSON.
  factory EditDecision.fromJson(Map<String, dynamic> json) {
    return EditDecision(
      id: json['id'] as String? ?? '',
      type: json['type'] != null
          ? EditDecisionType.fromString(json['type'] as String)
          : EditDecisionType.cut,
      startTime: (json['startTime'] as num?)?.toDouble() ?? 0.0,
      endTime: (json['endTime'] as num?)?.toDouble() ?? 0.0,
      params: json['params'] != null
          ? EditParams.fromJson(json['params'] as Map<String, dynamic>)
          : const EditParams(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      reasoning: json['reasoning'] as String? ?? '',
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toJson(),
      'startTime': startTime,
      'endTime': endTime,
      'params': params.toJson(),
      'confidence': confidence,
      'reasoning': reasoning,
    };
  }

  /// Creates a copy with selective field updates.
  EditDecision copyWith({
    String? id,
    EditDecisionType? type,
    double? startTime,
    double? endTime,
    EditParams? params,
    double? confidence,
    String? reasoning,
  }) {
    return EditDecision(
      id: id ?? this.id,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      params: params ?? this.params,
      confidence: confidence ?? this.confidence,
      reasoning: reasoning ?? this.reasoning,
    );
  }

  /// Duration of this edit in seconds.
  double get duration => endTime - startTime;

  @override
  String toString() =>
      'EditDecision(id: $id, type: ${type.name}, ${startTime.toStringAsFixed(1)}-${endTime.toStringAsFixed(1)})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EditDecision &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// The type of a timeline track.
enum TrackType {
  video,
  audio,
  caption,
  overlay,
  effect;

  factory TrackType.fromString(String value) {
    return TrackType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TrackType.video,
    );
  }

  String toJson() => name;
}

/// A clip on the timeline representing a segment of source media.
class TimelineClip {
  final String id;
  final String trackId;
  final double sourceStartTime;
  final double sourceEndTime;
  final double timelineStartTime;
  final double timelineEndTime;
  final List<EditDecision> effects;
  final List<EditDecision> transitions;

  const TimelineClip({
    required this.id,
    required this.trackId,
    required this.sourceStartTime,
    required this.sourceEndTime,
    required this.timelineStartTime,
    required this.timelineEndTime,
    this.effects = const [],
    this.transitions = const [],
  });

  /// Creates a TimelineClip from JSON.
  factory TimelineClip.fromJson(Map<String, dynamic> json) {
    return TimelineClip(
      id: json['id'] as String? ?? '',
      trackId: json['trackId'] as String? ?? '',
      sourceStartTime:
          (json['sourceStartTime'] as num?)?.toDouble() ?? 0.0,
      sourceEndTime: (json['sourceEndTime'] as num?)?.toDouble() ?? 0.0,
      timelineStartTime:
          (json['timelineStartTime'] as num?)?.toDouble() ?? 0.0,
      timelineEndTime:
          (json['timelineEndTime'] as num?)?.toDouble() ?? 0.0,
      effects: (json['effects'] as List<dynamic>?)
              ?.map((e) =>
                  EditDecision.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      transitions: (json['transitions'] as List<dynamic>?)
              ?.map((t) =>
                  EditDecision.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trackId': trackId,
      'sourceStartTime': sourceStartTime,
      'sourceEndTime': sourceEndTime,
      'timelineStartTime': timelineStartTime,
      'timelineEndTime': timelineEndTime,
      'effects': effects.map((e) => e.toJson()).toList(),
      'transitions': transitions.map((t) => t.toJson()).toList(),
    };
  }

  /// Creates a copy with selective field updates.
  TimelineClip copyWith({
    String? id,
    String? trackId,
    double? sourceStartTime,
    double? sourceEndTime,
    double? timelineStartTime,
    double? timelineEndTime,
    List<EditDecision>? effects,
    List<EditDecision>? transitions,
  }) {
    return TimelineClip(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      sourceStartTime: sourceStartTime ?? this.sourceStartTime,
      sourceEndTime: sourceEndTime ?? this.sourceEndTime,
      timelineStartTime: timelineStartTime ?? this.timelineStartTime,
      timelineEndTime: timelineEndTime ?? this.timelineEndTime,
      effects: effects ?? this.effects,
      transitions: transitions ?? this.transitions,
    );
  }

  /// Duration of this clip on the timeline in seconds.
  double get timelineDuration => timelineEndTime - timelineStartTime;

  /// Duration of the source segment in seconds.
  double get sourceDuration => sourceEndTime - sourceStartTime;

  /// Speed factor (timeline duration / source duration).
  double get speedFactor =>
      sourceDuration > 0 ? timelineDuration / sourceDuration : 1.0;

  @override
  String toString() =>
      'TimelineClip(id: $id, track: $trackId, timeline: ${timelineStartTime.toStringAsFixed(1)}-${timelineEndTime.toStringAsFixed(1)})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimelineClip &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// A track on the editing timeline.
class TimelineTrack {
  final String id;
  final String name;
  final TrackType type;
  final List<TimelineClip> clips;

  const TimelineTrack({
    required this.id,
    required this.name,
    required this.type,
    this.clips = const [],
  });

  /// Creates a TimelineTrack from JSON.
  factory TimelineTrack.fromJson(Map<String, dynamic> json) {
    return TimelineTrack(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] != null
          ? TrackType.fromString(json['type'] as String)
          : TrackType.video,
      clips: (json['clips'] as List<dynamic>?)
              ?.map((c) =>
                  TimelineClip.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toJson(),
      'clips': clips.map((c) => c.toJson()).toList(),
    };
  }

  /// Creates a copy with selective field updates.
  TimelineTrack copyWith({
    String? id,
    String? name,
    TrackType? type,
    List<TimelineClip>? clips,
  }) {
    return TimelineTrack(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      clips: clips ?? this.clips,
    );
  }

  /// Number of clips on this track.
  int get clipCount => clips.length;

  /// Total duration of all clips on this track.
  double get totalDuration {
    if (clips.isEmpty) return 0.0;
    final last = clips.last;
    return last.timelineEndTime - clips.first.timelineStartTime;
  }

  /// Start time of the first clip.
  double get startTime =>
      clips.isEmpty ? 0.0 : clips.first.timelineStartTime;

  /// End time of the last clip.
  double get endTime =>
      clips.isEmpty ? 0.0 : clips.last.timelineEndTime;

  @override
  String toString() =>
      'TimelineTrack(id: $id, name: $name, type: ${type.name}, clips: $clipCount)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimelineTrack &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
