import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:ffmpeg_kit_flutter/media_information_session.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../models/video_effect.dart';

/// A comprehensive video-effects service that applies real visual effects,
/// captions, sound effects, and transitions to video clips using FFmpeg.
///
/// Every public method builds and executes an FFmpeg command via
/// [FFmpegKit.execute], so all processing happens on-device.
class VideoEffectsService {
  VideoEffectsService._();

  static final VideoEffectsService instance = VideoEffectsService._();

  // ── helpers ──────────────────────────────────────────────────────────────

  static Future<String> _tempDir() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  static String _outPath(String dir, String prefix) =>
      '$dir/${prefix}_${DateTime.now().millisecondsSinceEpoch}.mp4';

  /// Escapes single-quotes and colons for use inside FFmpeg drawtext strings.
  static String _escapeText(String text) =>
      text.replaceAll("'", "'\\''").replaceAll(':', '\\:');

  /// Runs an FFmpeg command and throws on failure.
  static Future<void> _run(String command, String label) async {
    debugPrint('[$label] FFmpeg command: $command');
    final session = await FFmpegKit.execute(command);
    final rc = await session.getReturnCode();
    if (!ReturnCode.isSuccess(rc)) {
      final log = await session.getAllLogsAsString();
      throw Exception('$label failed (rc=$rc): $log');
    }
  }

  /// Retrieves video metadata (duration, resolution, etc.) via FFprobe.
  static Future<VideoInfo> getVideoInfo(String path) async {
    final session = await FFprobeKit.getMediaInformation(path);
    final info = await session.getMediaInformation();
    if (info == null) throw Exception('Could not read video info for $path');

    final format = info.getFormat();
    final streams = info.getStreams() ?? [];
    int w = 0, h = 0, fps = 30;
    bool hasAudio = false;

    for (final s in streams) {
      if (s.getType() == 'video') {
        w = int.tryParse(s.getWidth()?.toString() ?? '0') ?? 0;
        h = int.tryParse(s.getHeight()?.toString() ?? '0') ?? 0;
        fps = _parseFps(s.getRealFrameRate());
      } else if (s.getType() == 'audio') {
        hasAudio = true;
      }
    }

    return VideoInfo(
      path: path,
      duration: double.tryParse(format?.getDuration() ?? '0') ?? 0,
      width: w,
      height: h,
      fps: fps,
      bitrate: double.tryParse(format?.getBitrate() ?? '0') ?? 0,
      fileSize: int.tryParse(format?.getSize() ?? '0') ?? 0,
      hasAudio: hasAudio,
    );
  }

  static int _parseFps(dynamic value) {
    if (value == null) return 30;
    final s = value.toString();
    if (s.contains('/')) {
      final parts = s.split('/');
      if (parts.length == 2) {
        final num = double.tryParse(parts[0]) ?? 30;
        final den = double.tryParse(parts[1]) ?? 1;
        return (num / den).round();
      }
    }
    return int.tryParse(s) ?? 30;
  }

  // ════════════════════════════════════════════════════════════════════════
  // 1. CAPTIONS
  // ════════════════════════════════════════════════════════════════════════

  /// Adds animated text captions to a video.
  ///
  /// Each [CaptionSegment] is rendered via the `drawtext` filter with a
  /// configurable time window (`enable='between(t,...)'`).
  ///
  /// Multiple segments are chained with commas in a single `-vf` pass.
  static Future<String> addCaptions({
    required String inputPath,
    required List<CaptionSegment> captions,
    String? outputPath,
  }) async {
    final dir = await _tempDir();
    final output = outputPath ?? _outPath(dir, 'captioned');

    if (captions.isEmpty) {
      // No captions – just copy the file.
      await _run(
        '-i "$inputPath" -c copy -y "$output"',
        'addCaptions',
      );
      return output;
    }

    final filters = <String>[];

    for (var i = 0; i < captions.length; i++) {
      final seg = captions[i];
      final style = seg.style;
      final escaped = _escapeText(seg.text);

      // Position expressions.
      final xPos = (style.xPosition * 100).toStringAsFixed(1);
      final yPos = (style.yPosition * 100).toStringAsFixed(1);

      final parts = <String>[
        "drawtext=text='$escaped'",
        'fontsize=${style.fontSize}',
        'fontcolor=${style.fontColor}',
        'borderw=${style.borderWidth}',
        'bordercolor=${style.borderColor}',
        'x=(w*${xPos}/100)-(text_w/2)',
        'y=(h*${yPos}/100)-(text_h/2)',
        "enable='between(t,${seg.startTime},${seg.endTime})'",
      ];

      // Optional font family.
      if (style.fontFamily != null && style.fontFamily!.isNotEmpty) {
        parts.add("fontfile='${style.fontFamily}'");
      }

      // Optional background box.
      if (style.hasBackground) {
        parts.add(
          'box=1:boxcolor=${style.backgroundColor}:boxborderw=8',
        );
      }

      filters.add(parts.join(':'));
    }

    final filterChain = filters.join(',');
    final command = '-i "$inputPath" '
        '-vf "$filterChain" '
        '-c:v libx264 -crf 18 -preset fast '
        '-c:a copy '
        '-movflags +faststart '
        '-y "$output"';

    await _run(command, 'addCaptions');
    debugPrint('[addCaptions] Output → $output');
    return output;
  }

