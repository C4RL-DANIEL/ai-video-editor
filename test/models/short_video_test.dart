import 'package:flutter_test/flutter_test.dart';
import 'package:ai_video_editor/features/shorts/models/short_video.dart';

void main() {
  group('ShortVideoStatus', () {
    test('fromString returns correct enum value', () {
      expect(ShortVideoStatus.fromString('pending'), ShortVideoStatus.pending);
      expect(
          ShortVideoStatus.fromString('generating'), ShortVideoStatus.generating);
      expect(ShortVideoStatus.fromString('editing'), ShortVideoStatus.editing);
      expect(
          ShortVideoStatus.fromString('rendering'), ShortVideoStatus.rendering);
      expect(
          ShortVideoStatus.fromString('completed'), ShortVideoStatus.completed);
      expect(ShortVideoStatus.fromString('failed'), ShortVideoStatus.failed);
    });

    test('fromString returns pending for unknown value', () {
      expect(ShortVideoStatus.fromString('unknown'), ShortVideoStatus.pending);
    });
  });

  group('ShortCategory', () {
    test('fromString returns correct enum value', () {
      expect(ShortCategory.fromString('comedy'), ShortCategory.comedy);
      expect(
          ShortCategory.fromString('informative'), ShortCategory.informative);
      expect(ShortCategory.fromString('storyTime'), ShortCategory.storyTime);
      expect(ShortCategory.fromString('reaction'), ShortCategory.reaction);
      expect(ShortCategory.fromString('tutorial'), ShortCategory.tutorial);
      expect(ShortCategory.fromString('highlights'), ShortCategory.highlights);
      expect(
          ShortCategory.fromString('motivational'), ShortCategory.motivational);
      expect(ShortCategory.fromString('horror'), ShortCategory.horror);
      expect(ShortCategory.fromString('gaming'), ShortCategory.gaming);
      expect(ShortCategory.fromString('news'), ShortCategory.news);
      expect(ShortCategory.fromString('other'), ShortCategory.other);
    });

    test('fromString returns other for unknown value', () {
      expect(ShortCategory.fromString('unknown'), ShortCategory.other);
    });
  });

  group('EditingStyle', () {
    test('fromString returns correct enum value', () {
      expect(EditingStyle.fromString('minimal'), EditingStyle.minimal);
      expect(EditingStyle.fromString('dynamic'), EditingStyle.dynamic);
      expect(EditingStyle.fromString('cinematic'), EditingStyle.cinematic);
      expect(EditingStyle.fromString('meme'), EditingStyle.meme);
      expect(EditingStyle.fromString('documentary'), EditingStyle.documentary);
      expect(EditingStyle.fromString('podcast'), EditingStyle.podcast);
      expect(EditingStyle.fromString('sports'), EditingStyle.sports);
      expect(EditingStyle.fromString('musicVideo'), EditingStyle.musicVideo);
    });

    test('fromString returns dynamic for unknown value', () {
      expect(EditingStyle.fromString('unknown'), EditingStyle.dynamic);
    });
  });

  group('CaptionPosition', () {
    test('fromString returns correct enum value', () {
      expect(CaptionPosition.fromString('top'), CaptionPosition.top);
      expect(CaptionPosition.fromString('center'), CaptionPosition.center);
      expect(CaptionPosition.fromString('bottom'), CaptionPosition.bottom);
      expect(CaptionPosition.fromString('topLeft'), CaptionPosition.topLeft);
      expect(CaptionPosition.fromString('topRight'), CaptionPosition.topRight);
      expect(
          CaptionPosition.fromString('bottomLeft'), CaptionPosition.bottomLeft);
      expect(CaptionPosition.fromString('bottomRight'),
          CaptionPosition.bottomRight);
    });

    test('fromString returns bottom for unknown value', () {
      expect(CaptionPosition.fromString('unknown'), CaptionPosition.bottom);
    });
  });

  group('CaptionStyle', () {
    test('creates with default values', () {
      const style = CaptionStyle();
      expect(style.fontFamily, null);
      expect(style.fontSize, 24.0);
      expect(style.color, '#FFFFFF');
      expect(style.backgroundColor, null);
      expect(style.backgroundOpacity, null);
      expect(style.isBold, true);
      expect(style.isItalic, false);
      expect(style.shadowBlur, null);
      expect(style.shadowColor, '#000000');
    });

    test('creates with all parameters', () {
      const style = CaptionStyle(
        fontFamily: 'Arial',
        fontSize: 32.0,
        color: '#FF0000',
        backgroundColor: '#000000',
        backgroundOpacity: 0.8,
        isBold: false,
        isItalic: true,
        shadowBlur: 4.0,
        shadowColor: '#888888',
      );
      expect(style.fontFamily, 'Arial');
      expect(style.fontSize, 32.0);
      expect(style.color, '#FF0000');
      expect(style.backgroundColor, '#000000');
      expect(style.backgroundOpacity, 0.8);
      expect(style.isBold, false);
      expect(style.isItalic, true);
      expect(style.shadowBlur, 4.0);
      expect(style.shadowColor, '#888888');
    });

    test('fromJson/toJson round-trip', () {
      const original = CaptionStyle(
        fontFamily: 'Roboto',
        fontSize: 28.0,
        color: '#FFFF00',
        backgroundColor: '#333333',
        backgroundOpacity: 0.5,
        isBold: false,
        isItalic: true,
        shadowBlur: 2.0,
        shadowColor: '#111111',
      );

      final json = original.toJson();
      final restored = CaptionStyle.fromJson(json);

      expect(restored.fontFamily, original.fontFamily);
      expect(restored.fontSize, original.fontSize);
      expect(restored.color, original.color);
      expect(restored.backgroundColor, original.backgroundColor);
      expect(restored.backgroundOpacity, original.backgroundOpacity);
      expect(restored.isBold, original.isBold);
      expect(restored.isItalic, original.isItalic);
      expect(restored.shadowBlur, original.shadowBlur);
      expect(restored.shadowColor, original.shadowColor);
    });

    test('fromJson handles missing fields with defaults', () {
      final style = CaptionStyle.fromJson({});
      expect(style.fontFamily, null);
      expect(style.fontSize, 24.0);
      expect(style.color, '#FFFFFF');
      expect(style.isBold, true);
      expect(style.isItalic, false);
    });

    test('copyWith updates selected fields', () {
      const original = CaptionStyle();
      final updated = original.copyWith(
        fontSize: 40.0,
        isBold: false,
      );
      expect(updated.fontSize, 40.0);
      expect(updated.isBold, false);
      expect(updated.color, '#FFFFFF');
      expect(updated.fontFamily, null);
    });

    test('copyWith clears nullable fields', () {
      const original = CaptionStyle(
        fontFamily: 'Arial',
        backgroundColor: '#000',
        backgroundOpacity: 0.5,
        shadowBlur: 2.0,
        shadowColor: '#111',
      );
      final cleared = original.copyWith(
        clearFontFamily: true,
        clearBackgroundColor: true,
        clearBackgroundOpacity: true,
        clearShadowBlur: true,
        clearShadowColor: true,
      );
      expect(cleared.fontFamily, null);
      expect(cleared.backgroundColor, null);
      expect(cleared.backgroundOpacity, null);
      expect(cleared.shadowBlur, null);
      expect(cleared.shadowColor, null);
    });

    test('toString returns formatted string', () {
      const style = CaptionStyle(fontFamily: 'Arial', fontSize: 32, isBold: false);
      expect(style.toString(), contains('Arial'));
      expect(style.toString(), contains('32'));
    });
  });

  group('CaptionEntry', () {
    test('creates with required parameters and defaults', () {
      const entry = CaptionEntry(text: 'Hello', startTime: 0.0, endTime: 2.0);
      expect(entry.text, 'Hello');
      expect(entry.startTime, 0.0);
      expect(entry.endTime, 2.0);
      expect(entry.position, CaptionPosition.bottom);
      expect(entry.style, isA<CaptionStyle>());
      expect(entry.keywords, isEmpty);
      expect(entry.isEmphasized, false);
    });

    test('creates with all parameters', () {
      const entry = CaptionEntry(
        text: 'World',
        startTime: 1.0,
        endTime: 3.5,
        position: CaptionPosition.topLeft,
        style: CaptionStyle(fontSize: 36),
        keywords: ['important', 'bold'],
        isEmphasized: true,
      );
      expect(entry.position, CaptionPosition.topLeft);
      expect(entry.style.fontSize, 36);
      expect(entry.keywords, ['important', 'bold']);
      expect(entry.isEmphasized, true);
    });

    test('fromJson/toJson round-trip', () {
      const original = CaptionEntry(
        text: 'Round trip',
        startTime: 5.0,
        endTime: 10.0,
        position: CaptionPosition.center,
        style: CaptionStyle(fontFamily: 'Mono', fontSize: 18),
        keywords: ['a', 'b'],
        isEmphasized: true,
      );

      final json = original.toJson();
      final restored = CaptionEntry.fromJson(json);

      expect(restored.text, original.text);
      expect(restored.startTime, original.startTime);
      expect(restored.endTime, original.endTime);
      expect(restored.position, original.position);
      expect(restored.style.fontFamily, original.style.fontFamily);
      expect(restored.keywords, original.keywords);
      expect(restored.isEmphasized, original.isEmphasized);
    });

    test('fromJson handles missing fields with defaults', () {
      final entry = CaptionEntry.fromJson({});
      expect(entry.text, '');
      expect(entry.startTime, 0.0);
      expect(entry.endTime, 0.0);
      expect(entry.position, CaptionPosition.bottom);
      expect(entry.keywords, isEmpty);
      expect(entry.isEmphasized, false);
    });

    test('copyWith updates selected fields', () {
      const original = CaptionEntry(
          text: 'Old', startTime: 0.0, endTime: 2.0);
      final updated = original.copyWith(text: 'New', startTime: 5.0);
      expect(updated.text, 'New');
      expect(updated.startTime, 5.0);
      expect(updated.endTime, 2.0);
    });

    test('duration getter computes end - start', () {
      const entry =
          CaptionEntry(text: 'Hi', startTime: 3.0, endTime: 7.0);
      expect(entry.duration, 4.0);
    });

    test('toString returns formatted string', () {
      const entry =
          CaptionEntry(text: 'Test', startTime: 1.0, endTime: 3.0);
      final str = entry.toString();
      expect(str, contains('Test'));
      expect(str, contains('1.0'));
      expect(str, contains('3.0'));
    });
  });

  group('AudioConfig', () {
    test('creates with default values', () {
      const config = AudioConfig();
      expect(config.commentaryVolume, 1.0);
      expect(config.musicVolume, 0.3);
      expect(config.sfxVolume, 0.5);
      expect(config.duckingEnabled, true);
    });

    test('creates with all parameters', () {
      const config = AudioConfig(
        commentaryVolume: 0.8,
        musicVolume: 0.5,
        sfxVolume: 0.7,
        duckingEnabled: false,
      );
      expect(config.commentaryVolume, 0.8);
      expect(config.musicVolume, 0.5);
      expect(config.sfxVolume, 0.7);
      expect(config.duckingEnabled, false);
    });

    test('fromJson/toJson round-trip', () {
      const original = AudioConfig(
        commentaryVolume: 0.6,
        musicVolume: 0.4,
        sfxVolume: 0.9,
        duckingEnabled: false,
      );

      final json = original.toJson();
      final restored = AudioConfig.fromJson(json);

      expect(restored.commentaryVolume, original.commentaryVolume);
      expect(restored.musicVolume, original.musicVolume);
      expect(restored.sfxVolume, original.sfxVolume);
      expect(restored.duckingEnabled, original.duckingEnabled);
    });

    test('fromJson handles missing fields with defaults', () {
      final config = AudioConfig.fromJson({});
      expect(config.commentaryVolume, 1.0);
      expect(config.musicVolume, 0.3);
      expect(config.sfxVolume, 0.5);
      expect(config.duckingEnabled, true);
    });

    test('copyWith updates selected fields', () {
      const original = AudioConfig();
      final updated =
          original.copyWith(musicVolume: 0.8, duckingEnabled: false);
      expect(updated.musicVolume, 0.8);
      expect(updated.duckingEnabled, false);
      expect(updated.commentaryVolume, 1.0);
      expect(updated.sfxVolume, 0.5);
    });

    test('toString returns formatted string', () {
      const config = AudioConfig(
          commentaryVolume: 0.8, musicVolume: 0.5, sfxVolume: 0.7);
      final str = config.toString();
      expect(str, contains('0.8'));
      expect(str, contains('0.5'));
      expect(str, contains('0.7'));
    });
  });

  group('EditDecisionEntry', () {
    test('creates with required parameters', () {
      const entry = EditDecisionEntry(
          type: 'cut', startTime: 0.0, endTime: 5.0);
      expect(entry.type, 'cut');
      expect(entry.startTime, 0.0);
      expect(entry.endTime, 5.0);
      expect(entry.params, null);
    });

    test('fromJson/toJson round-trip', () {
      const original = EditDecisionEntry(
        type: 'zoom',
        startTime: 2.0,
        endTime: 8.0,
        params: {'level': 2.0},
      );

      final json = original.toJson();
      final restored = EditDecisionEntry.fromJson(json);

      expect(restored.type, original.type);
      expect(restored.startTime, original.startTime);
      expect(restored.endTime, original.endTime);
      expect(restored.params, original.params);
    });

    test('fromJson handles missing fields with defaults', () {
      final entry = EditDecisionEntry.fromJson({});
      expect(entry.type, '');
      expect(entry.startTime, 0.0);
      expect(entry.endTime, 0.0);
      expect(entry.params, null);
    });

    test('toString returns formatted string', () {
      const entry = EditDecisionEntry(
          type: 'sfx', startTime: 1.0, endTime: 3.0);
      final str = entry.toString();
      expect(str, contains('sfx'));
      expect(str, contains('1.0'));
      expect(str, contains('3.0'));
    });
  });

  group('ShortVersion', () {
    test('creates with required parameters and defaults', () {
      final now = DateTime(2024, 1, 1);
      const version = ShortVersion(versionNumber: 1, createdAt: _ConstDateTime());

      expect(version.versionNumber, 1);
      expect(version.videoUrl, null);
      expect(version.editDecisions, isEmpty);
      expect(version.score, null);
    });

    test('creates with all parameters', () {
      const version = ShortVersion(
        versionNumber: 3,
        videoUrl: 'https://example.com/video.mp4',
        editDecisions: [
          EditDecisionEntry(type: 'cut', startTime: 0.0, endTime: 5.0),
        ],
        score: 8.5,
        createdAt: _ConstDateTime(),
      );

      expect(version.versionNumber, 3);
      expect(version.videoUrl, 'https://example.com/video.mp4');
      expect(version.editDecisions.length, 1);
      expect(version.score, 8.5);
    });

    test('fromJson/toJson round-trip', () {
      final now = DateTime(2024, 6, 15, 12, 0);
      final original = ShortVersion(
        versionNumber: 2,
        videoUrl: 'https://example.com/v2.mp4',
        editDecisions: const [
          EditDecisionEntry(type: 'cut', startTime: 0.0, endTime: 5.0),
        ],
        score: 7.5,
        createdAt: now,
      );

      final json = original.toJson();
      final restored = ShortVersion.fromJson(json);

      expect(restored.versionNumber, original.versionNumber);
      expect(restored.videoUrl, original.videoUrl);
      expect(restored.editDecisions.length, original.editDecisions.length);
      expect(restored.score, original.score);
      expect(restored.createdAt, original.createdAt);
    });

    test('fromJson handles missing fields with defaults', () {
      final version = ShortVersion.fromJson({});
      expect(version.versionNumber, 1);
      expect(version.videoUrl, null);
      expect(version.editDecisions, isEmpty);
      expect(version.score, null);
      expect(version.createdAt, isA<DateTime>());
    });

    test('copyWith updates selected fields', () {
      final now = DateTime(2024, 1, 1);
      final original = ShortVersion(versionNumber: 1, createdAt: now);
      final updated = original.copyWith(
        versionNumber: 2,
        score: 9.0,
      );
      expect(updated.versionNumber, 2);
      expect(updated.score, 9.0);
      expect(updated.createdAt, now);
    });

    test('copyWith clears nullable fields', () {
      final now = DateTime(2024, 1, 1);
      final original = ShortVersion(
        versionNumber: 1,
        videoUrl: 'https://example.com/v.mp4',
        score: 8.0,
        createdAt: now,
      );
      final cleared = original.copyWith(
        clearVideoUrl: true,
        clearScore: true,
      );
      expect(cleared.videoUrl, null);
      expect(cleared.score, null);
      expect(cleared.versionNumber, 1);
    });

    test('hasVideo returns true when videoUrl is non-empty', () {
      const version =
          ShortVersion(versionNumber: 1, videoUrl: 'https://example.com/v.mp4', createdAt: _ConstDateTime());
      expect(version.hasVideo, true);
    });

    test('hasVideo returns false when videoUrl is null', () {
      const version =
          ShortVersion(versionNumber: 1, createdAt: _ConstDateTime());
      expect(version.hasVideo, false);
    });

    test('toString returns formatted string', () {
      const version =
          ShortVersion(versionNumber: 2, score: 8.5, createdAt: _ConstDateTime());
      final str = version.toString();
      expect(str, contains('v2'));
      expect(str, contains('8.50'));
    });
  });

  group('ShortVideo', () {
    // Helper to create a test ShortVideo
    ShortVideo createTestVideo({
      String id = 'sv-1',
      String title = 'Test Short',
      double duration = 45.0,
      double targetDuration = 60.0,
      ShortVideoStatus status = ShortVideoStatus.pending,
      double hookScore = 7.5,
      double viralScore = 8.0,
      ShortCategory category = ShortCategory.comedy,
      EditingStyle editingStyle = EditingStyle.dynamic,
      double estimatedRetention = 0.65,
      String? hookText = 'Check this out!',
      String? commentaryText = 'Amazing video',
      String? thumbnailUrl = 'https://example.com/thumb.jpg',
    }) {
      return ShortVideo(
        id: id,
        projectId: 'proj-1',
        momentId: 'moment-1',
        title: title,
        duration: duration,
        targetDuration: targetDuration,
        hookText: hookText,
        status: status,
        hookScore: hookScore,
        viralScore: viralScore,
        category: category,
        sourceTimestamp: 120.0,
        editingStyle: editingStyle,
        estimatedRetention: estimatedRetention,
        commentaryText: commentaryText,
        thumbnailUrl: thumbnailUrl,
      );
    }

    test('creates with required parameters and defaults', () {
      final video = ShortVideo(
        id: 'v1',
        projectId: 'p1',
        momentId: 'm1',
        title: 'Test',
        duration: 30.0,
        targetDuration: 60.0,
        status: ShortVideoStatus.pending,
        category: ShortCategory.other,
        sourceTimestamp: 0.0,
        editingStyle: EditingStyle.dynamic,
      );

      expect(video.id, 'v1');
      expect(video.hookScore, 0.0);
      expect(video.viralScore, 0.0);
      expect(video.estimatedRetention, 0.0);
      expect(video.versions, isEmpty);
      expect(video.captions, isEmpty);
      expect(video.hookText, null);
      expect(video.commentaryText, null);
      expect(video.thumbnailUrl, null);
      expect(video.audioConfig, isA<AudioConfig>());
    });

    test('fromJson/toJson round-trip', () {
      final original = createTestVideo();

      final json = original.toJson();
      final restored = ShortVideo.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.projectId, original.projectId);
      expect(restored.momentId, original.momentId);
      expect(restored.title, original.title);
      expect(restored.duration, original.duration);
      expect(restored.targetDuration, original.targetDuration);
      expect(restored.hookText, original.hookText);
      expect(restored.status, original.status);
      expect(restored.hookScore, original.hookScore);
      expect(restored.viralScore, original.viralScore);
      expect(restored.category, original.category);
      expect(restored.sourceTimestamp, original.sourceTimestamp);
      expect(restored.editingStyle, original.editingStyle);
      expect(restored.estimatedRetention, original.estimatedRetention);
      expect(restored.commentaryText, original.commentaryText);
      expect(restored.thumbnailUrl, original.thumbnailUrl);
    });

    test('fromJson handles missing fields with defaults', () {
      final video = ShortVideo.fromJson({});
      expect(video.id, '');
      expect(video.projectId, '');
      expect(video.momentId, '');
      expect(video.title, '');
      expect(video.duration, 0.0);
      expect(video.targetDuration, 60.0);
      expect(video.status, ShortVideoStatus.pending);
      expect(video.hookScore, 0.0);
      expect(video.viralScore, 0.0);
      expect(video.category, ShortCategory.other);
      expect(video.editingStyle, EditingStyle.dynamic);
      expect(video.estimatedRetention, 0.0);
    });

    test('copyWith updates selected fields', () {
      final original = createTestVideo();
      final updated = original.copyWith(
        title: 'Updated Title',
        viralScore: 9.5,
        status: ShortVideoStatus.completed,
      );
      expect(updated.title, 'Updated Title');
      expect(updated.viralScore, 9.5);
      expect(updated.status, ShortVideoStatus.completed);
      expect(updated.id, original.id);
      expect(updated.hookScore, original.hookScore);
    });

    test('copyWith clears nullable fields', () {
      final original = createTestVideo();
      final cleared = original.copyWith(
        clearHookText: true,
        clearCommentaryText: true,
        clearThumbnailUrl: true,
      );
      expect(cleared.hookText, null);
      expect(cleared.commentaryText, null);
      expect(cleared.thumbnailUrl, null);
    });

    test('versionCount returns number of versions', () {
      final video = createTestVideo().copyWith(versions: [
        const ShortVersion(
            versionNumber: 1, createdAt: _ConstDateTime()),
        ShortVersion(
            versionNumber: 2, createdAt: DateTime(2024, 1, 2)),
      ]);
      expect(video.versionCount, 2);
    });

    test('latestVersion returns last version', () {
      final v1 =
          ShortVersion(versionNumber: 1, createdAt: DateTime(2024, 1, 1));
      final v2 =
          ShortVersion(versionNumber: 2, createdAt: DateTime(2024, 1, 2));
      final video = createTestVideo().copyWith(versions: [v1, v2]);
      expect(video.latestVersion?.versionNumber, 2);
    });

    test('latestVersion returns null when no versions', () {
      final video = createTestVideo();
      expect(video.latestVersion, null);
    });

    test('durationFormatted formats correctly', () {
      final video = createTestVideo(duration: 90.0);
      expect(video.durationFormatted, '1:30');
    });

    test('durationFormatted pads seconds', () {
      final video = createTestVideo(duration: 65.0);
      expect(video.durationFormatted, '1:05');
    });

    test('durationFormatted shows 0:00 for zero duration', () {
      final video = createTestVideo(duration: 0.0);
      expect(video.durationFormatted, '0:00');
    });

    test('equality is based on id', () {
      final v1 = createTestVideo(id: 'same-id', title: 'Title 1');
      final v2 = createTestVideo(id: 'same-id', title: 'Title 2');
      expect(v1 == v2, true);
      expect(v1.hashCode, v2.hashCode);
    });

    test('inequality for different ids', () {
      final v1 = createTestVideo(id: 'id-1');
      final v2 = createTestVideo(id: 'id-2');
      expect(v1 == v2, false);
    });

    test('toString contains key info', () {
      final video = createTestVideo(id: 'v1', title: 'Test');
      final str = video.toString();
      expect(str, contains('v1'));
      expect(str, contains('Test'));
      expect(str, contains('8.00'));
    });
  });
}

/// Helper for const ShortVersion createdAt
class _ConstDateTime extends DateTime {
  const _ConstDateTime() : super.utc(2024, 1, 1);
}
