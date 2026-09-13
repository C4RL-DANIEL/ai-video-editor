import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';

/// Represents the current status of an analysis job.
enum AnalysisStatus {
  pending('pending'),
  processing('processing'),
  completed('completed'),
  failed('failed');

  const AnalysisStatus(this.value);

  final String value;

  factory AnalysisStatus.fromString(String value) {
    return AnalysisStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AnalysisStatus.pending,
    );
  }
}

/// A viral moment detected by the AI.
class ViralMoment {
  const ViralMoment({
    required this.id,
    required this.projectId,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.score,
    this.description,
    this.tags,
  });

  factory ViralMoment.fromJson(Map<String, dynamic> json) {
    return ViralMoment(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      title: json['title'] as String,
      startTime: (json['startTime'] as num).toDouble(),
      endTime: (json['endTime'] as num).toDouble(),
      score: (json['score'] as num).toDouble(),
      description: json['description'] as String?,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  final String id;
  final String projectId;
  final String title;
  final double startTime;
  final double endTime;
  final double score;
  final String? description;
  final List<String>? tags;
}

/// Transcript segment.
class TranscriptSegment {
  const TranscriptSegment({
    required this.text,
    required this.startTime,
    required this.endTime,
    this.speaker,
    this.confidence,
  });

  factory TranscriptSegment.fromJson(Map<String, dynamic> json) {
    return TranscriptSegment(
      text: json['text'] as String,
      startTime: (json['startTime'] as num).toDouble(),
      endTime: (json['endTime'] as num).toDouble(),
      speaker: json['speaker'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }

  final String text;
  final double startTime;
  final double endTime;
  final String? speaker;
  final double? confidence;
}

/// Content map describing the structure of a long-form video.
class ContentMap {
  const ContentMap({
    required this.sections,
    required this.topics,
    this.sentimentTimeline,
  });

  factory ContentMap.fromJson(Map<String, dynamic> json) {
    return ContentMap(
      sections: (json['sections'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      topics: (json['topics'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      sentimentTimeline: json['sentimentTimeline'] as List<dynamic>?,
    );
  }

  final List<Map<String, dynamic>> sections;
  final List<String> topics;
  final List<dynamic>? sentimentTimeline;
}

/// Service layer for video analysis operations.
class AnalysisService {
  AnalysisService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  /// Starts a new analysis job for [projectId].
  Future<ApiResponse<Map<String, dynamic>>> startAnalysis(
    String projectId,
  ) async {
    return _api.post<Map<String, dynamic>>(
      '/projects/$projectId/analysis/start',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// Polls the current status of the analysis for [projectId].
  Future<ApiResponse<Map<String, dynamic>>> getAnalysisStatus(
    String projectId,
  ) async {
    return _api.get<Map<String, dynamic>>(
      '/projects/$projectId/analysis/status',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// Fetches the full analysis result once it is completed.
  Future<ApiResponse<Map<String, dynamic>>> getAnalysisResult(
    String projectId,
  ) async {
    return _api.get<Map<String, dynamic>>(
      '/projects/$projectId/analysis/result',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// Retrieves viral moments detected during analysis.
  Future<ApiResponse<List<ViralMoment>>> getViralMoments(
    String projectId,
  ) async {
    return _api.get<List<ViralMoment>>(
      '/projects/$projectId/viral-moments',
      fromJson: (data) {
        final list = data as List<dynamic>;
        return list
            .map((e) => ViralMoment.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Retrieves the auto-generated transcript.
  Future<ApiResponse<List<TranscriptSegment>>> getTranscript(
    String projectId,
  ) async {
    return _api.get<List<TranscriptSegment>>(
      '/projects/$projectId/transcript',
      fromJson: (data) {
        final list = data as List<dynamic>;
        return list
            .map((e) => TranscriptSegment.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Retrieves the content map.
  Future<ApiResponse<ContentMap>> getContentMap(String projectId) async {
    return _api.get<ContentMap>(
      '/projects/$projectId/content-map',
      fromJson: (data) => ContentMap.fromJson(data as Map<String, dynamic>),
    );
  }
}