  // ════════════════════════════════════════════════════════════════════════
  // 2. ZOOM EFFECT (Ken Burns)
  // ════════════════════════════════════════════════════════════════════════

  /// Applies a Ken Burns zoom effect.
  ///
  /// Uses the `zoompan` filter. The zoom starts at 1.0 and increases (or
  /// decreases for zoom-out) linearly over the clip duration.
  static Future<String> applyZoomEffect({
    required String inputPath,
    required ZoomEffect effect,
    String? outputPath,
  }) async {
    final dir = await _tempDir();
    final output = outputPath ?? _outPath(dir, 'zoom');

    final info = await getVideoInfo(inputPath);
    final dur = effect.duration > 0 ? effect.duration : info.duration;
    final totalFrames = (dur * effect.fps).round();

    // zoom expressions: zoomin starts at 1.0 → intensity,
    //                   zoomout starts at intensity → 1.0
    String zoomExpr;
    if (effect.type == ZoomType.zoomIn) {
      zoomExpr = "zoom+0.001";
    } else {
      zoomExpr = "zoom-0.001";
    }

    // The zoompan filter produces a frame-per-zoom step, so we use
    // `d=1` (one frame per input frame) and `s=` for output size.
    final command = '-i "$inputPath" '
        '-vf "zoompan=z=\'${zoomExpr}\':'
        'x=\'iw/2-(iw/zoom/2)\':'
        'y=\'ih/2-(ih/zoom/2)\':'
        'd=$totalFrames:'
        's=${info.width}x${info.height}:'
        'fps=${effect.fps}" '
        '-c:v libx264 -crf 18 -preset fast '
        '-c:a copy '
        '-movflags +faststart '
        '-y "$output"';

    await _run(command, 'applyZoomEffect');
    debugPrint('[applyZoomEffect] Output → $output');
    return output;
  }

  // ════════════════════════════════════════════════════════════════════════
  // 3. FADE TRANSITION
  // ════════════════════════════════════════════════════════════════════════

  /// Adds fade-in at the start and/or fade-out at the end of the video.
  ///
  /// [fadeInDuration] – seconds for the fade-in (0 to disable).
  /// [fadeOutDuration] – seconds for the fade-out (0 to disable).
  static Future<String> applyFadeTransition({
    required String inputPath,
    double fadeInDuration = 0.5,
    double fadeOutDuration = 0.5,
    String? outputPath,
  }) async {
    final dir = await _tempDir();
    final output = outputPath ?? _outPath(dir, 'faded');

    final info = await getVideoInfo(inputPath);
    final filters = <String>[];
    final audioFilters = <String>[];

    // Video fades.
    if (fadeInDuration > 0) {
      filters.add('fade=t=in:st=0:d=$fadeInDuration');
    }
    if (fadeOutDuration > 0) {
      final fadeOutStart = math.max(0, info.duration - fadeOutDuration);
      filters.add('fade=t=out:st=$fadeOutStart:d=$fadeOutDuration');
    }

    // Audio fades.
    if (info.hasAudio) {
      if (fadeInDuration > 0) {
        audioFilters.add('afade=t=in:st=0:d=$fadeInDuration');
      }
      if (fadeOutDuration > 0) {
        final fadeOutStart = math.max(0, info.duration - fadeOutDuration);
        audioFilters.add('afade=t=out:st=$fadeOutStart:d=$fadeOutDuration');
      }
    }

    final vf = filters.isNotEmpty ? '-vf "${filters.join(',')}"' : '-c:v copy';
    final af = audioFilters.isNotEmpty && info.hasAudio
        ? '-af "${audioFilters.join(',')}"'
        : (info.hasAudio ? '-c:a copy' : '-an');

    final command = '-i "$inputPath" $vf $af '
        '-c:v libx264 -crf 18 -preset fast '
        '-movflags +faststart '
        '-y "$output"';

    await _run(command, 'applyFadeTransition');
    debugPrint('[applyFadeTransition] Output → $output');
    return output;
  }

