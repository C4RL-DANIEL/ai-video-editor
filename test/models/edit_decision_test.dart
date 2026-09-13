import 'package:flutter_test/flutter_test.dart';
import 'package:ai_video_editor/features/editor/models/edit_decision.dart';

void main() {
  group('EditDecisionType', () {
    test('fromString returns correct enum value', () {
      expect(EditDecisionType.fromString('cut'), EditDecisionType.cut);
      expect(EditDecisionType.fromString('zoom'), EditDecisionType.zoom);
      expect(EditDecisionType.fromString('overlay'), EditDecisionType.overlay);
      expect(EditDecisionType.fromString('speed'), EditDecisionType.speed);
      expect(EditDecisionType.fromString('caption'), EditDecisionType.caption);
      expect(EditDecisionType.fromString('sfx'), EditDecisionType.sfx);
      expect(
          EditDecisionType.fromString('transition'), EditDecisionType.transition);
      expect(EditDecisionType.fromString('effect'), EditDecisionType.effect);
    });

    test('fromString returns cut for unknown value', () {
      expect(EditDecisionType.fromString('unknown'), EditDecisionType.cut);
    });
  });

  group('TrackType', () {
    test('fromString returns correct enum value', () {
      expect(TrackType.fromString('video'), TrackType.video);
      expect(TrackType.fromString('audio'), TrackType.audio);
      expect(TrackType.fromString('caption'), TrackType.caption);
      expect(TrackType.fromString('overlay'), TrackType.overlay);
      expect(TrackType.fromString('effect'), TrackType.effect);
    });

    test('fromString returns video for unknown value', () {
      expect(TrackType.fromString('unknown'), TrackType.video);
    });
  });

  group('EditParams', () {
    test('creates with all null defaults', () {
      const params = EditParams();
      expect(params.trimStart, null);
      expect(params.trimEnd, null);
      expect(params.zoomLevel, null);
      expect(params.zoomX, null);
      expect(params.zoomY, null);
      expect(params.overlayType, null);
      expect(params.overlayUrl, null);
      expect(params.overlayX, null);
      expect(params.overlayY, null);
      expect(params.overlayWidth, null);
      expect(params.overlayHeight, null);
      expect(params.overlayOpacity, null);
      expect(params.speedMultiplier, null);
      expect(params.captionText, null);
      expect(params.captionFont, null);
      expect(params.captionFontSize, null);
      expect(params.captionColor, null);
      expect(params.sfxType, null);
      expect(params.sfxUrl, null);
      expect(params.sfxVolume, null);
      expect(params.transitionType, null);
      expect(params.transitionDuration, null);
      expect(params.effectParams, null);
    });

    test('creates with all parameters', () {
      const params = EditParams(
        trimStart: 1.0,
        trimEnd: 5.0,
        zoomLevel: 2.0,
        zoomX: 100.0,
        zoomY: 200.0,
        overlayType: 'logo',
        overlayUrl: 'https://example.com/logo.png',
        overlayX: 10.0,
        overlayY: 20.0,
        overlayWidth: 100.0,
        overlayHeight: 50.0,
        overlayOpacity: 0.8,
        speedMultiplier: 1.5,
        captionText: 'Hello',
        captionFont: 'Arial',
        captionFontSize: 24.0,
        captionColor: '#FFFFFF',
        sfxType: 'whoosh',
        sfxUrl: 'https://example.com/whoosh.mp3',
        sfxVolume: 0.7,
        transitionType: 'fade',
        transitionDuration: 0.5,
        effectParams: {'brightness': 1.2},
      );
      expect(params.trimStart, 1.0);
      expect(params.trimEnd, 5.0);
      expect(params.zoomLevel, 2.0);
      expect(params.speedMultiplier, 1.5);
      expect(params.captionText, 'Hello');
      expect(params.sfxType, 'whoosh');
      expect(params.transitionType, 'fade');
      expect(params.effectParams, {'brightness': 1.2});
    });

    test('fromJson/toJson round-trip', () {
      const original = EditParams(
        trimStart: 1.0,
        trimEnd: 5.0,
        zoomLevel: 2.0,
        speedMultiplier: 1.5,
        captionText: 'Test',
        transitionType: 'fade',
        transitionDuration: 0.5,
        effectParams: {'key': 'value'},
      );

      final json = original.toJson();
      final restored = EditParams.fromJson(json);

      expect(restored.trimStart, original.trimStart);
      expect(restored.trimEnd, original.trimEnd);
      expect(restored.zoomLevel, original.zoomLevel);
      expect(restored.speedMultiplier, original.speedMultiplier);
      expect(restored.captionText, original.captionText);
      expect(restored.transitionType, original.transitionType);
      expect(restored.transitionDuration, original.transitionDuration);
      expect(restored.effectParams, original.effectParams);
    });

    test('toJson only includes non-null fields', () {
      const params = EditParams(trimStart: 1.0, captionText: 'Hello');
      final json = params.toJson();
      expect(json.containsKey('trimStart'), true);
      expect(json.containsKey('captionText'), true);
      expect(json.containsKey('trimEnd'), false);
      expect(json.containsKey('zoomLevel'), false);
      expect(json.containsKey('speedMultiplier'), false);
    });

    test('fromJson handles empty JSON', () {
      final params = EditParams.fromJson({});
      expect(params.trimStart, null);
      expect(params.trimEnd, null);
      expect(params.zoomLevel, null);
      expect(params.speedMultiplier, null);
      expect(params.effectParams, null);
    });

    test('copyWith updates selected fields', () {
      const original = EditParams(trimStart: 1.0, captionText: 'Old');
      final updated = original.copyWith(
        trimStart: 2.0,
        captionText: 'New',
        speedMultiplier: 2.0,
      );
      expect(updated.trimStart, 2.0);
      expect(updated.captionText, 'New');
      expect(updated.speedMultiplier, 2.0);
      expect(updated.trimEnd, null);
    });

    test('copyWith clears nullable fields', () {
      const original = EditParams(
        trimStart: 1.0,
        trimEnd: 5.0,
        zoomLevel: 2.0,
        overlayUrl: 'https://example.com/overlay.png',
        captionText: 'Hello',
        sfxUrl: 'https://example.com/sfx.mp3',
        transitionType: 'fade',
        transitionDuration: 0.5,
        effectParams: {'key': 'value'},
      );

      final cleared = original.copyWith(
        clearTrimStart: true,
        clearTrimEnd: true,
        clearZoomLevel: true,
        clearOverlayUrl: true,
        clearCaptionText: true,
        clearSfxUrl: true,
        clearTransitionType: true,
        clearTransitionDuration: true,
        clearEffectParams: true,
      );

      expect(cleared.trimStart, null);
      expect(cleared.trimEnd, null);
      expect(cleared.zoomLevel, null);
      expect(cleared.overlayUrl, null);
      expect(cleared.captionText, null);
      expect(cleared.sfxUrl, null);
      expect(cleared.transitionType, null);
      expect(cleared.transitionDuration, null);
      expect(cleared.effectParams, null);
    });

    test('toString contains JSON representation', () {
      const params = EditParams(trimStart: 1.0, captionText: 'Hello');
      final str = params.toString();
      expect(str, contains('trimStart'));
      expect(str, contains('1.0'));
      expect(str, contains('Hello'));
    });
  });

  group('EditDecision', () {
    test('creates with required parameters and defaults', () {
      const decision = EditDecision(
        id: 'ed-1',
        type: EditDecisionType.cut,
        startTime: 0.0,
        endTime: 5.0,
      );

      expect(decision.id, 'ed-1');
      expect(decision.type, EditDecisionType.cut);
      expect(decision.startTime, 0.0);
      expect(decision.endTime, 5.0);
      expect(decision.params, isA<EditParams>());
      expect(decision.confidence, 1.0);
      expect(decision.reasoning, '');
    });

    test('creates with all parameters', () {
      const decision = EditDecision(
        id: 'ed-2',
        type: EditDecisionType.zoom,
        startTime: 2.0,
        endTime: 8.0,
        params: EditParams(zoomLevel: 2.0),
        confidence: 0.9,
        reasoning: 'Subject detected',
      );

      expect(decision.params.zoomLevel, 2.0);
      expect(decision.confidence, 0.9);
      expect(decision.reasoning, 'Subject detected');
    });

    test('fromJson/toJson round-trip', () {
      const original = EditDecision(
        id: 'ed-3',
        type: EditDecisionType.transition,
        startTime: 5.0,
        endTime: 6.0,
        params: EditParams(
          transitionType: 'fade',
          transitionDuration: 1.0,
        ),
        confidence: 0.85,
        reasoning: 'Scene change',
      );

      final json = original.toJson();
      final restored = EditDecision.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.type, original.type);
      expect(restored.startTime, original.startTime);
      expect(restored.endTime, original.endTime);
      expect(restored.params.transitionType, 'fade');
      expect(restored.params.transitionDuration, 1.0);
      expect(restored.confidence, original.confidence);
      expect(restored.reasoning, original.reasoning);
    });

    test('fromJson handles missing fields with defaults', () {
      final decision = EditDecision.fromJson({});
      expect(decision.id, '');
      expect(decision.type, EditDecisionType.cut);
      expect(decision.startTime, 0.0);
      expect(decision.endTime, 0.0);
      expect(decision.confidence, 1.0);
      expect(decision.reasoning, '');
    });

    test('fromJson handles all edit types', () {
      for (final type in EditDecisionType.values) {
        final json = {'id': '1', 'type': type.name};
        final decision = EditDecision.fromJson(json);
        expect(decision.type, type);
      }
    });

    test('copyWith updates selected fields', () {
      const original = EditDecision(
        id: 'ed-1',
        type: EditDecisionType.cut,
        startTime: 0.0,
        endTime: 5.0,
      );

      final updated = original.copyWith(
        type: EditDecisionType.zoom,
        confidence: 0.7,
      );

      expect(updated.type, EditDecisionType.zoom);
      expect(updated.confidence, 0.7);
      expect(updated.id, 'ed-1');
      expect(updated.startTime, 0.0);
    });

    test('duration getter computes end - start', () {
      const decision = EditDecision(
        id: 'ed-1',
        type: EditDecisionType.cut,
        startTime: 3.0,
        endTime: 10.0,
      );
      expect(decision.duration, 7.0);
    });

    test('equality is based on id', () {
      const d1 = EditDecision(
        id: 'same-id',
        type: EditDecisionType.cut,
        startTime: 0.0,
        endTime: 5.0,
      );
      const d2 = EditDecision(
        id: 'same-id',
        type: EditDecisionType.zoom,
        startTime: 10.0,
        endTime: 20.0,
      );
      expect(d1 == d2, true);
      expect(d1.hashCode, d2.hashCode);
    });

    test('inequality for different ids', () {
      const d1 = EditDecision(
        id: 'id-1',
        type: EditDecisionType.cut,
        startTime: 0.0,
        endTime: 5.0,
      );
      const d2 = EditDecision(
        id: 'id-2',
        type: EditDecisionType.cut,
        startTime: 0.0,
        endTime: 5.0,
      );
      expect(d1 == d2, false);
    });

    test('toString contains key info', () {
      const decision = EditDecision(
        id: 'ed-1',
        type: EditDecisionType.zoom,
        startTime: 1.0,
        endTime: 3.0,
      );
      final str = decision.toString();
      expect(str, contains('ed-1'));
      expect(str, contains('zoom'));
      expect(str, contains('1.0'));
      expect(str, contains('3.0'));
    });
  });

  group('TimelineClip', () {
    test('creates with required parameters and defaults', () {
      const clip = TimelineClip(
        id: 'clip-1',
        trackId: 'track-1',
        sourceStartTime: 0.0,
        sourceEndTime: 10.0,
        timelineStartTime: 0.0,
        timelineEndTime: 10.0,
      );

      expect(clip.id, 'clip-1');
      expect(clip.trackId, 'track-1');
      expect(clip.sourceStartTime, 0.0);
      expect(clip.sourceEndTime, 10.0);
      expect(clip.timelineStartTime, 0.0);
      expect(clip.timelineEndTime, 10.0);
      expect(clip.effects, isEmpty);
      expect(clip.transitions, isEmpty);
    });

    test('creates with effects and transitions', () {
      const effect = EditDecision(
        id: 'eff-1',
        type: EditDecisionType.effect,
        startTime: 0.0,
        endTime: 5.0,
      );
      const transition = EditDecision(
        id: 'tr-1',
        type: EditDecisionType.transition,
        startTime: 5.0,
        endTime: 6.0,
      );

      const clip = TimelineClip(
        id: 'clip-1',
        trackId: 'track-1',
        sourceStartTime: 0.0,
        sourceEndTime: 10.0,
        timelineStartTime: 0.0,
        timelineEndTime: 10.0,
        effects: [effect],
        transitions: [transition],
      );

      expect(clip.effects.length, 1);
      expect(clip.transitions.length, 1);
    });

    test('fromJson/toJson round-trip', () {
      final original = TimelineClip(
        id: 'clip-2',
        trackId: 'track-2',
        sourceStartTime: 5.0,
        sourceEndTime: 15.0,
        timelineStartTime: 10.0,
        timelineEndTime: 20.0,
        effects: const [
          EditDecision(
            id: 'eff-1',
            type: EditDecisionType.zoom,
            startTime: 10.0,
            endTime: 15.0,
          ),
        ],
        transitions: const [
          EditDecision(
            id: 'tr-1',
            type: EditDecisionType.transition,
            startTime: 15.0,
            endTime: 16.0,
          ),
        ],
      );

      final json = original.toJson();
      final restored = TimelineClip.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.trackId, original.trackId);
      expect(restored.sourceStartTime, original.sourceStartTime);
      expect(restored.sourceEndTime, original.sourceEndTime);
      expect(restored.timelineStartTime, original.timelineStartTime);
      expect(restored.timelineEndTime, original.timelineEndTime);
      expect(restored.effects.length, 1);
      expect(restored.transitions.length, 1);
      expect(restored.effects[0].type, EditDecisionType.zoom);
    });

    test('fromJson handles missing fields with defaults', () {
      final clip = TimelineClip.fromJson({});
      expect(clip.id, '');
      expect(clip.trackId, '');
      expect(clip.sourceStartTime, 0.0);
      expect(clip.sourceEndTime, 0.0);
      expect(clip.timelineStartTime, 0.0);
      expect(clip.timelineEndTime, 0.0);
      expect(clip.effects, isEmpty);
      expect(clip.transitions, isEmpty);
    });

    test('copyWith updates selected fields', () {
      const original = TimelineClip(
        id: 'clip-1',
        trackId: 'track-1',
        sourceStartTime: 0.0,
        sourceEndTime: 10.0,
        timelineStartTime: 0.0,
        timelineEndTime: 10.0,
      );

      final updated = original.copyWith(
        id: 'clip-new',
        timelineEndTime: 15.0,
      );

      expect(updated.id, 'clip-new');
      expect(updated.timelineEndTime, 15.0);
      expect(updated.trackId, 'track-1');
      expect(updated.sourceStartTime, 0.0);
    });

    test('timelineDuration computes timeline end - start', () {
      const clip = TimelineClip(
        id: 'clip-1',
        trackId: 'track-1',
        sourceStartTime: 0.0,
        sourceEndTime: 20.0,
        timelineStartTime: 5.0,
        timelineEndTime: 15.0,
      );
      expect(clip.timelineDuration, 10.0);
    });

    test('sourceDuration computes source end - start', () {
      const clip = TimelineClip(
        id: 'clip-1',
        trackId: 'track-1',
        sourceStartTime: 2.0,
        sourceEndTime: 12.0,
        timelineStartTime: 0.0,
        timelineEndTime: 10.0,
      );
      expect(clip.sourceDuration, 10.0);
    });

    test('speedFactor computes timeline / source duration', () {
      const clip = TimelineClip(
        id: 'clip-1',
        trackId: 'track-1',
        sourceStartTime: 0.0,
        sourceEndTime: 10.0,
        timelineStartTime: 0.0,
        timelineEndTime: 20.0,
      );
      expect(clip.speedFactor, 2.0);
    });

    test('speedFactor returns 1.0 when source duration is 0', () {
      const clip = TimelineClip(
        id: 'clip-1',
        trackId: 'track-1',
        sourceStartTime: 5.0,
        sourceEndTime: 5.0,
        timelineStartTime: 0.0,
        timelineEndTime: 10.0,
      );
      expect(clip.speedFactor, 1.0);
    });

    test('equality is based on id', () {
      const c1 = TimelineClip(
        id: 'same-id',
        trackId: 'track-1',
        sourceStartTime: 0.0,
        sourceEndTime: 10.0,
        timelineStartTime: 0.0,
        timelineEndTime: 10.0,
      );
      const c2 = TimelineClip(
        id: 'same-id',
        trackId: 'track-2',
        sourceStartTime: 20.0,
        sourceEndTime: 30.0,
        timelineStartTime: 20.0,
        timelineEndTime: 30.0,
      );
      expect(c1 == c2, true);
      expect(c1.hashCode, c2.hashCode);
    });

    test('inequality for different ids', () {
      const c1 = TimelineClip(
        id: 'id-1',
        trackId: 'track-1',
        sourceStartTime: 0.0,
        sourceEndTime: 10.0,
        timelineStartTime: 0.0,
        timelineEndTime: 10.0,
      );
      const c2 = TimelineClip(
        id: 'id-2',
        trackId: 'track-1',
        sourceStartTime: 0.0,
        sourceEndTime: 10.0,
        timelineStartTime: 0.0,
        timelineEndTime: 10.0,
      );
      expect(c1 == c2, false);
    });

    test('toString contains key info', () {
      const clip = TimelineClip(
        id: 'clip-1',
        trackId: 'track-1',
        sourceStartTime: 0.0,
        sourceEndTime: 10.0,
        timelineStartTime: 5.0,
        timelineEndTime: 15.0,
      );
      final str = clip.toString();
      expect(str, contains('clip-1'));
      expect(str, contains('track-1'));
      expect(str, contains('5.0'));
      expect(str, contains('15.0'));
    });
  });

  group('TimelineTrack', () {
    final clip1 = const TimelineClip(
      id: 'clip-1',
      trackId: 'track-1',
      sourceStartTime: 0.0,
      sourceEndTime: 10.0,
      timelineStartTime: 0.0,
      timelineEndTime: 10.0,
    );

    final clip2 = const TimelineClip(
      id: 'clip-2',
      trackId: 'track-1',
      sourceStartTime: 10.0,
      sourceEndTime: 20.0,
      timelineStartTime: 10.0,
      timelineEndTime: 25.0,
    );

    test('creates with required parameters and defaults', () {
      const track = TimelineTrack(
        id: 'track-1',
        name: 'Main Video',
        type: TrackType.video,
      );

      expect(track.id, 'track-1');
      expect(track.name, 'Main Video');
      expect(track.type, TrackType.video);
      expect(track.clips, isEmpty);
    });

    test('creates with clips', () {
      final track = TimelineTrack(
        id: 'track-1',
        name: 'Main Video',
        type: TrackType.video,
        clips: [clip1, clip2],
      );
      expect(track.clips.length, 2);
    });

    test('fromJson/toJson round-trip', () {
      final original = TimelineTrack(
        id: 'track-2',
        name: 'Audio',
        type: TrackType.audio,
        clips: [clip1],
      );

      final json = original.toJson();
      final restored = TimelineTrack.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.type, original.type);
      expect(restored.clips.length, 1);
      expect(restored.clips[0].id, 'clip-1');
    });

    test('fromJson handles missing fields with defaults', () {
      final track = TimelineTrack.fromJson({});
      expect(track.id, '');
      expect(track.name, '');
      expect(track.type, TrackType.video);
      expect(track.clips, isEmpty);
    });

    test('fromJson handles all track types', () {
      for (final type in TrackType.values) {
        final json = {'id': '1', 'type': type.name};
        final track = TimelineTrack.fromJson(json);
        expect(track.type, type);
      }
    });

    test('copyWith updates selected fields', () {
      const original = TimelineTrack(
        id: 'track-1',
        name: 'Old Name',
        type: TrackType.video,
      );

      final updated = original.copyWith(
        name: 'New Name',
        type: TrackType.caption,
      );

      expect(updated.name, 'New Name');
      expect(updated.type, TrackType.caption);
      expect(updated.id, 'track-1');
    });

    test('clipCount returns number of clips', () {
      final track = TimelineTrack(
        id: 'track-1',
        name: 'Video',
        type: TrackType.video,
        clips: [clip1, clip2],
      );
      expect(track.clipCount, 2);
    });

    test('totalDuration spans first clip start to last clip end', () {
      final track = TimelineTrack(
        id: 'track-1',
        name: 'Video',
        type: TrackType.video,
        clips: [clip1, clip2],
      );
      // clip1: 0-10, clip2: 10-25
      expect(track.totalDuration, 25.0);
    });

    test('totalDuration returns 0 for empty track', () {
      const track = TimelineTrack(
        id: 'track-1',
        name: 'Video',
        type: TrackType.video,
      );
      expect(track.totalDuration, 0.0);
    });

    test('startTime returns first clip timeline start', () {
      final track = TimelineTrack(
        id: 'track-1',
        name: 'Video',
        type: TrackType.video,
        clips: [clip1, clip2],
      );
      expect(track.startTime, 0.0);
    });

    test('startTime returns 0 for empty track', () {
      const track = TimelineTrack(
        id: 'track-1',
        name: 'Video',
        type: TrackType.video,
      );
      expect(track.startTime, 0.0);
    });

    test('endTime returns last clip timeline end', () {
      final track = TimelineTrack(
        id: 'track-1',
        name: 'Video',
        type: TrackType.video,
        clips: [clip1, clip2],
      );
      expect(track.endTime, 25.0);
    });

    test('endTime returns 0 for empty track', () {
      const track = TimelineTrack(
        id: 'track-1',
        name: 'Video',
        type: TrackType.video,
      );
      expect(track.endTime, 0.0);
    });

    test('equality is based on id', () {
      const t1 = TimelineTrack(
        id: 'same-id',
        name: 'Track 1',
        type: TrackType.video,
      );
      const t2 = TimelineTrack(
        id: 'same-id',
        name: 'Track 2',
        type: TrackType.audio,
      );
      expect(t1 == t2, true);
      expect(t1.hashCode, t2.hashCode);
    });

    test('inequality for different ids', () {
      const t1 = TimelineTrack(
        id: 'id-1',
        name: 'Track',
        type: TrackType.video,
      );
      const t2 = TimelineTrack(
        id: 'id-2',
        name: 'Track',
        type: TrackType.video,
      );
      expect(t1 == t2, false);
    });

    test('toString contains key info', () {
      final track = TimelineTrack(
        id: 'track-1',
        name: 'Video',
        type: TrackType.video,
        clips: [clip1, clip2],
      );
      final str = track.toString();
      expect(str, contains('track-1'));
      expect(str, contains('Video'));
      expect(str, contains('video'));
      expect(str, contains('2'));
    });
  });
}
