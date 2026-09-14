import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:ffmpeg_kit_flutter/media_information_session.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Real video editing service using FFmpeg.
/// This actually cuts, trims, and processes video files on the device.
class VideoEditorService {
  /// Trim a video from startTime to endTime.
  /// Returns the path to the trimmed video file.
  static Future<String> trimVideo({
    required String inputPath,
    required double startTimeSeconds,
    required double endTimeSeconds,
    String? outputPath,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final output = outputPath ??
        '${dir.path}/trimmed_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final duration = endTimeSeconds - startTimeSeconds;
    final command = '-i "$inputPath" '
        '-ss $startTimeSeconds '
        '-t $duration '
        '-c:v libx264 -c:a aac '
        '-avoid_negative_ts make_zero '
        '-y "$output"';

    debugPrint('FFmpeg trim command: $command');
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      debugPrint('Trim successful: $output');
      return output;
    } else {
      final output_log = await session.getOutput();
      throw Exception('FFmpeg trim failed: $output_log');
    }
  }

  /// Extract a clip from a video.
  static Future<String> extractClip({
    required String inputPath,
    required double startTime,
    required double duration,
    String? outputPath,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final output = outputPath ??
        '${dir.path}/clip_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final command = '-i "$inputPath" '
        '-ss $startTime '
        '-t $duration '
        '-c:v libx264 -c:a aac '
        '-movflags +faststart '
        '-y "$output"';

    debugPrint('FFmpeg extract clip command: $command');
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return output;
    } else {
      final log = await session.getOutput();
      throw Exception('FFmpeg extract clip failed: $log');
    }
  }

  /// Get real video metadata using FFprobe.
  static Future<VideoInfo> getVideoInfo(String videoPath) async {
    final session = await FFprobeKit.getMediaInformation(videoPath);
    final info = await session.getMediaInformation();

    if (info == null) {
      throw Exception('Could not get video info');
    }

    final format = info.getFormat();
    final streams = info.getStreams() ?? [];

    int width = 0, height = 0, fps = 30;
    bool hasAudio = false;
    double bitrate = 0;

    for (final stream in streams) {
      if (stream.getType() == 'video') {
        width = int.tryParse(stream.getWidth()?.toString() ?? '0') ?? 0;
        height = int.tryParse(stream.getHeight()?.toString() ?? '0') ?? 0;
        fps = _parseFps(stream.getRealFrameRate());
      } else if (stream.getType() == 'audio') {
        hasAudio = true;
      }
    }

    final duration = double.tryParse(format?.getDuration() ?? '0') ?? 0;
    bitrate = double.tryParse(format?.getBitrate() ?? '0') ?? 0;
    final size = int.tryParse(format?.getSize() ?? '0') ?? 0;

    return VideoInfo(
      path: videoPath,
      duration: duration,
      width: width,
      height: height,
      fps: fps,
      bitrate: bitrate,
      fileSize: size,
      hasAudio: hasAudio,
    );
  }

  /// Automatically generate short clips from a video.
  /// Uses scene detection to find the best cut points.
  static Future<List<GeneratedClip>> autoGenerateShorts({
    required String inputPath,
    int maxClips = 6,
    double minClipDuration = 10,
    double maxClipDuration = 60,
  }) async {
    final info = await getVideoInfo(inputPath);
    final clips = <GeneratedClip>[];

    // Detect scene changes
    final scenes = await _detectScenes(inputPath);
    debugPrint('Detected ${scenes.length} scenes');

    // Generate clips around the most interesting moments
    final sortedScenes = List<double>.from(scenes)..sort();

    for (final sceneTime in sortedScenes) {
      if (clips.length >= maxClips) break;

      // Create a clip centered on this scene change
      double clipStart = max(0, sceneTime - 3);
      double clipDuration = min(maxClipDuration, max(minClipDuration, info.duration * 0.1));

      // Don't exceed video duration
      if (clipStart + clipDuration > info.duration) {
        clipStart = max(0, info.duration - clipDuration);
      }

      // Check overlap with existing clips
      bool overlaps = false;
      for (final existing in clips) {
        if (clipStart < existing.endTime && clipStart + clipDuration > existing.startTime) {
          overlaps = true;
          break;
        }
      }
      if (overlaps) continue;

      clips.add(GeneratedClip(
        startTime: clipStart,
        duration: clipDuration,
        label: 'Short ${clips.length + 1}',
      ));
    }

    // Sort by start time
    clips.sort((a, b) => a.startTime.compareTo(b.startTime));
    return clips;
  }