  // ════════════════════════════════════════════════════════════════════════
  // 4. COLOR GRADING
  // ════════════════════════════════════════════════════════════════════════

  /// Applies a color-grading preset using `eq` and `colorbalance` filters.
  static Future<String> applyColorGrading({
    required String inputPath,
    required ColorGrade grade,
    String? outputPath,
  }) async {
    final dir = await _tempDir();
    final output = outputPath ?? _outPath(dir, 'graded');

    final filter = _colorGradeFilter(grade);

    final command = '-i "$inputPath" '
        '-vf "$filter" '
        '-c:v libx264 -crf 18 -preset fast '
        '-c:a copy '
        '-movflags +faststart '
        '-y "$output"';

    await _run(command, 'applyColorGrading');
    debugPrint('[applyColorGrading] grade=$grade → $output');
    return output;
  }

  /// Returns the FFmpeg filter string for a given [ColorGrade].
  static String _colorGradeFilter(ColorGrade grade) {
    switch (grade) {
      case ColorGrade.warm:
        // Boost reds/yellows, slight saturation bump.
        return 'eq=saturation=1.1:brightness=0.02:contrast=1.05,'
            'colorbalance=rs=0.15:gs=0.05:bs=-0.10:rh=0.10:gh=0.02:bh=-0.08';

      case ColorGrade.cool:
        // Shift toward blue, slight contrast.
        return 'eq=saturation=1.05:contrast=1.05,'
            'colorbalance=rs=-0.10:gs=-0.02:bs=0.15:rm=-0.05:bm=0.10';

      case ColorGrade.highContrast:
        // Strong contrast boost, high saturation.
        return 'eq=saturation=1.3:contrast=1.5:brightness=-0.03';

      case ColorGrade.vintage:
        // Desaturated, warm highlights, faded blacks.
        return 'eq=saturation=0.7:contrast=1.1:brightness=0.05:gamma=1.2,'
            'colorbalance=rs=0.10:gs=0.05:bs=-0.05:rh=0.08:gh=0.03:bh=-0.05';

      case ColorGrade.cinematic:
        // Slightly desaturated, teal shadows, orange highlights (blockbuster look).
        return 'eq=saturation=0.9:contrast=1.15:brightness=-0.02,'
            'colorbalance=rs=-0.05:gs=0.02:bs=0.08:rh=0.10:gh=0.03:bh=-0.08';
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // 5. SOUND EFFECTS (SFX)
  // ════════════════════════════════════════════════════════════════════════

  /// Adds sound effects at specific timestamps.
  ///
  /// Simple tones (beep, ding, click) are synthesised with FFmpeg's built-in
  /// `sine` audio source. Whoosh and impact effects are approximated with
  /// shaped noise bursts via `anoisesrc`.
  static Future<String> addSFX({
    required String inputPath,
    required List<SFXTiming> sfxTimings,
    String? outputPath,
  }) async {
    final dir = await _tempDir();
    final output = outputPath ?? _outPath(dir, 'sfx');

    if (sfxTimings.isEmpty) {
      await _run('-i "$inputPath" -c copy -y "$output"', 'addSFX');
      return output;
    }

    // We'll generate each SFX to a temp file, then mix them all together
    // with the original audio.
    final tempSfxFiles = <String>[];
    final info = await getVideoInfo(inputPath);

    for (var i = 0; i < sfxTimings.length; i++) {
      final sfx = sfxTimings[i];
      final sfxPath = '$dir/_sfx_${DateTime.now().millisecondsSinceEpoch}_$i.wav';
      tempSfxFiles.add(sfxPath);

      await _generateSfx(type: sfx.type, duration: sfx.duration, volume: sfx.volume, outputPath: sfxPath);
    }

    // Build the complex filter to mix all SFX into the original audio.
    final inputs = StringBuffer('-i "$inputPath"');
    for (final f in tempSfxFiles) {
      inputs.write(' -i "$f"');
    }

    final filterParts = <String>[];

    // Delay each SFX to its timestamp, set volume.
    for (var i = 0; i < sfxTimings.length; i++) {
      final delayMs = (sfxTimings[i].timestamp * 1000).round();
      filterParts.add('[${i + 1}:a]adelay=$delayMs|$delayMs,volume=${sfxTimings[i].volume}[sfx$i]');
    }

    // Mix: [0:a] is the original audio, plus all [sfxN] streams.
    final mixInputs = StringBuffer('[0:a]');
    for (var i = 0; i < sfxTimings.length; i++) {
      mixInputs.write('[sfx$i]');
    }
    final mixCount = sfxTimings.length + 1;
    filterParts.add(
      '${mixInputs}amix=inputs=$mixCount:duration=first:dropout_transition=0[aout]',
    );

    final filterComplex = filterParts.join(';');

    final command = '$inputs '
        '-filter_complex "$filterComplex" '
        '-map 0:v -map "[aout]" '
        '-c:v copy -c:a aac -b:a 192k '
        '-movflags +faststart '
        '-y "$output"';

    await _run(command, 'addSFX');

    // Clean up temp SFX files.
    for (final f in tempSfxFiles) {
      try {
        await File(f).delete();
      } catch (_) {}
    }

    debugPrint('[addSFX] Output → $output');
    return output;
  }

  /// Generates a simple sound-effect WAV file using FFmpeg's audio sources.
  static Future<void> _generateSfx({
    required SFXType type,
    required double duration,
    required double volume,
    required String outputPath,
  }) async {
    String command;
    switch (type) {
      case SFXType.ding:
        // Short 880 Hz sine tone, quick fade out.
        command = '-f lavfi -i "sine=frequency=880:duration=$duration" '
            '-af "afade=t=out:st=0.1:d=${math.max(0.05, duration - 0.1)},volume=$volume" '
            '-y "$outputPath"';
        break;
      case SFXType.beep:
        // 1 kHz sine tone.
        command = '-f lavfi -i "sine=frequency=1000:duration=$duration" '
            '-af "afade=t=in:d=0.02,afade=t=out:st=${math.max(0.02, duration - 0.1)}:d=0.1,volume=$volume" '
            '-y "$outputPath"';
        break;
      case SFXType.click:
        // Very short high-frequency chirp.
        command = '-f lavfi -i "sine=frequency=2000:duration=0.05" '
            '-af "afade=t=out:st=0.02:d=0.03,volume=$volume" '
            '-y "$outputPath"';
        break;
      case SFXType.whoosh:
        // White noise burst with bandpass and sweep.
        command = '-f lavfi -i "anoisesrc=d=$duration:c=white:r=44100:a=$volume" '
            '-af "highpass=f=1000,lowpass=f=6000,afade=t=in:d=${duration * 0.3},afade=t=out:st=${duration * 0.5}:d=${duration * 0.5}" '
            '-y "$outputPath"';
        break;
      case SFXType.impact:
        // Low-frequency rumble burst.
        command = '-f lavfi -i "anoisesrc=d=$duration:c=pink:r=44100:a=$volume" '
            '-af "lowpass=f=200,afade=t=in:d=0.01,afade=t=out:st=${duration * 0.2}:d=${duration * 0.8}" '
            '-y "$outputPath"';
        break;
    }

    debugPrint('[SFX] Generating ${type.name}: $command');
    await _run(command, 'generateSFX');
  }

  // ════════════════════════════════════════════════════════════════════════
  // 6. SPEED EFFECT
  // ════════════════════════════════════════════════════════════════════════

  /// Changes playback speed of the video.
  ///
  /// For uniform speed the entire clip is processed. For segment-based
  /// variable speed, the clip is cut into segments, each sped up or slowed
  /// down, then re-concatenated.
  static Future<String> applySpeedEffect({
    required String inputPath,
    required List<SpeedEffect> effects,
    String? outputPath,
  }) async {
    final dir = await _tempDir();
    final output = outputPath ?? _outPath(dir, 'speed');

    if (effects.isEmpty) {
      await _run('-i "$inputPath" -c copy -y "$output"', 'applySpeedEffect');
      return output;
    }

    final info = await getVideoInfo(inputPath);

    // Simple case: single uniform speed effect covering the whole clip.
    if (effects.length == 1 &&
        effects[0].startTime == null &&
        effects[0].endTime == null) {
      return _applyUniformSpeed(
        inputPath: inputPath,
        speed: effects[0].speed,
        info: info,
        output: output,
      );
    }

    // Complex case: split into segments, process each, concatenate.
    return _applySegmentedSpeed(
      inputPath: inputPath,
      effects: effects,
      info: info,
      output: output,
      dir: dir,
    );
  }

  static Future<String> _applyUniformSpeed({
    required String inputPath,
    required double speed,
    required VideoInfo info,
    required String output,
  }) async {
    // setpts adjusts video speed; atempo adjusts audio speed.
    // atempo only accepts 0.5–100.0 so we chain multiple for extreme values.
    final ptsFactor = (1.0 / speed).toStringAsFixed(4);
    final videoFilter = 'setpts=$ptsFactor*PTS';

    final audioFilter = _buildAtempoChain(speed);

    final command = '-i "$inputPath" '
        '-vf "$videoFilter" '
        '-af "$audioFilter" '
        '-c:v libx264 -crf 18 -preset fast '
        '-c:a aac -b:a 192k '
        '-movflags +faststart '
        '-y "$output"';

    await _run(command, 'applySpeedEffect(uniform)');
    debugPrint('[applySpeedEffect] speed=$speed → $output');
    return output;
  }

  /// Builds a chain of `atempo` filters (each limited to 0.5–100.0 range).
  static String _buildAtempoChain(double speed) {
    if (speed <= 0) speed = 1.0;
    final filters = <String>[];
    double remaining = speed;

    while (remaining > 100.0) {
      filters.add('atempo=100.0');
      remaining /= 100.0;
    }
    while (remaining < 0.5) {
      filters.add('atempo=0.5');
      remaining /= 0.5;
    }
    filters.add('atempo=${remaining.toStringAsFixed(4)}');

    return filters.join(',');
  }

  static Future<String> _applySegmentedSpeed({
    required String inputPath,
    required List<SpeedEffect> effects,
    required VideoInfo info,
    required String output,
    required String dir,
  }) async {
    // Sort effects by start time.
    final sorted = List<SpeedEffect>.from(effects)
      ..sort((a, b) => (a.startTime ?? 0).compareTo(b.startTime ?? 0));

    // Build segments: [0 → eff1.start], [eff1.start → eff1.end], …, [last.end → duration].
    final segments = <_SpeedSegment>[];
    double cursor = 0;

    for (final eff in sorted) {
      final segStart = eff.startTime ?? 0;
      final segEnd = eff.endTime ?? info.duration;

      if (segStart > cursor + 0.05) {
        segments.add(_SpeedSegment(start: cursor, end: segStart, speed: 1.0));
      }
      segments.add(_SpeedSegment(start: segStart, end: segEnd, speed: eff.speed));
      cursor = segEnd;
    }
    if (cursor < info.duration - 0.05) {
      segments.add(_SpeedSegment(start: cursor, end: info.duration, speed: 1.0));
    }

    // Process each segment.
    final partPaths = <String>[];
    for (var i = 0; i < segments.length; i++) {
      final seg = segments[i];
      final segDur = seg.end - seg.start;
      if (segDur <= 0) continue;

      final partPath = '$dir/_speed_part_${DateTime.now().millisecondsSinceEpoch}_$i.mp4';
      partPaths.add(partPath);

      final ptsFactor = (1.0 / seg.speed).toStringAsFixed(4);
      final af = _buildAtempoChain(seg.speed);

      final command = '-i "$inputPath" '
          '-ss ${seg.start} -t $segDur '
          '-vf "setpts=$ptsFactor*PTS" '
          '-af "$af" '
          '-c:v libx264 -crf 18 -preset fast '
          '-c:a aac '
          '-movflags +faststart '
          '-y "$partPath"';

      await _run(command, 'speedPart$i');
    }

    // Concatenate all parts.
    final concatFile = File('$dir/_speed_concat_${DateTime.now().millisecondsSinceEpoch}.txt');
    await concatFile.writeAsString(
      partPaths.map((p) => "file '$p'").join('\n'),
    );

    final concatCmd = '-f concat -safe 0 -i "${concatFile.path}" '
        '-c:v libx264 -crf 18 -preset fast '
        '-c:a aac '
        '-movflags +faststart '
        '-y "$output"';

    await _run(concatCmd, 'speedConcat');

    // Clean up.
    await concatFile.delete();
    for (final f in partPaths) {
      try {
        await File(f).delete();
      } catch (_) {}
    }

    debugPrint('[applySpeedEffect] segmented → $output');
    return output;
  }

  // ════════════════════════════════════════════════════════════════════════
  // 7. INTRO / OUTRO
  // ════════════════════════════════════════════════════════════════════════

  /// Creates a branded intro or outro clip (solid background + centred text).
  ///
  /// Returns the path to the generated short clip. This can then be
  /// concatenated with the main clip.
  static Future<String> addIntroOutro({
    required String inputPath,
    IntroOutro? intro,
    IntroOutro? outro,
    String? outputPath,
  }) async {
    final dir = await _tempDir();
    final output = outputPath ?? _outPath(dir, 'intro_outro');

    final info = await getVideoInfo(inputPath);
    final w = info.width > 0 ? info.width : 1920;
    final h = info.height > 0 ? info.height : 1080;
    final fps = info.fps > 0 ? info.fps : 30;

    // Build list of clips to concatenate: [intro, main, outro].
    final parts = <String>[];

    if (intro != null) {
      final introPath = await _generateBrandedClip(
        text: intro.text,
        duration: intro.duration,
        bg: intro.backgroundColor,
        fg: intro.textColor,
        fontSize: intro.fontSize,
        width: w,
        height: h,
        fps: fps,
        dir: dir,
        label: 'intro',
      );
      parts.add(introPath);
    }

    parts.add(inputPath);

    if (outro != null) {
      final outroPath = await _generateBrandedClip(
        text: outro.text,
        duration: outro.duration,
        bg: outro.backgroundColor,
        fg: outro.textColor,
        fontSize: outro.fontSize,
        width: w,
        height: h,
        fps: fps,
        dir: dir,
        label: 'outro',
      );
      parts.add(outroPath);
    }

    if (parts.length == 1) {
      // No intro/outro provided – just copy.
      await _run('-i "$inputPath" -c copy -y "$output"', 'addIntroOutro');
      return output;
    }

    // Concat.
    final concatFile = File('$dir/_intro_concat_${DateTime.now().millisecondsSinceEpoch}.txt');
    await concatFile.writeAsString(
      parts.map((p) => "file '$p'").join('\n'),
    );

    final command = '-f concat -safe 0 -i "${concatFile.path}" '
        '-c:v libx264 -crf 18 -preset fast '
        '-c:a aac '
        '-movflags +faststart '
        '-y "$output"';

    await _run(command, 'addIntroOutroConcat');

    await concatFile.delete();
    // Clean up temp intro/outro files (keep main input intact).
    for (final p in parts) {
      if (p != inputPath) {
        try {
          await File(p).delete();
        } catch (_) {}
      }
    }

    debugPrint('[addIntroOutro] Output → $output');
    return output;
  }

  /// Generates a short clip with a solid background and centred text.
  static Future<String> _generateBrandedClip({
    required String text,
    required double duration,
    required String bg,
    required String fg,
    required int fontSize,
    required int width,
    required int height,
    required int fps,
    required String dir,
    required String label,
  }) async {
    final outPath = '$dir/_branded_${label}_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final escaped = _escapeText(text);
    final totalFrames = (duration * fps).round();

    final command = '-f lavfi -i "color=c=$bg:s=${width}x${height}:d=$duration:r=$fps" '
        '-f lavfi -i "anullsrc=channel_layout=stereo:sample_rate=44100" '
        '-vf "drawtext=text=\'$escaped\':'
        'fontsize=$fontSize:fontcolor=$fg:'
        'x=(w-text_w)/2:y=(h-text_h)/2:'
        'borderw=2:bordercolor=black@0.5" '
        '-t $duration '
        '-c:v libx264 -crf 18 -preset fast '
        '-c:a aac -shortest '
        '-movflags +faststart '
        '-y "$outPath"';

    await _run(command, 'generateBrandedClip($label)');
    return outPath;
  }

  // ════════════════════════════════════════════════════════════════════════
  // 8. EXPORT FINAL CLIP
  // ════════════════════════════════════════════════════════════════════════

  /// Combines all selected effects into a single final exported video.
  ///
  /// Effects are applied in this order:
  /// 1. Speed
  /// 2. Zoom
  /// 3. Color grading
  /// 4. Fade
  /// 5. Captions
  /// 6. SFX
  /// 7. Intro / Outro
  ///
  /// Each step writes an intermediate file which is cleaned up afterwards.
  static Future<String> exportFinalClip({
    required String inputPath,
    List<SpeedEffect>? speedEffects,
    ZoomEffect? zoomEffect,
    ColorGrade? colorGrade,
    double fadeInDuration = 0.5,
    double fadeOutDuration = 0.5,
    List<CaptionSegment>? captions,
    List<SFXTiming>? sfxTimings,
    IntroOutro? intro,
    IntroOutro? outro,
    ExportSettings settings = const ExportSettings(),
    String? outputPath,
  }) async {
    final dir = await _tempDir();
    final output = outputPath ?? _outPath(dir, 'final_clip');

    String current = inputPath;
    final tempFiles = <String>[];

    try {
      // 1 ── Speed
      if (speedEffects != null && speedEffects.isNotEmpty) {
        final next = _outPath(dir, 'step_speed');
        tempFiles.add(next);
        current = await applySpeedEffect(
          inputPath: current,
          effects: speedEffects,
          outputPath: next,
        );
      }

      // 2 ── Zoom
      if (zoomEffect != null) {
        final next = _outPath(dir, 'step_zoom');
        tempFiles.add(next);
        current = await applyZoomEffect(
          inputPath: current,
          effect: zoomEffect,
          outputPath: next,
        );
      }

      // 3 ── Color grading
      if (colorGrade != null) {
        final next = _outPath(dir, 'step_color');
        tempFiles.add(next);
        current = await applyColorGrading(
          inputPath: current,
          grade: colorGrade,
          outputPath: next,
        );
      }

      // 4 ── Fade
      if (fadeInDuration > 0 || fadeOutDuration > 0) {
        final next = _outPath(dir, 'step_fade');
        tempFiles.add(next);
        current = await applyFadeTransition(
          inputPath: current,
          fadeInDuration: fadeInDuration,
          fadeOutDuration: fadeOutDuration,
          outputPath: next,
        );
      }

      // 5 ── Captions
      if (captions != null && captions.isNotEmpty) {
        final next = _outPath(dir, 'step_captions');
        tempFiles.add(next);
        current = await addCaptions(
          inputPath: current,
          captions: captions,
          outputPath: next,
        );
      }

      // 6 ── SFX
      if (sfxTimings != null && sfxTimings.isNotEmpty) {
        final next = _outPath(dir, 'step_sfx');
        tempFiles.add(next);
        current = await addSFX(
          inputPath: current,
          sfxTimings: sfxTimings,
          outputPath: next,
        );
      }

      // 7 ── Intro / Outro
      if (intro != null || outro != null) {
        final next = _outPath(dir, 'step_introoutro');
        tempFiles.add(next);
        current = await addIntroOutro(
          inputPath: current,
          intro: intro,
          outro: outro,
          outputPath: next,
        );
      }

      // Final pass: scale & quality.
      final scaleFilter = settings.scaleString;
      final finalCommand = '-i "$current" '
          '-vf "scale=$scaleFilter:flags=lanczos" '
          '-c:v libx264 -crf ${settings.crf} -preset medium '
          '-r ${settings.fps} '
          '${settings.includeAudio ? '-c:a aac -b:a 192k' : '-an'} '
          '-movflags +faststart '
          '-y "$output"';

      await _run(finalCommand, 'exportFinalClip(final)');
    } finally {
      // Clean up all intermediate files.
      for (final f in tempFiles) {
        try {
          final file = File(f);
          if (await file.exists()) await file.delete();
        } catch (_) {}
      }
    }

    debugPrint('[exportFinalClip] Final output → $output');
    return output;
  }
}

// ── Internal helpers ───────────────────────────────────────────────────────

class _SpeedSegment {
  final double start;
  final double end;
  final double speed;

  const _SpeedSegment({
    required this.start,
    required this.end,
    required this.speed,
  });
}

// Re-export VideoInfo from editor service so consumers only need one import.
// If VideoInfo is already exported from video_editor_service.dart, this alias
// prevents duplicate-definition issues when both files are imported.
class VideoInfo {
  final String path;
  final double duration;
  final int width;
  final int height;
  final int fps;
  final double bitrate;
  final int fileSize;
  final bool hasAudio;

  const VideoInfo({
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
