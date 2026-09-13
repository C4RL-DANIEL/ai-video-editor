import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';

/// Represents the full timeline state for a short-form video.
class Timeline {
  const Timeline({
    required this.shortId,
    required this.tracks,
    required this.duration,
    this.version,
  });

  factory Timeline.fromJson(Map<String, dynamic> json) {
    return Timeline(
      shortId: json['shortId'] as String,
      tracks: (json['tracks'] as List<dynamic>)
          .map((e) => Track.fromJson(e as Map<String, dynamic>))
          .toList(),
      duration: (json['duration'] as num).toDouble(),
      version: json['version'] as int?,
    );
  }

  final String shortId;
  final List<Track> tracks;
  final double duration;
  final int? version;

  Map<String, dynamic> toJson() => {
        'shortId': shortId,
        'tracks': tracks.map((t) => t.toJson()).toList(),
        'duration': duration,
        'version': version,
      };
}

/// A single track (video, audio, text overlay, etc.).
class Track {
  const Track({
    required this.id,
    required this.type,
    required this.clips,
    this.muted = false,
    this.opacity = 1.0,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] as String,
      type: TrackType.fromString(json['type'] as String? ?? 'video'),
      clips: (json['clips'] as List<dynamic>)
          .map((e) => Clip.fromJson(e as Map<String, dynamic>))
          .toList(),
      muted: json['muted'] as bool? ?? false,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
    );
  }

  final String id;
  final TrackType type;
  final List<Clip> clips;
  final bool muted;
  final double opacity;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.value,
        'clips': clips.map((c) => c.toJson()).toList(),
        'muted': muted,
        'opacity': opacity,
      };
}

enum TrackType {
  video('video'),
  audio('audio'),
  text('text'),
  overlay('overlay');

  const TrackType(this.value);

  final String value;

  factory TrackType.fromString(String value) {
    return TrackType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TrackType.video,
    );
  }
}

/// A single clip on a track.
class Clip {
  const Clip({
    required this.id,
    required this.sourceId,
    required this.start,
    required this.end,
    this.trimStart,
    this.trimEnd,
    this.position,
    this.scale,
    this.rotation,
    this.properties,
  });

  factory Clip.fromJson(Map<String, dynamic> json) {
    return Clip(
      id: json['id'] as String,
      sourceId: json['sourceId'] as String,
      start: (json['start'] as num).toDouble(),
      end: (json['end'] as num).toDouble(),
      trimStart: (json['trimStart'] as num?)?.toDouble(),
      trimEnd: (json['trimEnd'] as num?)?.toDouble(),
      position: json['position'] as Map<String, dynamic>?,
      scale: (json['scale'] as num?)?.toDouble(),
      rotation: (json['rotation'] as num?)?.toDouble(),
      properties: json['properties'] as Map<String, dynamic>?,
    );
  }

  final String id;
  final String sourceId;
  final double start;
  final double end;
  final double? trimStart;
  final double? trimEnd;
  final Map<String, dynamic>? position;
  final double? scale;
  final double? rotation;
  final Map<String, dynamic>? properties;

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceId': sourceId,
        'start': start,
        'end': end,
        'trimStart': trimStart,
        'trimEnd': trimEnd,
        'position': position,
        'scale': scale,
        'rotation': rotation,
        'properties': properties,
      };
}

/// Describes an edit decision (undo/redo entry).
class EditDecision {
  const EditDecision({
    required this.id,
    required this.type,
    required this.payload,
    required this.timestamp,
  });

  factory EditDecision.fromJson(Map<String, dynamic> json) {
    return EditDecision(
      id: json['id'] as String,
      type: json['type'] as String,
      payload: json['payload'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  final String id;
  final String type;
  final Map<String, dynamic> payload;
  final DateTime timestamp;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'payload': payload,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Service layer for timeline editing operations.
class EditorService {
  EditorService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  /// Fetches the current timeline for a short.
  Future<ApiResponse<Timeline>> getTimeline(String shortId) async {
    return _api.get<Timeline>(
      '/shorts/$shortId/timeline',
      fromJson: (data) => Timeline.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Replaces the entire timeline for a short.
  Future<ApiResponse<Timeline>> updateTimeline(
    String shortId,
    Timeline timeline,
  ) async {
    return _api.put<Timeline>(
      '/shorts/$shortId/timeline',
      data: timeline.toJson(),
      fromJson: (data) => Timeline.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Applies a single edit decision (e.g. trim, split, add effect).
  Future<ApiResponse<Timeline>> applyEditDecision(
    String shortId,
    EditDecision decision,
  ) async {
    return _api.post<Timeline>(
      '/shorts/$shortId/timeline/apply',
      data: decision.toJson(),
      fromJson: (data) => Timeline.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Requests a low-res preview render.
  Future<ApiResponse<Map<String, dynamic>>> renderPreview(String shortId) async {
    return _api.post<Map<String, dynamic>>(
      '/shorts/$shortId/render/preview',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// Requests the final high-res render.
  Future<ApiResponse<Map<String, dynamic>>> renderFinal(String shortId) async {
    return _api.post<Map<String, dynamic>>(
      '/shorts/$shortId/render/final',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// Undoes an edit decision.
  Future<ApiResponse<Timeline>> undo(
    String shortId,
    String decisionId,
  ) async {
    return _api.post<Timeline>(
      '/shorts/$shortId/timeline/undo',
      data: {'decisionId': decisionId},
      fromJson: (data) => Timeline.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Redoes a previously undone edit decision.
  Future<ApiResponse<Timeline>> redo(
    String shortId,
    String decisionId,
  ) async {
    return _api.post<Timeline>(
      '/shorts/$shortId/timeline/redo',
      data: {'decisionId': decisionId},
      fromJson: (data) => Timeline.fromJson(data as Map<String, dynamic>),
    );
  }
}
