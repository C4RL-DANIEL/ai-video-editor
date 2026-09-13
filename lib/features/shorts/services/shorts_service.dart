import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';

/// Represents a generated short-form video clip.
class Short {
  const Short({
    required this.id,
    required this.projectId,
    required this.title,
    required this.status,
    this.description,
    this.duration,
    this.outputUrl,
    this.thumbnailUrl,
    this.createdAt,
    this.hooks,
    this.metadata,
  });

  factory Short.fromJson(Map<String, dynamic> json) {
    return Short(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      title: json['title'] as String,
      status: ShortStatus.fromString(json['status'] as String? ?? 'pending'),
      description: json['description'] as String?,
      duration: (json['duration'] as num?)?.toDouble(),
      outputUrl: json['outputUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      hooks: (json['hooks'] as List<dynamic>?)
          ?.map((e) => Hook.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  final String id;
  final String projectId;
  final String title;
  final ShortStatus status;
  final String? description;
  final double? duration;
  final String? outputUrl;
  final String? thumbnailUrl;
  final DateTime? createdAt;
  final List<Hook>? hooks;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'title': title,
        'status': status.value,
        'description': description,
        'duration': duration,
        'outputUrl': outputUrl,
        'thumbnailUrl': thumbnailUrl,
        'createdAt': createdAt?.toIso8601String(),
        'metadata': metadata,
      };
}

enum ShortStatus {
  pending('pending'),
  generating('generating'),
  ready('ready'),
  rendering('rendering'),
  completed('completed'),
  failed('failed');

  const ShortStatus(this.value);

  final String value;

  factory ShortStatus.fromString(String value) {
    return ShortStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ShortStatus.pending,
    );
  }
}

/// A hook (opening clip) suggestion for a short.
class Hook {
  const Hook({
    required this.id,
    required this.text,
    required this.score,
    this.startOffset,
    this.duration,
  });

  factory Hook.fromJson(Map<String, dynamic> json) {
    return Hook(
      id: json['id'] as String,
      text: json['text'] as String,
      score: (json['score'] as num).toDouble(),
      startOffset: (json['startOffset'] as num?)?.toDouble(),
      duration: (json['duration'] as num?)?.toDouble(),
    );
  }

  final String id;
  final String text;
  final double score;
  final double? startOffset;
  final double? duration;
}

/// Service layer for short-form video operations.
class ShortsService {
  ShortsService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  /// Fetches all shorts for a project.
  Future<ApiResponse<List<Short>>> getShorts(String projectId) async {
    return _api.get<List<Short>>(
      '/projects/$projectId/shorts',
      fromJson: (data) {
        final list = data as List<dynamic>;
        return list.map((e) => Short.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }

  /// Fetches a single short by [shortId].
  Future<ApiResponse<Short>> getShort(String shortId) async {
    return _api.get<Short>(
      '/shorts/$shortId',
      fromJson: (data) => Short.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Triggers generation of new shorts from selected viral [momentIds].
  Future<ApiResponse<List<Short>>> generateShorts(
    String projectId,
    List<String> momentIds,
  ) async {
    return _api.post<List<Short>>(
      '/projects/$projectId/shorts/generate',
      data: {'momentIds': momentIds},
      fromJson: (data) {
        final list = data as List<dynamic>;
        return list.map((e) => Short.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }

  /// Requests regeneration of a single short.
  Future<ApiResponse<Short>> regenerateShort(String shortId) async {
    return _api.post<Short>(
      '/shorts/$shortId/regenerate',
      fromJson: (data) => Short.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Updates a short's editable properties (title, description, hooks, etc.).
  Future<ApiResponse<Short>> updateShort(
    String shortId,
    Map<String, dynamic> data,
  ) async {
    return _api.patch<Short>(
      '/shorts/$shortId',
      data: data,
      fromJson: (data) => Short.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Generates hook suggestions for a specific viral [momentId].
  Future<ApiResponse<List<Hook>>> generateHooks(String momentId) async {
    return _api.post<List<Hook>>(
      '/moments/$momentId/hooks',
      fromJson: (data) {
        final list = data as List<dynamic>;
        return list.map((e) => Hook.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }

  /// Generates a low-res preview of the short.
  Future<ApiResponse<Map<String, dynamic>>> previewShort(String shortId) async {
    return _api.post<Map<String, dynamic>>(
      '/shorts/$shortId/preview',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
}
