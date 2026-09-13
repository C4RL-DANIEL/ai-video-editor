/// Video rendering service for the AI Video Editor app.
///
/// Builds FFmpeg command pipelines for rendering short-form (9:16) and
/// long-form (16:9) videos from edit decisions, captions, and audio tracks.
/// The actual FFmpeg execution is delegated to a platform channel or native
/// package; this service is responsible for command construction, pipeline
/// orchestration, and result validation.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../features/editor/models/edit_decision.dart';
import '../../features/longform/presentation/long_form_builder_page.dart'
    show Chapter;
import '../../features/shorts/models/short_video.dart';

// ---------------------------------------------------------------------------
// Result / QC models
// ---------------------------------------------------------------------------

/// Outcome of a render pass.
class RenderResult {
  /// Whether the render completed without errors.
  final bool success;

  /// Absolute path to the rendered file (null on failure).
  final String? outputPath;

  /// Duration of the output video (null on failure).
  final Duration? duration;

  /// File size in bytes (null on failure).
  final int? fileSize;

  /// Human-readable error when [success] is false.
  final String? error;

  /// Wall-clock time the render took.
  final Duration? renderTime;

  const RenderResult({
    required this.success,
    this.outputPath,
    this.duration,
    this.fileSize,
    this.error,
    this.renderTime,
  });

  /// Convenience factory for a successful result.
  factory RenderResult.ok({
    required String outputPath,
    required Duration duration,
    required int fileSize,
    Duration? renderTime,
  }) {
    return RenderResult(
      success: true,
      outputPath: outputPath,
      duration: duration,
      fileSize: fileSize,
      renderTime: renderTime,
    );
  }

  /// Convenience factory for a failed result.
  factory RenderResult.fail(String error) {
    return RenderResult(success: false, error: error);
  }

  @override
  String toString() => success
      ? 'RenderResult(✓ ${outputPath ?? "?"}, ${duration ?? "N/A"}, '
          '${fileSize ?? 0} bytes)'
      : 'RenderResult(✗ $error)';
}

/// Quality-control result for a rendered output.
class QCResult {
  /// Overall pass (no blocking issues).
  final bool passed;

  /// Individual issues found.
  final List<QCIssue> issues;

  const QCResult({required this.passed, this.issues = const []});

  factory QCResult.pass() => const QCResult(passed: true);
  factory QCResult.fail(List<QCIssue> issues) =>
      QCResult(passed: false, issues: issues);

  /// Number of issues that exceed the given severity threshold.
  int severeCount([double threshold = 0.7]) =>
      issues.where((i) => i.severity >= threshold).length;

  @override
  String toString() =>
      'QCResult(${passed ? "PASS" : "FAIL (${issues.length} issues)"})';
}

/// A single quality-control issue.
class QCIssue {
  /// Issue category – e.g. "black_frame", "audio_sync", "bad_crop",
  /// "caption_timing", "audio_clipping", "corruption", "frozen_frame".
  final String type;

  /// Human-readable description.
  final String description;

  /// Severity from 0.0 (informational) to 1.0 (blocking).
  final double severity;

  /// Timestamp of the issue within the video, if localised.
  final Duration? timestamp;

  const QCIssue({
    required this.type,
    required this.description,
    this.severity = 1.0,
    this.timestamp,
  });

  @override
  String toString() => 'QCIssue($type, sev: ${severity.toStringAsFixed(2)}, '
      '${timestamp != null ? timestamp! : "global"})';
}

// ---------------------------------------------------------------------------
// FFmpeg command representation
// ---------------------------------------------------------------------------

/// Describes a single FFmpeg command to execute.
class FFmpegCommand {
  /// The executable (e.g. "ffmpeg" or "ffprobe").
  final String executable;

  /// Arguments (without the executable itself).
  final List<String> args;

  /// Optional label for progress reporting.
  final String label;

  const FFmpegCommand({
    this.executable = 'ffmpeg',
    required this.args,
    this.label = '',
  });

  /// Serialises the command to a shell-safe string.
  String toShellString() {
    final parts = <String>[executable, ...args];
    return parts.map(_shellEscape).join(' ');
  }

  static String _shellEscape(String arg) {
    if (arg.contains(' ') || arg.contains("'") || arg.contains('"')) {
      return "'${arg.replaceAll("'", r"'\''")}'";
    }
    return arg;
  }

  @override
  String toString() => toShellString();
}

/// Describes an ffprobe command.
class FFprobeCommand extends FFmpegCommand {
  const FFprobeCommand({required List<String> args, String label = ''})
      : super(executable: 'ffprobe', args: args, label: label);
}

// ---------------------------------------------------------------------------
// Progress callback type
// ---------------------------------------------------------------------------

/// Called during rendering with a value from 0.0 to 1.0 and a stage name.
typedef ProgressCallback = void Function(double progress, String stage);

// ---------------------------------------------------------------------------
// VideoRenderService
// ---------------------------------------------------------------------------

