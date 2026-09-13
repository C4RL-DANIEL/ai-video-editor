/// AI Analysis Service for the AI Video Editor app.
///
/// Provides a unified interface for all AI-powered analysis pipelines including
/// transcription, scene detection, viral moment identification, commentary
/// generation, captioning, hook generation, self-critique, and auto-fix.

import 'package:flutter/foundation.dart';

import '../network/api_client.dart';
import '../network/api_response.dart';
import '../../features/analysis/models/transcript.dart';
import '../../features/analysis/models/video_analysis.dart';
import '../../features/analysis/models/viral_moment.dart';

// ---------------------------------------------------------------------------
// Additional models used by the analysis pipeline
// ---------------------------------------------------------------------------

/// A single caption entry with styling metadata.
class CaptionEntry {
  final String id;
  final double startTime;
  final double endTime;
  final String text;
  final String? speaker;
  final bool isKeywordHighlighted;
  final String? animationStyle;

  const CaptionEntry({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.text,
    this.speaker,
    this.isKeywordHighlighted = false,
    this.animationStyle,
  });

  factory CaptionEntry.fromJson(Map<String, dynamic> json) {
    return CaptionEntry(
      id: json['id'] as String? ?? '',
      startTime: (json['startTime'] as num?)?.toDouble() ?? 0.0,
      endTime: (json['endTime'] as num?)?.toDouble() ?? 0.0,
      text: json['text'] as String? ?? '',
      speaker: json['speaker'] as String?,
      isKeywordHighlighted: json['isKeywordHighlighted'] as bool? ?? false,
      animationStyle: json['animationStyle'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime,
      'endTime': endTime,
      'text': text,
      'speaker': speaker,
      'isKeywordHighlighted': isKeywordHighlighted,
      'animationStyle': animationStyle,
    };
  }

  CaptionEntry copyWith({
    String? id,
    double? startTime,
    double? endTime,
    String? text,
    String? speaker,
    bool? isKeywordHighlighted,
    String? animationStyle,
    bool clearSpeaker = false,
  }) {
    return CaptionEntry(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      text: text ?? this.text,
      speaker: clearSpeaker ? null : (speaker ?? this.speaker),
      isKeywordHighlighted: isKeywordHighlighted ?? this.isKeywordHighlighted,
      animationStyle: animationStyle ?? this.animationStyle,
    );
  }

  double get duration => endTime - startTime;

  @override
  String toString() =>
      'CaptionEntry(id: $id, text: "${text.length > 30 ? '${text.substring(0, 30)}...' : text}")';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaptionEntry && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// A hook suggestion for short-form content.
class HookSuggestion {
  final String id;
  final String text;
  final double score;
  final String reasoning;
  final String? style;

  const HookSuggestion({
    required this.id,
    required this.text,
    required this.score,
    this.reasoning = '',
    this.style,
  });

  factory HookSuggestion.fromJson(Map<String, dynamic> json) {
    return HookSuggestion(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      reasoning: json['reasoning'] as String? ?? '',
      style: json['style'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'score': score,
      'reasoning': reasoning,
      'style': style,
    };
  }

  HookSuggestion copyWith({
    String? id,
    String? text,
    double? score,
    String? reasoning,
    String? style,
    bool clearStyle = false,
  }) {
    return HookSuggestion(
      id: id ?? this.id,
      text: text ?? this.text,
      score: score ?? this.score,
      reasoning: reasoning ?? this.reasoning,
      style: clearStyle ? null : (style ?? this.style),
    );
  }

  @override
  String toString() =>
      'HookSuggestion(id: $id, score: ${score.toStringAsFixed(2)}, text: "${text.length > 40 ? '${text.substring(0, 40)}...' : text}")';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HookSuggestion && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// An individual critique issue found during self-critique.
class CritiqueIssue {
  final String category;
  final String description;
  final double severity; // 0.0 (minor) to 1.0 (critical)
  final String? suggestion;

  const CritiqueIssue({
    required this.category,
    required this.description,
    this.severity = 0.5,
    this.suggestion,
  });

  factory CritiqueIssue.fromJson(Map<String, dynamic> json) {
    return CritiqueIssue(
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      severity: (json['severity'] as num?)?.toDouble() ?? 0.5,
      suggestion: json['suggestion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'description': description,
      'severity': severity,
      'suggestion': suggestion,
    };
  }

  @override
  String toString() =>
      'CritiqueIssue(category: $category, severity: ${severity.toStringAsFixed(2)})';
}

/// Result of AI self-critique of a generated short.
class CritiqueResult {
  final String shortId;
  final double overallScore; // 0.0 to 1.0
  final List<CritiqueIssue> issues;
  final String summary;
  final Map<String, double> categoryScores;

  const CritiqueResult({
    required this.shortId,
    this.overallScore = 0.0,
    this.issues = const [],
    this.summary = '',
    this.categoryScores = const {},
  });

  factory CritiqueResult.fromJson(Map<String, dynamic> json) {
    return CritiqueResult(
      shortId: json['shortId'] as String? ?? '',
      overallScore: (json['overallScore'] as num?)?.toDouble() ?? 0.0,
      issues: (json['issues'] as List<dynamic>?)
              ?.map((i) => CritiqueIssue.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      summary: json['summary'] as String? ?? '',
      categoryScores: (json['categoryScores'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shortId': shortId,
      'overallScore': overallScore,
      'issues': issues.map((i) => i.toJson()).toList(),
      'summary': summary,
      'categoryScores': categoryScores,
    };
  }

  /// Number of issues found.
  int get issueCount => issues.length;

  /// Whether the video passes quality checks (score >= 0.7 and no critical issues).
  bool get passesQualityCheck {
    final hasCriticalIssues =
        issues.any((i) => i.severity >= 0.8);
    return overallScore >= 0.7 && !hasCriticalIssues;
  }

  /// Issues grouped by category.
  Map<String, List<CritiqueIssue>> get issuesByCategory {
    final grouped = <String, List<CritiqueIssue>>{};
    for (final issue in issues) {
      grouped.putIfAbsent(issue.category, () => []).add(issue);
    }
    return grouped;
  }

  @override
  String toString() =>
      'CritiqueResult(shortId: $shortId, score: ${overallScore.toStringAsFixed(2)}, issues: $issueCount)';
}

// ---------------------------------------------------------------------------
// AI Analysis Service
// ---------------------------------------------------------------------------

/// Service that orchestrates all AI-powered analysis pipelines.
///
/// Every public method returns an [ApiResponse] so callers never need to catch
/// exceptions — they simply check `response.isSuccess` and act accordingly.
///
/// The backend API endpoints handle the actual integration with external
/// AI providers (OpenAI Whisper, GPT-4V, etc.) so this client stays
/// transport-agnostic and doesn't embed API keys.
class AIAnalysisService {
  AIAnalysisService(this._apiClient);

  final ApiClient _apiClient;

  /// Default timeout for long-running analysis requests (120 s).
  static const Duration _analysisTimeout = Duration(seconds: 120);

  // ---------------------------------------------------------------------------
  // Transcription
  // ---------------------------------------------------------------------------

  /// Transcribe a video's audio track.
  ///
  /// Sends the [videoUrl] to the backend, which delegates to OpenAI Whisper.
  /// Returns a [Transcript] with word-level timestamps.
  Future<ApiResponse<Transcript>> transcribeVideo(String videoUrl) async {
    if (videoUrl.isEmpty) {
      return ApiResponse.error('Video URL must not be empty.');
    }

    final response = await _apiClient.post<Transcript>(
      '/api/transcribe',
      data: {'videoUrl': videoUrl},
      fromJson: (data) => Transcript.fromJson(data as Map<String, dynamic>),
    );

    if (!response.isSuccess) {
      debugPrint('[AIAnalysisService] transcribeVideo failed: ${response.message}');
    }

    return response;
  }

  // ---------------------------------------------------------------------------
  // Video Analysis
  // ---------------------------------------------------------------------------

  /// Perform comprehensive content analysis on a video.
  ///
  /// Returns scene detection results, speaker diarization, audio analysis,
  /// semantic analysis, and a high-level content map.
  Future<ApiResponse<VideoAnalysis>> analyzeVideo(String videoId) async {
    if (videoId.isEmpty) {
      return ApiResponse.error('Video ID must not be empty.');
    }

    final response = await _apiClient.post<VideoAnalysis>(
      '/api/analyze',
      data: {'videoId': videoId},
      fromJson: (data) => VideoAnalysis.fromJson(data as Map<String, dynamic>),
    );

    if (!response.isSuccess) {
      debugPrint('[AIAnalysisService] analyzeVideo failed: ${response.message}');
    }

    return response;
  }

  // ---------------------------------------------------------------------------
  // Viral Moment Detection
  // ---------------------------------------------------------------------------

  /// Detect viral-worthy moments within the video.
  ///
  /// Returns a list of [ViralMoment]s, each with multi-dimensional scores
  /// and reasoning explaining why the moment was flagged.
  Future<ApiResponse<List<ViralMoment>>> detectViralMoments(
    String videoId,
  ) async {
    if (videoId.isEmpty) {
      return ApiResponse.error('Video ID must not be empty.');
    }

    final response = await _apiClient.post<List<ViralMoment>>(
      '/api/detect-moments',
      data: {'videoId': videoId},
      fromJson: (data) {
        final list = data as List<dynamic>;
        return list
            .map((item) => ViralMoment.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );

    if (!response.isSuccess) {
      debugPrint(
        '[AIAnalysisService] detectViralMoments failed: ${response.message}',
      );
    }

    return response;
  }

  // ---------------------------------------------------------------------------
  // Commentary Generation
  // ---------------------------------------------------------------------------

  /// Generate AI commentary for a specific viral moment.
  ///
  /// [momentId] — the viral moment to comment on.
  /// [style] — the desired tone: `"funny"`, `"sarcastic"`, `"energetic"`,
  ///   `"informative"`, `"dramatic"`, etc.
  /// [customPrompt] — optional additional instructions for the LLM.
  Future<ApiResponse<String>> generateCommentary({
    required String momentId,
    required String style,
    String? customPrompt,
  }) async {
    if (momentId.isEmpty) {
      return ApiResponse.error('Moment ID must not be empty.');
    }
    if (style.isEmpty) {
      return ApiResponse.error('Commentary style must not be empty.');
    }

    final payload = <String, dynamic>{
      'momentId': momentId,
      'style': style,
    };
    if (customPrompt != null && customPrompt.isNotEmpty) {
      payload['customPrompt'] = customPrompt;
    }

    final response = await _apiClient.post<String>(
      '/api/generate-commentary',
      data: payload,
      fromJson: (data) => data as String,
    );

    if (!response.isSuccess) {
      debugPrint(
        '[AIAnalysisService] generateCommentary failed: ${response.message}',
      );
    }

    return response;
  }

  // ---------------------------------------------------------------------------
  // Caption Generation
  // ---------------------------------------------------------------------------

  /// Generate captions from a transcript.
  ///
  /// [transcriptId] — the transcript to derive captions from.
  /// [style] — caption presentation style (`"animated"`, `"minimal"`,
  ///   `"karaoke"`, etc.).
  /// [keywordHighlight] — whether to visually emphasise keywords.
  Future<ApiResponse<List<CaptionEntry>>> generateCaptions({
    required String transcriptId,
    String style = 'animated',
    bool keywordHighlight = true,
  }) async {
    if (transcriptId.isEmpty) {
      return ApiResponse.error('Transcript ID must not be empty.');
    }

    final response = await _apiClient.post<List<CaptionEntry>>(
      '/api/generate-captions',
      data: {
        'transcriptId': transcriptId,
        'style': style,
        'keywordHighlight': keywordHighlight,
      },
      fromJson: (data) {
        final list = data as List<dynamic>;
        return list
            .map((item) => CaptionEntry.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );

    if (!response.isSuccess) {
      debugPrint(
        '[AIAnalysisService] generateCaptions failed: ${response.message}',
      );
    }

    return response;
  }

  // ---------------------------------------------------------------------------
  // Hook Generation
  // ---------------------------------------------------------------------------

  /// Generate multiple hook variations for a viral moment.
  ///
  /// Returns 10–20 [HookSuggestion]s ranked by predicted engagement.
  Future<ApiResponse<List<HookSuggestion>>> generateHooks(
    String momentId,
  ) async {
    if (momentId.isEmpty) {
      return ApiResponse.error('Moment ID must not be empty.');
    }

    final response = await _apiClient.post<List<HookSuggestion>>(
      '/api/generate-hooks',
      data: {'momentId': momentId},
      fromJson: (data) {
        final list = data as List<dynamic>;
        return list
            .map(
                (item) => HookSuggestion.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );

    if (!response.isSuccess) {
      debugPrint('[AIAnalysisService] generateHooks failed: ${response.message}');
    }

    return response;
  }

  // ---------------------------------------------------------------------------
  // Moment Scoring
  // ---------------------------------------------------------------------------

  /// Re-score a viral moment for its viral potential.
  ///
  /// Useful when the context has changed (e.g. after editing) or when the
  /// user requests a refreshed score.
  Future<ApiResponse<ViralMoment>> scoreMoment(String momentId) async {
    if (momentId.isEmpty) {
      return ApiResponse.error('Moment ID must not be empty.');
    }

    final response = await _apiClient.post<ViralMoment>(
      '/api/score-moment',
      data: {'momentId': momentId},
      fromJson: (data) => ViralMoment.fromJson(data as Map<String, dynamic>),
    );

    if (!response.isSuccess) {
      debugPrint('[AIAnalysisService] scoreMoment failed: ${response.message}');
    }

    return response;
  }

  // ---------------------------------------------------------------------------
  // Content Map
  // ---------------------------------------------------------------------------

  /// Build a full semantic content map for a video.
  ///
  /// Returns a [ContentMap] with a high-level overview of the video's
  /// structure, key moments, and a chronological timeline.
  Future<ApiResponse<ContentMap>> buildContentMap(String videoId) async {
    if (videoId.isEmpty) {
      return ApiResponse.error('Video ID must not be empty.');
    }

    final response = await _apiClient.post<ContentMap>(
      '/api/content-map',
      data: {'videoId': videoId},
      fromJson: (data) => ContentMap.fromJson(data as Map<String, dynamic>),
    );

    if (!response.isSuccess) {
      debugPrint('[AIAnalysisService] buildContentMap failed: ${response.message}');
    }

    return response;
  }

  // ---------------------------------------------------------------------------
  // Self-Critique
  // ---------------------------------------------------------------------------

  /// Run an AI self-critique pass on a generated short.
  ///
  /// Analyses the hook, pacing, captions, audio balance, and payoff,
  /// returning a [CritiqueResult] with a breakdown of issues and scores.
  Future<ApiResponse<CritiqueResult>> critiqueVideo(String shortId) async {
    if (shortId.isEmpty) {
      return ApiResponse.error('Short ID must not be empty.');
    }

    final response = await _apiClient.post<CritiqueResult>(
      '/api/critique',
      data: {'shortId': shortId},
      fromJson: (data) => CritiqueResult.fromJson(data as Map<String, dynamic>),
    );

    if (!response.isSuccess) {
      debugPrint('[AIAnalysisService] critiqueVideo failed: ${response.message}');
    }

    return response;
  }

  // ---------------------------------------------------------------------------
  // Auto-Fix
  // ---------------------------------------------------------------------------

  /// Automatically fix issues identified during self-critique.
  ///
  /// [shortId] — the generated short to repair.
  /// [issues] — list of issue category strings or IDs to address.
  ///
  /// Returns the ID of the fixed version on success.
  Future<ApiResponse<String>> autoFix(
    String shortId,
    List<String> issues,
  ) async {
    if (shortId.isEmpty) {
      return ApiResponse.error('Short ID must not be empty.');
    }
    if (issues.isEmpty) {
      return ApiResponse.error('At least one issue must be provided.');
    }

    final response = await _apiClient.post<String>(
      '/api/auto-fix',
      data: {
        'shortId': shortId,
        'issues': issues,
      },
      fromJson: (data) => data as String,
    );

    if (!response.isSuccess) {
      debugPrint('[AIAnalysisService] autoFix failed: ${response.message}');
    }

    return response;
  }
}
