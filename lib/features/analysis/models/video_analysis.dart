/// Video analysis models for the AI Video Editor app.
///
/// Comprehensive models representing AI analysis of video content including
/// scenes, speakers, audio analysis, semantic analysis, and content maps.

import 'transcript.dart';

/// The type of a detected scene.
enum SceneType {
  talking,
  broll,
  transition,
  titleCard,
  intro,
  outro,
  action,
  montage,
  interview,
  demonstration,
  other;

  factory SceneType.fromString(String value) {
    return SceneType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SceneType.other,
    );
  }

  String toJson() => name;
}

/// A detected scene within the video.
class Scene {
  final String id;
  final double startTime;
  final double endTime;
  final String description;
  final SceneType type;
  final double confidence;

  const Scene({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.type,
    this.confidence = 1.0,
  });

  factory Scene.fromJson(Map<String, dynamic> json) {
    return Scene(
      id: json['id'] as String? ?? '',
      startTime: (json['startTime'] as num?)?.toDouble() ?? 0.0,
      endTime: (json['endTime'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      type: json['type'] != null
          ? SceneType.fromString(json['type'] as String)
          : SceneType.other,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime,
      'endTime': endTime,
      'description': description,
      'type': type.toJson(),
      'confidence': confidence,
    };
  }

  Scene copyWith({
    String? id,
    double? startTime,
    double? endTime,
    String? description,
    SceneType? type,
    double? confidence,
  }) {
    return Scene(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      description: description ?? this.description,
      type: type ?? this.type,
      confidence: confidence ?? this.confidence,
    );
  }

  /// Duration of this scene in seconds.
  double get duration => endTime - startTime;

  @override
  String toString() =>
      'Scene(id: $id, type: $type, ${startTime.toStringAsFixed(1)}-${endTime.toStringAsFixed(1)})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Scene && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// A time segment associated with a speaker.
class SpeakerSegment {
  final double startTime;
  final double endTime;

  const SpeakerSegment({
    required this.startTime,
    required this.endTime,
  });

  factory SpeakerSegment.fromJson(Map<String, dynamic> json) {
    return SpeakerSegment(
      startTime: (json['startTime'] as num?)?.toDouble() ?? 0.0,
      endTime: (json['endTime'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  double get duration => endTime - startTime;

  /// Whether this segment overlaps with another time range.
  bool overlaps(double start, double end) {
    return startTime < end && endTime > start;
  }

  @override
  String toString() =>
      'SpeakerSegment(${startTime.toStringAsFixed(1)}-${endTime.toStringAsFixed(1)})';
}

/// A detected speaker in the video.
class Speaker {
  final String id;
  final String name;
  final List<SpeakerSegment> segments;
  final String? faceUrl;

  const Speaker({
    required this.id,
    required this.name,
    this.segments = const [],
    this.faceUrl,
  });

  factory Speaker.fromJson(Map<String, dynamic> json) {
    return Speaker(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Speaker',
      segments: (json['segments'] as List<dynamic>?)
              ?.map(
                  (s) => SpeakerSegment.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      faceUrl: json['faceUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'segments': segments.map((s) => s.toJson()).toList(),
      'faceUrl': faceUrl,
    };
  }

  Speaker copyWith({
    String? id,
    String? name,
    List<SpeakerSegment>? segments,
    String? faceUrl,
    bool clearFaceUrl = false,
  }) {
    return Speaker(
      id: id ?? this.id,
      name: name ?? this.name,
      segments: segments ?? this.segments,
      faceUrl: clearFaceUrl ? null : (faceUrl ?? this.faceUrl),
    );
  }

  /// Total speaking time in seconds.
  double get totalSpeakingTime =>
      segments.fold(0.0, (sum, seg) => sum + seg.duration);

  @override
  String toString() => 'Speaker(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Speaker && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Audio analysis results.
class AudioAnalysis {
  final bool musicPresence;
  final bool sfxPresence;
  final bool speechPresence;
  final List<double> volumeProfile; // volume levels at regular intervals
  final double noiseLevel; // 0.0 to 1.0

  const AudioAnalysis({
    this.musicPresence = false,
    this.sfxPresence = false,
    this.speechPresence = false,
    this.volumeProfile = const [],
    this.noiseLevel = 0.0,
  });

  factory AudioAnalysis.fromJson(Map<String, dynamic> json) {
    return AudioAnalysis(
      musicPresence: json['musicPresence'] as bool? ?? false,
      sfxPresence: json['sfxPresence'] as bool? ?? false,
      speechPresence: json['speechPresence'] as bool? ?? false,
      volumeProfile: (json['volumeProfile'] as List<dynamic>?)
              ?.map((v) => (v as num).toDouble())
              .toList() ??
          [],
      noiseLevel: (json['noiseLevel'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'musicPresence': musicPresence,
      'sfxPresence': sfxPresence,
      'speechPresence': speechPresence,
      'volumeProfile': volumeProfile,
      'noiseLevel': noiseLevel,
    };
  }

  AudioAnalysis copyWith({
    bool? musicPresence,
    bool? sfxPresence,
    bool? speechPresence,
    List<double>? volumeProfile,
    double? noiseLevel,
  }) {
    return AudioAnalysis(
      musicPresence: musicPresence ?? this.musicPresence,
      sfxPresence: sfxPresence ?? this.sfxPresence,
      speechPresence: speechPresence ?? this.speechPresence,
      volumeProfile: volumeProfile ?? this.volumeProfile,
      noiseLevel: noiseLevel ?? this.noiseLevel,
    );
  }

  /// Average volume across the profile.
  double get averageVolume {
    if (volumeProfile.isEmpty) return 0.0;
    return volumeProfile.reduce((a, b) => a + b) / volumeProfile.length;
  }

  /// Peak volume across the profile.
  double get peakVolume {
    if (volumeProfile.isEmpty) return 0.0;
    return volumeProfile.reduce((a, b) => a > b ? a : b);
  }

  @override
  String toString() =>
      'AudioAnalysis(music: $musicPresence, speech: $speechPresence, noise: ${noiseLevel.toStringAsFixed(2)})';
}

/// A keyword extracted from the video.
class Keyword {
  final String text;
  final double weight; // importance weight, 0.0 to 1.0

  const Keyword({
    required this.text,
    this.weight = 1.0,
  });

  factory Keyword.fromJson(Map<String, dynamic> json) {
    return Keyword(
      text: json['text'] as String? ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'weight': weight,
    };
  }

  @override
  String toString() => 'Keyword("$text", weight: $weight)';
}

/// A question detected in the video content.
class ContentQuestion {
  final String text;
  final double timestamp;
  final String? context;

  const ContentQuestion({
    required this.text,
    required this.timestamp,
    this.context,
  });

  factory ContentQuestion.fromJson(Map<String, dynamic> json) {
    return ContentQuestion(
      text: json['text'] as String? ?? '',
      timestamp: (json['timestamp'] as num?)?.toDouble() ?? 0.0,
      context: json['context'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'timestamp': timestamp,
      'context': context,
    };
  }

  ContentQuestion copyWith({
    String? text,
    double? timestamp,
    String? context,
    bool clearContext = false,
  }) {
    return ContentQuestion(
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      context: clearContext ? null : (context ?? this.context),
    );
  }

  @override
  String toString() => 'ContentQuestion("$text")';
}

/// A punchline or memorable quote detected in the video.
class Punchline {
  final String text;
  final double timestamp;
  final double impactScore; // 0.0 to 1.0

  const Punchline({
    required this.text,
    required this.timestamp,
    this.impactScore = 0.5,
  });

  factory Punchline.fromJson(Map<String, dynamic> json) {
    return Punchline(
      text: json['text'] as String? ?? '',
      timestamp: (json['timestamp'] as num?)?.toDouble() ?? 0.0,
      impactScore: (json['impactScore'] as num?)?.toDouble() ?? 0.5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'timestamp': timestamp,
      'impactScore': impactScore,
    };
  }

  @override
  String toString() =>
      'Punchline("$text", impact: ${impactScore.toStringAsFixed(2)})';
}

/// A claim or assertion detected in the video.
class ContentClaim {
  final String text;
  final double timestamp;
  final double confidence; // how certain the AI is about this being a claim

  const ContentClaim({
    required this.text,
    required this.timestamp,
    this.confidence = 0.5,
  });

  factory ContentClaim.fromJson(Map<String, dynamic> json) {
    return ContentClaim(
      text: json['text'] as String? ?? '',
      timestamp: (json['timestamp'] as num?)?.toDouble() ?? 0.0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'timestamp': timestamp,
      'confidence': confidence,
    };
  }

  @override
  String toString() =>
      'ContentClaim("$text", confidence: ${confidence.toStringAsFixed(2)})';
}

/// A story beat in the narrative structure.
enum StoryBeatType {
  setup,
  escalation,
  climax,
  payoff,
  resolution;

  factory StoryBeatType.fromString(String value) {
    return StoryBeatType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => StoryBeatType.setup,
    );
  }

  String toJson() => name;
}

/// A story beat detected in the video's narrative.
class StoryBeat {
  final StoryBeatType type;
  final double timestamp;
  final String description;
  final double importance; // 0.0 to 1.0

  const StoryBeat({
    required this.type,
    required this.timestamp,
    required this.description,
    this.importance = 0.5,
  });

  factory StoryBeat.fromJson(Map<String, dynamic> json) {
    return StoryBeat(
      type: json['type'] != null
          ? StoryBeatType.fromString(json['type'] as String)
          : StoryBeatType.setup,
      timestamp: (json['timestamp'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      importance: (json['importance'] as num?)?.toDouble() ?? 0.5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toJson(),
      'timestamp': timestamp,
      'description': description,
      'importance': importance,
    };
  }

  StoryBeat copyWith({
    StoryBeatType? type,
    double? timestamp,
    String? description,
    double? importance,
  }) {
    return StoryBeat(
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
      importance: importance ?? this.importance,
    );
  }

  @override
  String toString() =>
      'StoryBeat(${type.name}, ${timestamp.toStringAsFixed(1)}s, importance: ${importance.toStringAsFixed(2)})';
}

/// Semantic analysis results including transcript, keywords, and narrative.
class SemanticAnalysis {
  final Transcript transcript;
  final List<Keyword> keywords;
  final List<ContentQuestion> questions;
  final List<Punchline> punchlines;
  final List<ContentClaim> claims;
  final List<StoryBeat> storyBeats;

  const SemanticAnalysis({
    this.transcript = const Transcript(),
    this.keywords = const [],
    this.questions = const [],
    this.punchlines = const [],
    this.claims = const [],
    this.storyBeats = const [],
  });

  factory SemanticAnalysis.fromJson(Map<String, dynamic> json) {
    return SemanticAnalysis(
      transcript: json['transcript'] != null
          ? Transcript.fromJson(json['transcript'] as Map<String, dynamic>)
          : const Transcript(),
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((k) => Keyword.fromJson(k as Map<String, dynamic>))
              .toList() ??
          [],
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) =>
                  ContentQuestion.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
      punchlines: (json['punchlines'] as List<dynamic>?)
              ?.map((p) => Punchline.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      claims: (json['claims'] as List<dynamic>?)
              ?.map((c) => ContentClaim.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      storyBeats: (json['storyBeats'] as List<dynamic>?)
              ?.map((s) => StoryBeat.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transcript': transcript.toJson(),
      'keywords': keywords.map((k) => k.toJson()).toList(),
      'questions': questions.map((q) => q.toJson()).toList(),
      'punchlines': punchlines.map((p) => p.toJson()).toList(),
      'claims': claims.map((c) => c.toJson()).toList(),
      'storyBeats': storyBeats.map((s) => s.toJson()).toList(),
    };
  }

  SemanticAnalysis copyWith({
    Transcript? transcript,
    List<Keyword>? keywords,
    List<ContentQuestion>? questions,
    List<Punchline>? punchlines,
    List<ContentClaim>? claims,
    List<StoryBeat>? storyBeats,
  }) {
    return SemanticAnalysis(
      transcript: transcript ?? this.transcript,
      keywords: keywords ?? this.keywords,
      questions: questions ?? this.questions,
      punchlines: punchlines ?? this.punchlines,
      claims: claims ?? this.claims,
      storyBeats: storyBeats ?? this.storyBeats,
    );
  }

  @override
  String toString() =>
      'SemanticAnalysis(keywords: ${keywords.length}, questions: ${questions.length}, storyBeats: ${storyBeats.length})';
}

/// A moment in the content map.
class ContentMoment {
  final String id;
  final double startTime;
  final double endTime;
  final String description;
  final String? type;
  final double score; // 0.0 to 1.0

  const ContentMoment({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.description,
    this.type,
    this.score = 0.5,
  });

  factory ContentMoment.fromJson(Map<String, dynamic> json) {
    return ContentMoment(
      id: json['id'] as String? ?? '',
      startTime: (json['startTime'] as num?)?.toDouble() ?? 0.0,
      endTime: (json['endTime'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      type: json['type'] as String?,
      score: (json['score'] as num?)?.toDouble() ?? 0.5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime,
      'endTime': endTime,
      'description': description,
      'type': type,
      'score': score,
    };
  }

  ContentMoment copyWith({
    String? id,
    double? startTime,
    double? endTime,
    String? description,
    String? type,
    double? score,
    bool clearType = false,
  }) {
    return ContentMoment(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      description: description ?? this.description,
      type: clearType ? null : (type ?? this.type),
      score: score ?? this.score,
    );
  }

  double get duration => endTime - startTime;

  @override
  String toString() =>
      'ContentMoment(id: $id, ${startTime.toStringAsFixed(1)}-${endTime.toStringAsFixed(1)})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentMoment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// A timeline entry in the content map.
class TimelineEntry {
  final double timestamp;
  final String description;
  final String? eventType;

  const TimelineEntry({
    required this.timestamp,
    required this.description,
    this.eventType,
  });

  factory TimelineEntry.fromJson(Map<String, dynamic> json) {
    return TimelineEntry(
      timestamp: (json['timestamp'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      eventType: json['eventType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'description': description,
      'eventType': eventType,
    };
  }

  @override
  String toString() =>
      'TimelineEntry(${timestamp.toStringAsFixed(1)}s, $description)';
}

/// The content map providing a high-level overview of the video.
class ContentMap {
  final List<ContentMoment> moments;
  final List<TimelineEntry> timeline;

  const ContentMap({
    this.moments = const [],
    this.timeline = const [],
  });

  factory ContentMap.fromJson(Map<String, dynamic> json) {
    return ContentMap(
      moments: (json['moments'] as List<dynamic>?)
              ?.map((m) => ContentMoment.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      timeline: (json['timeline'] as List<dynamic>?)
              ?.map(
                  (t) => TimelineEntry.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moments': moments.map((m) => m.toJson()).toList(),
      'timeline': timeline.map((t) => t.toJson()).toList(),
    };
  }

  ContentMap copyWith({
    List<ContentMoment>? moments,
    List<TimelineEntry>? timeline,
  }) {
    return ContentMap(
      moments: moments ?? this.moments,
      timeline: timeline ?? this.timeline,
    );
  }

  @override
  String toString() =>
      'ContentMap(moments: ${moments.length}, timeline: ${timeline.length})';
}

/// The complete video analysis result.
class VideoAnalysis {
  final String id;
  final String projectId;
  final double duration;
  final List<Scene> scenes;
  final List<Speaker> speakers;
  final AudioAnalysis audioAnalysis;
  final SemanticAnalysis semanticAnalysis;
  final ContentMap contentMap;

  const VideoAnalysis({
    required this.id,
    required this.projectId,
    required this.duration,
    this.scenes = const [],
    this.speakers = const [],
    this.audioAnalysis = const AudioAnalysis(),
    this.semanticAnalysis = const SemanticAnalysis(),
    this.contentMap = const ContentMap(),
  });

  factory VideoAnalysis.fromJson(Map<String, dynamic> json) {
    return VideoAnalysis(
      id: json['id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
      scenes: (json['scenes'] as List<dynamic>?)
              ?.map((s) => Scene.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      speakers: (json['speakers'] as List<dynamic>?)
              ?.map((s) => Speaker.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      audioAnalysis: json['audioAnalysis'] != null
          ? AudioAnalysis.fromJson(
              json['audioAnalysis'] as Map<String, dynamic>)
          : const AudioAnalysis(),
      semanticAnalysis: json['semanticAnalysis'] != null
          ? SemanticAnalysis.fromJson(
              json['semanticAnalysis'] as Map<String, dynamic>)
          : const SemanticAnalysis(),
      contentMap: json['contentMap'] != null
          ? ContentMap.fromJson(json['contentMap'] as Map<String, dynamic>)
          : const ContentMap(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'duration': duration,
      'scenes': scenes.map((s) => s.toJson()).toList(),
      'speakers': speakers.map((s) => s.toJson()).toList(),
      'audioAnalysis': audioAnalysis.toJson(),
      'semanticAnalysis': semanticAnalysis.toJson(),
      'contentMap': contentMap.toJson(),
    };
  }

  VideoAnalysis copyWith({
    String? id,
    String? projectId,
    double? duration,
    List<Scene>? scenes,
    List<Speaker>? speakers,
    AudioAnalysis? audioAnalysis,
    SemanticAnalysis? semanticAnalysis,
    ContentMap? contentMap,
  }) {
    return VideoAnalysis(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      duration: duration ?? this.duration,
      scenes: scenes ?? this.scenes,
      speakers: speakers ?? this.speakers,
      audioAnalysis: audioAnalysis ?? this.audioAnalysis,
      semanticAnalysis: semanticAnalysis ?? this.semanticAnalysis,
      contentMap: contentMap ?? this.contentMap,
    );
  }

  /// Number of detected scenes.
  int get sceneCount => scenes.length;

  /// Number of detected speakers.
  int get speakerCount => speakers.length;

  @override
  String toString() =>
      'VideoAnalysis(id: $id, projectId: $projectId, scenes: $sceneCount, speakers: $speakerCount)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoAnalysis &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