/// Service responsible for constructing and executing FFmpeg pipelines that
/// render short-form (9:16) and long-form (16:9) videos.
///
/// ## Architecture
///
/// 1. The public API accepts *edit decisions*, *captions*, and *audio
///    configuration – all defined in the editor/shorts models.
/// 2. Each method translates those into one or more [FFmpegCommand]s.
/// 3. Commands are executed via [_executeCommand], which is an abstraction
///    over the native FFmpeg bridge. Swap this out for testing.
/// 4. A post-render QC pass ([validateOutput]) checks the output.
///
/// ## Native integration
///
/// On production builds the FFmpeg binary is provided by either
/// * `flutter_ffmpeg` / `ffmpeg_kit_flutter` or
/// * a custom platform channel calling a bundled `ffmpeg` binary.
///
/// The methods marked `// TODO(native)` should be replaced with real
/// platform calls; the default stubs return placeholder results so the
/// service can be unit-tested without a native layer.
class VideoRenderService {
  VideoRenderService({
    FFmpegExecutor? executor,
    FFprobeExecutor? probeExecutor,
  })  : _executor = executor ?? const _StubFFmpegExecutor(),
        _probe = probeExecutor ?? const _StubFFprobeExecutor();

  final FFmpegExecutor _executor;
  final FFprobeExecutor _probe;

  // ─────────────────────────────────────────────────────────────────────────
  // Public API — Short-form render
  // ─────────────────────────────────────────────────────────────────────────

