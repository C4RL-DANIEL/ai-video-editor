import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';

/// Represents a long-form (chapters) version of a project.
class LongForm {
  const LongForm({
    required this.id,
    required this.projectId,
    required this.title,
    required this.chapters,
    this.description,
    this.status,
    this.outputUrl,
    this.thumbnailUrl,
    this.createdAt,
    this.duration,
  });

  factory LongForm.fromJson(Map<String, dynamic> json) {
    return LongForm(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      title: json['title'] as String,
      chapters: (json['chapters'] as List<dynamic>)
          .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
          .toList(),
      description: json['description'] as String?,
      status: json['status'] as String?,
      outputUrl: json['outputUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      duration: (json['duration'] as num?)?.toDouble(),
    );
  }

  final String id;
  final String projectId;
  final String title;
  final List<Chapter> chapters;
  final String? description;
  final String? status;
  final String? outputUrl;
  final String? thumbnailUrl;
  final DateTime? createdAt;
  final double? duration;
}

/// A chapter within a long-form video.
class Chapter {
  const Chapter({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.description,
    this.order,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      title: json['title'] as String,
      startTime: (json['startTime'] as num).toDouble(),
      endTime: (json['endTime'] as num).toDouble(),
      description: json['description'] as String?,
      order: json['order'] as int?,
    );
  }

  final String id;
  final String title;
  final double startTime;
  final double endTime;
  final String? description;
  final int? order;
}

/// Parameters for long-form generation.
class LongFormParams {
  const LongFormParams({
    this.title,
    this.targetDuration,
    this.style,
    this.transitions,
    this.backgroundMusic,
    this.includeChapters = true,
  });

  final String? title;
  final double? targetDuration;
  final String? style;
  final String? transitions;
  final String? backgroundMusic;
  final bool includeChapters;

  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title,
        if (targetDuration != null) 'targetDuration': targetDuration,
        if (style != null) 'style': style,
        if (transitions != null) 'transitions': transitions,
        if (backgroundMusic != null) 'backgroundMusic': backgroundMusic,
        'includeChapters': includeChapters,
      };
}

/// Service layer for long-form video operations.
class LongFormService {
  LongFormService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  /// Fetches all long-form videos for a project.
  Future<ApiResponse<List<LongForm>>> getLongForms(String projectId) async {
    return _api.get<List<LongForm>>(
      '/projects/$projectId/longform',
      fromJson: (data) {
        final list = data as List<dynamic>;
        return list
            .map((e) => LongForm.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Fetches a single long-form by ID.
  Future<ApiResponse<LongForm>> getLongForm(String longFormId) async {
    return _api.get<LongForm>(
      '/longform/$longFormId',
      fromJson: (data) => LongForm.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Kicks off generation of a new long-form video from the project.
  Future<ApiResponse<LongForm>> generateLongForm(
    String projectId,
    LongFormParams params,
  ) async {
    return _api.post<LongForm>(
      '/projects/$projectId/longform/generate',
      data: params.toJson(),
      fromJson: (data) => LongForm.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Updates a specific chapter within a long-form video.
  Future<ApiResponse<Chapter>> updateChapter(
    String longFormId,
    String chapterId,
    Map<String, dynamic> data,
  ) async {
    return _api.patch<Chapter>(
      '/longform/$longFormId/chapters/$chapterId',
      data: data,
      fromJson: (data) => Chapter.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Requests the final render of a long-form video.
  Future<ApiResponse<Map<String, dynamic>>> renderLongForm(
    String longFormId,
  ) async {
    return _api.post<Map<String, dynamic>>(
      '/longform/$longFormId/render',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
}
