import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../config/appwrite_config.dart';
import '../services/real_video_analyzer.dart';

/// Service that calls the Appwrite Function "process-video" for real
/// server-side video processing (FFmpeg on the backend).
///
/// Endpoint: https://sgp.cloud.appwrite.io/v1/functions/process-video/executions
/// Project ID: 6aa6c23100337d473370
class AppwriteFunctionService {
  AppwriteFunctionService._();

  static const _baseUrl =
      '${AppwriteConfig.endpoint}/functions/process-video/executions';

  /// Executes the "process-video" Appwrite Function with the given [action]
  /// and [payload], then returns the parsed JSON response body.
  ///
  /// [action] must be one of: "analyze", "trim", "extract-clip".
  /// Returns null if the function runs but response body isn't captured.
  static Future<Map<String, dynamic>?> _executeFunction({
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    final body = jsonEncode({
      'action': action,
      ...payload,
    });

    debugPrint('AppwriteFunctionService: calling action=$action');

    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    try {
      final response = await dio.post(
        _baseUrl,
        data: body,
      );

      debugPrint('AppwriteFunctionService: status=${response.statusCode}');

      // The function returns 200 when it runs successfully
      // But the response body may not be captured by the execution API
      if (response.statusCode == 200) {
        if (response.data is Map && (response.data as Map).isNotEmpty) {
          final data = response.data as Map<String, dynamic>;
          debugPrint('AppwriteFunctionService: got response data — keys=${data.keys.toList()}');
          return data;
        }
        // Response body is empty — function ran but body not captured
        debugPrint('AppwriteFunctionService: function ran (200) but response body empty — using client-side analysis');
        return null;
      }

      debugPrint('AppwriteFunctionService: unexpected status ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      debugPrint('AppwriteFunctionService: DioException — ${e.message}');
      return null;
    } finally {
      dio.close();
    }
  }

  // ── Public API ──────────────────────────────────────────────────

  /// Calls the Appwrite Function to perform a full video **analysis**.
  /// Falls back to client-side RealVideoAnalyzer if the function response
  /// body isn't captured (known Appwrite Cloud issue).
  static Future<VideoAnalysisResult> analyzeVideo(String fileId, {String? localPath}) async {
    try {
      final json = await _executeFunction(
        action: 'analyze',
        payload: {'fileId': fileId},
      );

      if (json != null && json.isNotEmpty) {
        return _parseAnalysisResult(json);
      }
    } catch (e) {
      debugPrint('AppwriteFunctionService: function call failed — $e');
    }

    // Fallback: use client-side analyzer if we have a local path
    if (localPath != null) {
      debugPrint('AppwriteFunctionService: falling back to client-side analysis');
      return await RealVideoAnalyzer.analyze(localPath);
    }

    // Last resort: return empty result
    debugPrint('AppwriteFunctionService: no local path available, returning empty result');
    return VideoAnalysisResult(
      metadata: VideoMetadata(duration: 0, width: 0, height: 0, fps: 30, fileSize: 0),
      scenes: [],
      viralMoments: [],
      clips: [],
      hasAudio: false,
      overallScore: 0,
    );
  }

  /// Calls the Appwrite Function to **trim** a video between [start] and
  /// [end] seconds and returns the resulting trimmed-video metadata.
  static Future<Map<String, dynamic>> trimVideo(
    String fileId,
    double start,
    double end,
  ) async {
    return _executeFunction(
      action: 'trim',
      payload: {
        'fileId': fileId,
        'start': start,
        'end': end,
      },
    );
  }

  /// Calls the Appwrite Function to **extract a clip** between [start]
  /// and [end] seconds and returns the resulting clip metadata.
  static Future<Map<String, dynamic>> extractClip(
    String fileId,
    double start,
    double end,
  ) async {
    return _executeFunction(
      action: 'extract-clip',
      payload: {
        'fileId': fileId,
        'start': start,
        'end': end,
      },
    );
  }

  // ── Parsing helpers ─────────────────────────────────────────────

  /// Converts the raw JSON returned by the function into a
  /// [VideoAnalysisResult] that the existing UI can consume.
  static VideoAnalysisResult _parseAnalysisResult(Map<String, dynamic> json) {
    // The function may nest its payload under "result" or return it at the
    // top level — be lenient.
    final data = (json['result'] as Map<String, dynamic>?) ?? json;

    // Metadata
    final metaJson = (data['metadata'] as Map<String, dynamic>?) ?? {};
    final metadata = VideoMetadata(
      duration: (metaJson['duration'] as num?)?.toDouble() ?? 0,
      width: (metaJson['width'] as num?)?.toInt() ?? 0,
      height: (metaJson['height'] as num?)?.toInt() ?? 0,
      fps: (metaJson['fps'] as num?)?.toInt() ?? 30,
      fileSize: (metaJson['fileSize'] as num?)?.toInt() ?? 0,
    );

    // Scene changes
    final scenesList = (data['scenes'] as List<dynamic>?) ?? [];
    final scenes = scenesList.map((s) {
      final m = s as Map<String, dynamic>;
      return SceneChange(
        time: (m['time'] as num?)?.toDouble() ?? 0,
        score: (m['score'] as num?)?.toDouble() ?? 0.5,
        type: (m['type'] as String?) ?? 'transition',
      );
    }).toList();

    // Viral moments
    final momentsList = (data['viralMoments'] as List<dynamic>?) ?? [];
    final viralMoments = momentsList.map((m) {
      final vm = m as Map<String, dynamic>;
      return ViralMoment(
        time: (vm['time'] as num?)?.toDouble() ?? 0,
        score: (vm['score'] as num?)?.toInt() ?? 50,
        type: (vm['type'] as String?) ?? 'engaging',
        label: (vm['label'] as String?) ?? '',
      );
    }).toList();

    // Short clips
    final clipsList = (data['clips'] as List<dynamic>?) ?? [];
    final clips = clipsList.map((c) {
      final cl = c as Map<String, dynamic>;
      return ShortClip(
        startTime: (cl['startTime'] as num?)?.toDouble() ?? 0,
        endTime: (cl['endTime'] as num?)?.toDouble() ?? 0,
        duration: (cl['duration'] as num?)?.toDouble() ?? 0,
        score: (cl['score'] as num?)?.toInt() ?? 50,
        label: (cl['label'] as String?) ?? '',
      );
    }).toList();

    return VideoAnalysisResult(
      metadata: metadata,
      scenes: scenes,
      viralMoments: viralMoments,
      clips: clips,
      hasAudio: (data['hasAudio'] as bool?) ?? true,
      overallScore: (data['overallScore'] as num?)?.toInt() ?? 50,
    );
  }
}