  /// Renders a short-form video (9:16, 1080×1920).
  ///
  /// The pipeline:
  /// 1. **Cut** source to each [EditDecision]'s time range.
  /// 2. **Zoom / crop** to 9:16 centre-crop or smart-zoom.
  /// 3. **Speed** changes via `setpts` / `atempo`.
  /// 4. **Caption overlays** drawn with `drawtext` filters.
  /// 5. **Audio mix** – original + commentary + music + SFX with ducking.
  /// 6. **Effects** – freeze frame, replay, screen shake via select/equaliser.
  /// 7. **Export** to [outputPath].
  Future<RenderResult> renderShort({
    required String sourceVideoPath,
    required List<EditDecision> edits,
    required List<CaptionEntry> captions,
    required AudioConfig audioConfig,
    required String outputPath,
    ProgressCallback? onProgress,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      // ── Stage 1: probe source ──
      onProgress?.call(0.0, 'probing');
      final sourceInfo = await _probeMedia(sourceVideoPath);
      if (sourceInfo == null) {
        return RenderResult.fail('Could not probe source: $sourceVideoPath');
      }

      // ── Stage 2: build video filter chain ──
      onProgress?.call(0.05, 'building_filters');
      final videoFilters = _buildShortVideoFilters(
        edits: edits,
        sourceWidth: sourceInfo.width,
        sourceHeight: sourceInfo.height,
      );

      // ── Stage 3: build caption drawtext filters ──
      onProgress?.call(0.15, 'captions');
      final captionFilters = _buildCaptionFilters(captions);

      // ── Stage 4: build audio filter chain ──
      onProgress?.call(0.25, 'audio_mix');
      final audioFilters = _buildShortAudioFilters(
        edits: edits,
        audioConfig: audioConfig,
      );

      // ── Stage 5: build the complete FFmpeg command ──
      onProgress?.call(0.30, 'building_command');
      final command = _buildShortRenderCommand(
        sourceVideoPath: sourceVideoPath,
        edits: edits,
        videoFilters: [...videoFilters, ...captionFilters],
        audioFilters: audioFilters,
        outputPath: outputPath,
      );

      debugPrint('[VideoRenderService] FFmpeg command:\n$command');

      // ── Stage 6: execute ──
      onProgress?.call(0.35, 'encoding');
      final execResult = await _executor.run(
        command,
        onProgress: (double p, String stage) {
          // Map 0..1 native progress into 35%–90% of total
          onProgress?.call(0.35 + p * 0.55, 'encoding');
        },
      );

      if (!execResult.success) {
        return RenderResult.fail(
          'FFmpeg exited with code ${execResult.exitCode}: ${execResult.stderr}',
        );
      }

      // ── Stage 7: probe output ──
      onProgress?.call(0.92, 'verifying');
      final outputInfo = await _probeMedia(outputPath);

      stopwatch.stop();
      onProgress?.call(1.0, 'done');

      return RenderResult.ok(
        outputPath: outputPath,
        duration: outputInfo != null
            ? Duration(milliseconds: (outputInfo.durationSeconds * 1000).round())
            : Duration.zero,
        fileSize: execResult.outputFileSize ?? 0,
        renderTime: stopwatch.elapsed,
      );
    } catch (e, st) {
      stopwatch.stop();
      debugPrint('[VideoRenderService] renderShort error: $e\n$st');
      return RenderResult.fail(e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Public API — Long-form render
  // ─────────────────────────────────────────────────────────────────────────

  /// Renders a long-form video (16:9, 1920×1080).
  ///
  /// The pipeline:
  /// 1. For each [Chapter], cut and join the relevant segments.
  /// 2. Concatenate chapter segments with optional transitions.
  /// 3. Overlay chapter titles as brief text cards.
  /// 4. Mix audio: original + commentary voice-over.
  /// 5. Export to [outputPath].
  Future<RenderResult> renderLongForm({
    required String sourceVideoPath,
    required List<Chapter> chapters,
    required String commentaryPath,
    required String outputPath,
    ProgressCallback? onProgress,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      onProgress?.call(0.0, 'probing');
      final sourceInfo = await _probeMedia(sourceVideoPath);
      if (sourceInfo == null) {
        return RenderResult.fail('Could not probe source: $sourceVideoPath');
      }

      // Build per-chapter filter chains and concatenate.
      onProgress?.call(0.05, 'building_filters');
      final allVideoFilters = <String>[];
      final allAudioFilters = <String>[];
      final inputs = <String>[];
      final concatSegments = <_ConcatSegment>[];

      for (var i = 0; i < chapters.length; i++) {
        final chapter = chapters[i];

        // Each chapter uses trim filters on the same input.
        // [trim=start=X:end=Y] + [setpts=PTS-STARTPTS]
        allVideoFilters.add(
          '[0:v]trim=start=${chapter.startTime.toStringAsFixed(3)}'
          ':end=${chapter.endTime.toStringAsFixed(3)},'
          'setpts=PTS-STARTPTS,'
          'scale=1920:1080:force_original_aspect_ratio=decrease,'
          'pad=1920:1080:(ow-iw)/2:(oh-ih)/2,'
          'setsar=1'
          '[v$i]',
        );

        allAudioFilters.add(
          '[0:a]atrim=start=${chapter.startTime.toStringAsFixed(3)}'
          ':end=${chapter.endTime.toStringAsFixed(3)},'
          'asetpts=PTS-STARTPTS'
          '[a$i]',
        );

        concatSegments.add(_ConcatSegment(videoLabel: 'v$i', audioLabel: 'a$i'));
      }

      // Concatenate all chapter segments.
      final concatVideoLabel = concatSegments.map((s) => s.videoLabel).join('');
      final concatAudioLabel = concatSegments.map((s) => s.audioLabel).join('');
      final n = concatSegments.length;

      allVideoFilters.add(
        '${concatVideoLabel}concat=n=$n:v=1:a=0[outv]',
      );
      allAudioFilters.add(
        '${concatAudioLabel}concat=n=$n:v=0:a=1[outa_pre]',
      );

      // Mix with commentary (input 1) if provided.
      onProgress?.call(0.15, 'audio_mix');
      if (commentaryPath.isNotEmpty) {
        allAudioFilters.add(
          '[outa_pre][1:a]amix=inputs=2:duration=longest:'
          'dropout_transition=2:normalize=0'
          '[outa]',
        );
        inputs.addAll(['-i', sourceVideoPath, '-i', commentaryPath]);
      } else {
        allAudioFilters.add('[outa_pre]acopy[outa]');
        inputs.addAll(['-i', sourceVideoPath]);
      }

      final filterComplex = [
        ...allVideoFilters,
        ...allAudioFilters,
      ].join(';\n');

      final args = [
        ...inputs,
        '-filter_complex', filterComplex,
        '-map', '[outv]',
        '-map', '[outa]',
        '-c:v', 'libx264',
        '-preset', 'slow',
        '-crf', '18',
        '-c:a', 'aac',
        '-b:a', '192k',
        '-movflags', '+faststart',
        '-y',
        outputPath,
      ];

      final command = FFmpegCommand(args: args, label: 'long_form_render');
      debugPrint('[VideoRenderService] FFmpeg command:\n$command');

      onProgress?.call(0.20, 'encoding');
      final execResult = await _executor.run(
        command,
        onProgress: (double p, String stage) {
          onProgress?.call(0.20 + p * 0.70, 'encoding');
        },
      );

      if (!execResult.success) {
        return RenderResult.fail(
          'FFmpeg exited with code ${execResult.exitCode}: ${execResult.stderr}',
        );
      }

      onProgress?.call(0.92, 'verifying');
      final outputInfo = await _probeMedia(outputPath);

      stopwatch.stop();
      onProgress?.call(1.0, 'done');

      return RenderResult.ok(
        outputPath: outputPath,
        duration: outputInfo != null
            ? Duration(milliseconds: (outputInfo.durationSeconds * 1000).round())
            : Duration.zero,
        fileSize: execResult.outputFileSize ?? 0,
        renderTime: stopwatch.elapsed,
      );
    } catch (e, st) {
      stopwatch.stop();
      debugPrint('[VideoRenderService] renderLongForm error: $e\n$st');
      return RenderResult.fail(e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Public API — Proxy / preview
  // ─────────────────────────────────────────────────────────────────────────

  /// Generates a lower-resolution proxy for fast previewing.
  Future<String> generateProxy(String videoPath, {int maxWidth = 640}) async {
    final outputPath = '${videoPath}_proxy_${maxWidth}p.mp4';

    final command = FFmpegCommand(
      args: [
        '-i', videoPath,
        '-vf', 'scale=$maxWidth:-2',
        '-c:v', 'libx264',
        '-preset', 'ultrafast',
        '-crf', '28',
        '-an', // strip audio for smaller file
        '-y',
        outputPath,
      ],
      label: 'proxy',
    );

    final result = await _executor.run(command);
    if (!result.success) {
      throw VideoRenderException('Proxy generation failed: ${result.stderr}');
    }
    return outputPath;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Public API — Thumbnail extraction
  // ─────────────────────────────────────────────────────────────────────────

  /// Extracts a single frame as a thumbnail at [timestamp].
  Future<String> extractThumbnail(
    String videoPath,
    Duration timestamp,
  ) async {
    final tsSeconds = timestamp.inMicroseconds / 1e6;
    final outputPath = '${videoPath}_thumb_${timestamp.inMilliseconds}.jpg';

    final command = FFmpegCommand(
      args: [
        '-ss', tsSeconds.toStringAsFixed(4),
        '-i', videoPath,
        '-vframes', '1',
        '-q:v', '2',
        '-y',
        outputPath,
      ],
      label: 'thumbnail',
    );

    final result = await _executor.run(command);
    if (!result.success) {
      throw VideoRenderException('Thumbnail extraction failed: ${result.stderr}');
    }
    return outputPath;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Public API — Audio extraction
  // ─────────────────────────────────────────────────────────────────────────

  /// Extracts the audio track from a video file.
  Future<String> extractAudio(String videoPath) async {
    final outputPath = '${videoPath}_audio.m4a';

    final command = FFmpegCommand(
      args: [
        '-i', videoPath,
        '-vn',
        '-c:a', 'aac',
        '-b:a', '192k',
        '-y',
        outputPath,
      ],
      label: 'extract_audio',
    );

    final result = await _executor.run(command);
    if (!result.success) {
      throw VideoRenderException('Audio extraction failed: ${result.stderr}');
    }
    return outputPath;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Public API — Audio mixing
  // ─────────────────────────────────────────────────────────────────────────

  /// Mixes up to four audio tracks with independent volume control.
  ///
  /// [originalAudio] is the source video's extracted audio. The other three
  /// are optional supplementary tracks. When ducking is enabled the music
  /// track is attenuated during commentary segments.
  Future<String> mergeAudio({
    required String originalAudio,
    String? commentaryAudio,
    String? musicAudio,
    String? sfxAudio,
    double originalVolume = 1.0,
    double commentaryVolume = 1.0,
    double musicVolume = 0.3,
    double sfxVolume = 0.5,
    bool enableDucking = true,
    String? outputPath,
  }) async {
    // Collect non-null inputs and their volumes.
    final inputs = <_AudioTrack>[
      _AudioTrack(path: originalAudio, volume: originalVolume, label: 'orig'),
      if (commentaryAudio != null)
        _AudioTrack(path: commentaryAudio, volume: commentaryVolume, label: 'comm'),
      if (musicAudio != null)
        _AudioTrack(path: musicAudio, volume: musicVolume, label: 'music'),
      if (sfxAudio != null)
        _AudioTrack(path: sfxAudio, volume: sfxVolume, label: 'sfx'),
    ];

    if (inputs.length == 1) {
      // Only one track – just adjust volume.
      final out = outputPath ?? '${originalAudio}_mixed.m4a';
      final filter = 'volume=${originalVolume.toStringAsFixed(2)}';
      final command = FFmpegCommand(
        args: [
          '-i', originalAudio,
          '-af', filter,
          '-c:a', 'aac',
          '-b:a', '192k',
          '-y',
          out,
        ],
        label: 'merge_audio_single',
      );
      final result = await _executor.run(command);
      if (!result.success) {
        throw VideoRenderException('Audio merge failed: ${result.stderr}');
      }
      return out;
    }

    // Build amix filter chain with per-track volume.
    final filterParts = <String>[];
    for (final track in inputs) {
      filterParts.add('[${track.label}]volume=${track.volume.toStringAsFixed(2)}[${track.label}_v]');
    }

    final inputLabels = inputs.map((t) => '[${t.label}_v]').join();
    final mixFilter = '${inputLabels}amix=inputs=${inputs.length}'
        ':duration=longest:dropout_transition=3:normalize=0[out]';
    filterParts.add(mixFilter);

    // Optional sidechain ducking: when commentary is present, duck music.
    if (enableDucking &&
        commentaryAudio != null &&
        musicAudio != null) {
      // Use sidechaincompress to duck music under commentary.
      // This replaces the simple amix above with a more sophisticated chain.
      filterParts.clear();

      for (final track in inputs) {
        filterParts.add(
          '[${track.label}]volume=${track.volume.toStringAsFixed(2)}[${track.label}_v]',
        );
      }

      // Duck music using commentary as sidechain.
      filterParts.add(
        '[music_v][comm_v]sidechaincompress=threshold=0.02:'
        'ratio=4:attack=20:release=200[music_ducked]',
      );

      final mixInputs = <String>[
        '[orig_v]',
        '[comm_v]',
        '[music_ducked]',
        if (sfxAudio != null) '[sfx_v]',
      ];
      filterParts.add(
        '${mixInputs.join()}amix=inputs=${mixInputs.length}'
        ':duration=longest:dropout_transition=3:normalize=0[out]',
      );
    }

    final filterComplex = filterParts.join(';');

    // Build input flags.
    final inputArgs = <String>[];
    for (final track in inputs) {
      inputArgs.addAll(['-i', track.path]);
    }

    final out = outputPath ?? '${originalAudio}_merged.m4a';
    final command = FFmpegCommand(
      args: [
        ...inputArgs,
        '-filter_complex', filterComplex,
        '-map', '[out]',
        '-c:a', 'aac',
        '-b:a', '192k',
        '-y',
        out,
      ],
      label: 'merge_audio',
    );

    final result = await _executor.run(command);
    if (!result.success) {
      throw VideoRenderException('Audio merge failed: ${result.stderr}');
    }
    return out;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Public API — Quality control
  // ─────────────────────────────────────────────────────────────────────────

  /// Validates a rendered video for common quality issues.
  Future<QCResult> validateOutput(String videoPath) async {
    final issues = <QCIssue>[];

    // 1. Probe the output to verify it's readable.
    final info = await _probeMedia(videoPath);
    if (info == null) {
      return QCResult.fail([
        QCIssue(
          type: 'corruption',
          description: 'Output file could not be probed – file may be corrupt.',
          severity: 1.0,
        ),
      ]);
    }

    // 2. Check for black frames.
    issues.addAll(await _detectBlackFrames(videoPath));

    // 3. Check for frozen/still frames.
    issues.addAll(await _detectFrozenFrames(videoPath));

    // 4. Check audio levels for clipping.
    issues.addAll(await _detectAudioClipping(videoPath));

    // 5. Basic audio/video sync check via duration comparison.
    if (info.videoDurationSeconds != null && info.audioDurationSeconds != null) {
      final drift =
          (info.videoDurationSeconds! - info.audioDurationSeconds!).abs();
      if (drift > 0.1) {
        issues.add(QCIssue(
          type: 'audio_sync',
          description:
              'A/V drift of ${drift.toStringAsFixed(3)}s between video '
              '(${info.videoDurationSeconds!.toStringAsFixed(2)}s) and audio '
              '(${info.audioDurationSeconds!.toStringAsFixed(2)}s).',
          severity: drift > 0.5 ? 1.0 : 0.5,
        ));
      }
    }

    // Determine pass/fail: any severity >= 1.0 is blocking.
    final passed = !issues.any((i) => i.severity >= 1.0);
    return passed ? QCResult.pass() : QCResult.fail(issues);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Private — Short-form filter builders
  // ═══════════════════════════════════════════════════════════════════════════

  /// Builds the video filter chain for a short-form render.
  ///
  /// The chain applies, in order:
  /// * trim & concat from edit decisions
  /// * zoom / crop to 9:16
  /// * speed changes
  /// * effects (freeze frame, replay, screen shake)
  List<String> _buildShortVideoFilters({
    required List<EditDecision> edits,
    required int sourceWidth,
    required int sourceHeight,
  }) {
    final filters = <String>[];

    // ── Step 1: Cut segments and concat ──
    final cutDecisions =
        edits.where((e) => e.type == EditDecisionType.cut).toList();
    if (cutDecisions.isNotEmpty) {
      // For each cut, generate a trim segment.
      for (var i = 0; i < cutDecisions.length; i++) {
        final cut = cutDecisions[i];
        filters.add(
          '[0:v]trim=start=${cut.startTime.toStringAsFixed(3)}'
          ':end=${cut.endTime.toStringAsFixed(3)},'
          'setpts=PTS-STARTPTS[c$i]',
        );
      }

      // Speed adjustments per segment.
      final speedDecisions =
          edits.where((e) => e.type == EditDecisionType.speed).toList();
      for (final speed in speedDecisions) {
        final mult = speed.params.speedMultiplier ?? 1.0;
        if ((mult - 1.0).abs() > 0.001) {
          // Find the segment index this speed applies to.
          final idx = _findSegmentIndex(cutDecisions, speed);
          if (idx >= 0) {
            // Apply setpts for speed on that segment.
            final ptsFactor = (1.0 / mult).toStringAsFixed(4);
            final existingLabel = 'c$idx';
            filters[idx] = filters[idx].replaceFirst(
              '[c$idx]',
              '[c${idx}_pre]',
            );
            filters.add(
              '[c${idx}_pre]setpts=$ptsFactor*PTS[c$idx]',
            );
          }
        }
      }

      // Concat all segments.
      final labels = cutDecisions.asMap().keys.map((i) => '[c$i]').join();
      filters.add(
        '${labels}concat=n=${cutDecisions.length}:v=1:a=0[cut_video]',
      );
    }

    // ── Step 2: Zoom / crop to 9:16 (1080×1920) ──
    final zoomDecisions =
        edits.where((e) => e.type == EditDecisionType.zoom).toList();
    if (zoomDecisions.isNotEmpty) {
      final zoom = zoomDecisions.first;
      final zoomLevel = zoom.params.zoomLevel ?? 1.5;
      final centerX = zoom.params.zoomX ?? 0.5;
      final centerY = zoom.params.zoomY ?? 0.5;

      // Center-crop with zoom, then scale to 1080×1920.
      // zoompan handles the centre-based zoom on a 9:16 canvas.
      final inputLabel = filters.isEmpty ? '[0:v]' : '[cut_video]';
      filters.add(
        '${inputLabel}zoompan=z=$zoomLevel'
        ':x="iw/2-(iw/zoom/2)+((iw/zoom)*${centerX.toStringAsFixed(3)}-iw/zoom/2)"'
        ':y="ih/2-(ih/zoom/2)+((ih/zoom)*${centerY.toStringAsFixed(3)}-ih/zoom/2)"'
        ':d=1:s=1080x1920:fps=30'
        '[zoomed]',
      );
    } else {
      // Default: centre-crop to 9:16 without explicit zoom.
      final inputLabel = filters.isEmpty ? '[0:v]' : '[cut_video]';
      filters.add(
        '${inputLabel}scale=1080:1920:force_original_aspect_ratio=increase,'
        'crop=1080:1920,setsar=1[cropped]',
      );
    }

    // ── Step 3: Effects ──
    // Freeze frame effect.
    final freezeDecisions =
        edits.where((e) => e.type == EditDecisionType.effect).toList();
    for (final effect in freezeDecisions) {
      final params = effect.params.effectParams ?? {};
      final effectType = params['type'] as String? ?? '';

      if (effectType == 'freeze_frame') {
        final freezeStart = effect.startTime;
        final freezeDuration = params['duration'] as double? ?? 2.0;
        // Use select filter to freeze a single frame for the duration.
        filters.add(
          'select=gt(scene\\,0.01),'
          'freeze=start=${freezeStart.toStringAsFixed(3)}'
          ':duration=${freezeDuration.toStringAsFixed(3)}'
          '[frozen]',
        );
      } else if (effectType == 'screen_shake') {
        // Simulate shake via randomised crop offsets.
        filters.add(
          'crop=in_w-40:in_h-40:'
          '40+10*sin(t*15):30+8*cos(t*12)',
        );
      }
    }

    return filters;
  }

  /// Builds drawtext caption filters from [CaptionEntry] list.
  List<String> _buildCaptionFilters(List<CaptionEntry> captions) {
    final filters = <String>[];
    if (captions.isEmpty) return filters;

    for (var i = 0; i < captions.length; i++) {
      final cap = captions[i];
      final text = _escapeDrawText(cap.text);
      final style = cap.style;

      // Resolve position.
      final x = _captionXPosition(cap.position);
      final y = _captionYPosition(cap.position);

      // Font settings.
      final fontFile = style.fontFamily != null
          ? 'fontfile=${style.fontFamily}:'
          : '';
      final fontSize = style.fontSize.round();
      final fontColor = _hexToDrawTextColor(style.color ?? '#FFFFFF');
      final fontWeight = style.isBold ? 'Bold' : 'Normal';

      // Shadow for readability.
      final shadowColor =
          _hexToDrawTextColor(style.shadowColor ?? '#000000');
      final shadowX = '1';
      final shadowY = '1';

      // Optional background box.
      final boxOpts = style.backgroundColor != null
          ? ':box=1:boxcolor=${_hexToDrawTextColor(style.backgroundColor!)}'
              '${style.backgroundOpacity != null ? '@${style.backgroundOpacity!.toStringAsFixed(2)}' : ''}'
              ':boxborderw=8'
          : '';

      filters.add(
        "drawtext=$fontFile"
        "text='$text'"
        ":font_size=$fontSize"
        ":fontcolor=$fontColor"
        ":font_weight=$fontWeight"
        ":x=$x"
        ":y=$y"
        ":shadowcolor=$shadowColor"
        ":shadowx=$shadowX"
        ":shadowy=$shadowY"
        "$boxOpts"
        ":enable='between(t,${cap.startTime.toStringAsFixed(3)},${cap.endTime.toStringAsFixed(3)})'"
        '[cap$i]',
      );
    }

    // Chain caption filters together.
    if (filters.length > 1) {
      // Replace the input of subsequent filters to chain.
      for (var i = 1; i < filters.length; i++) {
        final prevLabel = '[cap${i - 1}]';
        filters[i] = filters[i].replaceFirst(
          RegExp(r'\[0:v\]'),
          prevLabel,
        );
      }
      // Final label.
      final lastLabel = '[cap${filters.length - 1}]';
      // Return the last filter with its output label as the result.
    }

    return filters;
  }

  /// Builds the audio filter chain for a short-form render.
  List<String> _buildShortAudioFilters({
    required List<EditDecision> edits,
    required AudioConfig audioConfig,
  }) {
    final filters = <String>[];

    // Original audio with trim.
    final cutDecisions =
        edits.where((e) => e.type == EditDecisionType.cut).toList();
    if (cutDecisions.isNotEmpty) {
      for (var i = 0; i < cutDecisions.length; i++) {
        final cut = cutDecisions[i];
        filters.add(
          '[0:a]atrim=start=${cut.startTime.toStringAsFixed(3)}'
          ':end=${cut.endTime.toStringAsFixed(3)},'
          'asetpts=PTS-STARTPTS,'
          'volume=1.0'
          '[a$i]',
        );
      }
      final labels = cutDecisions.asMap().keys.map((i) => '[a$i]').join();
      filters.add(
        '${labels}concat=n=${cutDecisions.length}:v=0:a=1[original_a]',
      );
    }

    // Apply commentary / music / SFX mixing if audio config indicates tracks.
    // In production these would come from separate input files.
    final inputLabels = <String>['[original_a]'];
    final volumes = <double>[1.0];

    // TODO(native): Wire up commentary, music, and SFX input paths here.
    // For now, we just apply volume to the original track.
    filters.add('[original_a]volume=1.0[final_a]');

    return filters;
  }

  /// Builds the complete FFmpeg command for a short-form render.
  FFmpegCommand _buildShortRenderCommand({
    required String sourceVideoPath,
    required List<EditDecision> edits,
    required List<String> videoFilters,
    required List<String> audioFilters,
    required String outputPath,
  }) {
    // Determine the last video label.
    String lastVideoLabel = '[0:v]';
    if (videoFilters.isNotEmpty) {
      // Find the last filter that produces an output label.
      for (var i = videoFilters.length - 1; i >= 0; i--) {
        final match = RegExp(r'\[(\w+)\]\s*$').firstMatch(videoFilters[i]);
        if (match != null) {
          lastVideoLabel = '[${match.group(1)}]';
          break;
        }
      }
    }

    // Determine the last audio label.
    String lastAudioLabel = '[0:a]';
    if (audioFilters.isNotEmpty) {
      for (var i = audioFilters.length - 1; i >= 0; i--) {
        final match = RegExp(r'\[(\w+)\]\s*$').firstMatch(audioFilters[i]);
        if (match != null) {
          lastAudioLabel = '[${match.group(1)}]';
          break;
        }
      }
    }

    final filterComplex = [...videoFilters, ...audioFilters].join(';\n');

    final args = <String>[
      '-i', sourceVideoPath,
      '-filter_complex', filterComplex,
      '-map', lastVideoLabel,
      '-map', lastAudioLabel,
      '-c:v', 'libx264',
      '-preset', 'medium',
      '-crf', '20',
      '-pix_fmt', 'yuv420p',
      '-c:a', 'aac',
      '-b:a', '192k',
      '-ar', '48000',
      '-movflags', '+faststart',
      '-y',
      outputPath,
    ];

    return FFmpegCommand(args: args, label: 'short_render');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Private — QC helpers
  // ═══════════════════════════════════════════════════════════════════════════

  /// Detects black frames using `select='eq(n\,black)'`.
  Future<List<QCIssue>> _detectBlackFrames(String videoPath) async {
    final command = FFprobeCommand(
      args: [
        '-f', 'lavfi',
        '-i', 'movie=${_escapeFFmpegPath(videoPath)},'
            'select=gt(scene\\,0.01)',
        '-vf', 'blackdetect=d=0.5:pix_th=0.10',
        '-f', 'null',
        '-',
      ],
      label: 'black_detect',
    );

    // TODO(native): Parse ffprobe output for blackdetect results.
    // For now, return empty – the real implementation would parse stderr.
    return const [];
  }

  /// Detects frozen/still frames (consecutive identical frames).
  Future<List<QCIssue>> _detectFrozenFrames(String videoPath) async {
    // TODO(native): Use `select='gt(scene,0)'` or custom analysis to detect
    // consecutive duplicate frames beyond a threshold.
    return const [];
  }

  /// Detects audio clipping by probing loudness stats.
  Future<List<QCIssue>> _detectAudioClipping(String videoPath) async {
    // TODO(native): Use `loudnorm=print_format=json` or `astats` to detect
    // samples exceeding 0 dBFS.
    return const [];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Private — Media probing
  // ═══════════════════════════════════════════════════════════════════════════

  /// Probes a media file and returns basic stream information.
  Future<MediaInfo?> _probeMedia(String path) async {
    try {
      return await _probe.probe(path);
    } catch (e) {
      debugPrint('[VideoRenderService] Probe failed for $path: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Private — Helpers
  // ═══════════════════════════════════════════════════════════════════════════

  /// Finds which segment index an edit applies to.
  int _findSegmentIndex(List<EditDecision> cuts, EditDecision edit) {
    for (var i = 0; i < cuts.length; i++) {
      if (edit.startTime >= cuts[i].startTime &&
          edit.endTime <= cuts[i].endTime) {
        return i;
      }
    }
    return -1;
  }

  /// Escapes text for FFmpeg drawtext filter.
  static String _escapeDrawText(String text) {
    return text
        .replaceAll('\\', '\\\\\\\\')
        .replaceAll("'", "'\\\\\\''")
        .replaceAll(':', '\\:')
        .replaceAll('%', '%%');
  }

  /// Escapes a path for FFmpeg filter syntax.
  static String _escapeFFmpegPath(String path) {
    return path.replaceAll("'", "\\'").replaceAll(':', '\\:');
  }

  /// Converts a hex colour to FFmpeg drawtext colour string.
  /// e.g. "#FF0000" → "0xFF0000" or "#FFFFFF@0.8" → "0xFFFFFF@0.8".
  static String _hexToDrawTextColor(String hex) {
    if (hex.startsWith('#') && hex.length == 7) {
      return '0x${hex.substring(1)}';
    }
    if (hex.startsWith('#') && hex.length == 9) {
      return '0x${hex.substring(1, 7)}@${int.parse(hex.substring(7, 9), radix: 16) / 255.0}';
    }
    return hex;
  }

  /// X-position expression for drawtext based on [CaptionPosition].
  static String _captionXPosition(CaptionPosition pos) {
    switch (pos) {
      case CaptionPosition.topLeft:
      case CaptionPosition.bottomLeft:
        return '20';
      case CaptionPosition.topRight:
      case CaptionPosition.bottomRight:
        return 'w-tw-20';
      case CaptionPosition.center:
      case CaptionPosition.top:
      case CaptionPosition.bottom:
        return '(w-tw)/2';
    }
  }

  /// Y-position expression for drawtext based on [CaptionPosition].
  static String _captionYPosition(CaptionPosition pos) {
    switch (pos) {
      case CaptionPosition.top:
      case CaptionPosition.topLeft:
      case CaptionPosition.topRight:
        return '40';
      case CaptionPosition.center:
        return '(h-th)/2';
      case CaptionPosition.bottom:
      case CaptionPosition.bottomLeft:
      case CaptionPosition.bottomRight:
        return 'h-th-40';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Supporting types & abstractions
// ═══════════════════════════════════════════════════════════════════════════════

/// Exception thrown by video render operations.
class VideoRenderException implements Exception {
  final String message;
  const VideoRenderException(this.message);

  @override
  String toString() => 'VideoRenderException: $message';
}

/// Basic info about a media stream returned by ffprobe.
class MediaInfo {
  final int width;
  final int height;
  final double durationSeconds;
  final double? videoDurationSeconds;
  final double? audioDurationSeconds;
  final double fps;
  final String? codecName;
  final int? bitrate;

  const MediaInfo({
    required this.width,
    required this.height,
    required this.durationSeconds,
    this.videoDurationSeconds,
    this.audioDurationSeconds,
    this.fps = 30.0,
    this.codecName,
    this.bitrate,
  });

  @override
  String toString() =>
      'MediaInfo(${width}x${height}, ${durationSeconds.toStringAsFixed(2)}s, '
      '${fps.toStringAsFixed(1)} fps)';
}

/// Result of executing a single FFmpeg command.
class FFmpegExecResult {
  final bool success;
  final int exitCode;
  final String stdout;
  final String stderr;
  final int? outputFileSize;

  const FFmpegExecResult({
    required this.success,
    required this.exitCode,
    this.stdout = '',
    this.stderr = '',
    this.outputFileSize,
  });

  factory FFmpegExecResult.ok({String stdout = '', int? fileSize}) {
    return FFmpegExecResult(
      success: true,
      exitCode: 0,
      stdout: stdout,
      outputFileSize: fileSize,
    );
  }

  factory FFmpegExecResult.fail({
    required int exitCode,
    String stderr = '',
  }) {
    return FFmpegExecResult(
      success: false,
      exitCode: exitCode,
      stderr: stderr,
    );
  }
}

/// Abstraction for executing FFmpeg commands.
///
/// Implementations:
/// * [_StubFFmpegExecutor] — returns success immediately (for testing).
/// * Native platform channel implementation (TODO).
/// * `ffmpeg_kit_flutter` wrapper (TODO).
abstract class FFmpegExecutor {
  /// Runs the given [command] and returns its result.
  Future<FFmpegExecResult> run(
    FFmpegCommand command, {
    ProgressCallback? onProgress,
  });
}

/// Abstraction for ffprobe queries.
abstract class FFprobeExecutor {
  /// Probes [path] and returns media information.
  Future<MediaInfo> probe(String path);
}

// ───────────────────────────────────────────────────────────────────────────
// Internal helpers
// ───────────────────────────────────────────────────────────────────────────

class _ConcatSegment {
  final String videoLabel;
  final String audioLabel;
  const _ConcatSegment({required this.videoLabel, required this.audioLabel});
}

class _AudioTrack {
  final String path;
  final double volume;
  final String label;
  const _AudioTrack({
    required this.path,
    required this.volume,
    required this.label,
  });
}

// ───────────────────────────────────────────────────────────────────────────
// Stub executors (for testing / unit tests)
// ───────────────────────────────────────────────────────────────────────────

/// A stub executor that returns success without running FFmpeg.
///
/// Used for unit tests and when the native layer is unavailable.
class _StubFFmpegExecutor implements FFmpegExecutor {
  const _StubFFmpegExecutor();

  @override
  Future<FFmpegExecResult> run(
    FFmpegCommand command, {
    ProgressCallback? onProgress,
  }) async {
    debugPrint('[StubFFmpeg] ${command.toShellString()}');
    onProgress?.call(1.0, 'done');
    return FFmpegExecResult.ok();
  }
}

class _StubFFprobeExecutor implements FFprobeExecutor {
  const _StubFFprobeExecutor();

  @override
  Future<MediaInfo> probe(String path) async {
    debugPrint('[StubFFprobe] $path');
    // Return a sensible default for testing.
    return const MediaInfo(
      width: 1920,
      height: 1080,
      durationSeconds: 60.0,
      fps: 30.0,
      codecName: 'h264',
    );
  }
}