  /// Detect scene changes using FFmpeg.
  static Future<List<double>> _detectScenes(String videoPath) async {
    final scenes = <double>[];

    try {
      final session = await FFmpegKit.execute(
        '-i "$videoPath" -vf "select=gt(scene\,0.3),showinfo" -vsync vfr -f null -',
      );
      final output = await session.getAllLogsAsString();

      final regex = RegExp(r'pts_time:(\d+\.?\d*)');
      for (final match in regex.allMatches(output)) {
        final time = double.tryParse(match.group(1) ?? '');
        if (time != null) scenes.add(time);
      }
    } catch (e) {
      debugPrint('Scene detection error: $e');
    }

    // If no scenes detected, generate evenly spaced points
    if (scenes.isEmpty) {
      final info = await getVideoInfo(videoPath);
      final interval = max(info.duration / 8, 5.0);
      for (double t = interval; t < info.duration - 5; t += interval) {
        scenes.add(t);
      }
    }

    return scenes;
  }

  /// Add text overlay to a video (for captions).
  static Future<String> addTextOverlay({
    required String inputPath,
    required String text,
    required double startTime,
    required double duration,
    String? outputPath,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final output = outputPath ??
        '${dir.path}/captioned_${DateTime.now().millisecondsSinceEpoch}.mp4';

    // Escape special characters for FFmpeg
    final escapedText = text.replaceAll("'", "'\\''").replaceAll(':', '\\:');

    final command = '-i "$inputPath" '
        '-vf "drawtext=text=\'$escapedText\':fontsize=24:fontcolor=white:'
        'borderw=2:bordercolor=black:'
        'x=(w-text_w)/2:y=h-text_h-40:'
        'enable=\'between(t,$startTime,$startTime + $duration)\'" '
        '-c:v libx264 -c:a copy '
        '-y "$output"';

    debugPrint('FFmpeg add text command: $command');
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return output;
    } else {
      final log = await session.getOutput();
      throw Exception('FFmpeg text overlay failed: $log');
    }
  }

  /// Concatenate multiple video clips into one.
  static Future<String> concatenateClips({
    required List<String> clipPaths,
    String? outputPath,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final output = outputPath ??
        '${dir.path}/combined_${DateTime.now().millisecondsSinceEpoch}.mp4';

    // Create concat file
    final concatFile = File('${dir.path}/concat_list.txt');
    final lines = clipPaths.map((path) => "file '$path'").join('\n');
    await concatFile.writeAsString(lines);

    final command = '-f concat -safe 0 -i "${concatFile.path}" '
        '-c:v libx264 -c:a copy '
        '-y "$output"';

    debugPrint('FFmpeg concatenate command: $command');
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    // Clean up
    await concatFile.delete();

    if (ReturnCode.isSuccess(returnCode)) {
      return output;
    } else {
      final log = await session.getOutput();
      throw Exception('FFmpeg concatenate failed: $log');
    }
  }

  static int _parseFps(dynamic fpsValue) {
    if (fpsValue == null) return 30;
    final fpsStr = fpsValue.toString();
    if (fpsStr.contains('/')) {
      final parts = fpsStr.split('/');
      if (parts.length == 2) {
        final num = double.tryParse(parts[0]) ?? 30;
        final den = double.tryParse(parts[1]) ?? 1;
        return (num / den).round();
      }
    }
    return int.tryParse(fpsStr) ?? 30;
  }

  static double max(double a, double b) => a > b ? a : b;
  static double min(double a, double b) => a < b ? a : b;
}

class VideoInfo {
  final String path;
  final double duration;
  final int width;
  final int height;
  final int fps;
  final double bitrate;
  final int fileSize;
  final bool hasAudio;

  VideoInfo({
    required this.path,
    required this.duration,
    required this.width,
    required this.height,
    required this.fps,
    required this.bitrate,
    required this.fileSize,
    required this.hasAudio,
  });
}

class GeneratedClip {
  final double startTime;
  final double duration;
  final String label;

  double get endTime => startTime + duration;

  GeneratedClip({
    required this.startTime,
    required this.duration,
    required this.label,
  });
}
