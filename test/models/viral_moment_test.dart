import 'package:flutter_test/flutter_test.dart';
import 'package:ai_video_editor/features/analysis/models/viral_moment.dart';

void main() {
  group('ViralMomentType', () {
    test('fromString returns correct enum value', () {
      expect(ViralMomentType.fromString('hook'), ViralMomentType.hook);
      expect(ViralMomentType.fromString('punchline'), ViralMomentType.punchline);
      expect(ViralMomentType.fromString('emotionalPeak'),
          ViralMomentType.emotionalPeak);
      expect(ViralMomentType.fromString('surprising'), ViralMomentType.surprising);
      expect(
          ViralMomentType.fromString('informative'), ViralMomentType.informative);
      expect(ViralMomentType.fromString('funny'), ViralMomentType.funny);
      expect(ViralMomentType.fromString('controversial'),
          ViralMomentType.controversial);
      expect(ViralMomentType.fromString('inspiring'), ViralMomentType.inspiring);
      expect(ViralMomentType.fromString('relatable'), ViralMomentType.relatable);
      expect(ViralMomentType.fromString('other'), ViralMomentType.other);
    });

    test('fromString returns other for unknown value', () {
      expect(ViralMomentType.fromString('unknown'), ViralMomentType.other);
    });
  });

  group('ViralScores', () {
    test('creates with all default values (0.0)', () {
      const scores = ViralScores();
      expect(scores.hook, 0.0);
      expect(scores.entertainment, 0.0);
      expect(scores.emotion, 0.0);
      expect(scores.humor, 0.0);
      expect(scores.surprise, 0.0);
      expect(scores.storyImportance, 0.0);
      expect(scores.replayPotential, 0.0);
      expect(scores.shortFormPotential, 0.0);
      expect(scores.longFormPotential, 0.0);
      expect(scores.commentaryPotential, 0.0);
      expect(scores.visualImpact, 0.0);
    });

    test('creates with all parameters', () {
      const scores = ViralScores(
        hook: 0.9,
        entertainment: 0.8,
        emotion: 0.7,
        humor: 0.6,
        surprise: 0.5,
        storyImportance: 0.4,
        replayPotential: 0.3,
        shortFormPotential: 0.2,
        longFormPotential: 0.1,
        commentaryPotential: 0.85,
        visualImpact: 0.75,
      );
      expect(scores.hook, 0.9);
      expect(scores.entertainment, 0.8);
      expect(scores.emotion, 0.7);
      expect(scores.humor, 0.6);
      expect(scores.surprise, 0.5);
      expect(scores.storyImportance, 0.4);
      expect(scores.replayPotential, 0.3);
      expect(scores.shortFormPotential, 0.2);
      expect(scores.longFormPotential, 0.1);
      expect(scores.commentaryPotential, 0.85);
      expect(scores.visualImpact, 0.75);
    });

    test('fromJson/toJson round-trip', () {
      const original = ViralScores(
        hook: 0.9,
        entertainment: 0.8,
        emotion: 0.7,
        humor: 0.6,
        surprise: 0.5,
        storyImportance: 0.4,
        replayPotential: 0.3,
        shortFormPotential: 0.2,
        longFormPotential: 0.1,
        commentaryPotential: 0.85,
        visualImpact: 0.75,
      );

      final json = original.toJson();
      final restored = ViralScores.fromJson(json);

      expect(restored.hook, original.hook);
      expect(restored.entertainment, original.entertainment);
      expect(restored.emotion, original.emotion);
      expect(restored.humor, original.humor);
      expect(restored.surprise, original.surprise);
      expect(restored.storyImportance, original.storyImportance);
      expect(restored.replayPotential, original.replayPotential);
      expect(restored.shortFormPotential, original.shortFormPotential);
      expect(restored.longFormPotential, original.longFormPotential);
      expect(restored.commentaryPotential, original.commentaryPotential);
      expect(restored.visualImpact, original.visualImpact);
    });

    test('fromJson handles missing fields with defaults', () {
      final scores = ViralScores.fromJson({});
      expect(scores.hook, 0.0);
      expect(scores.entertainment, 0.0);
      expect(scores.emotion, 0.0);
      expect(scores.humor, 0.0);
      expect(scores.surprise, 0.0);
      expect(scores.storyImportance, 0.0);
      expect(scores.replayPotential, 0.0);
      expect(scores.shortFormPotential, 0.0);
      expect(scores.longFormPotential, 0.0);
      expect(scores.commentaryPotential, 0.0);
      expect(scores.visualImpact, 0.0);
    });

    test('copyWith updates selected fields', () {
      const original = ViralScores(hook: 0.5, humor: 0.3);
      final updated = original.copyWith(hook: 0.9, humor: 0.8);
      expect(updated.hook, 0.9);
      expect(updated.humor, 0.8);
      expect(updated.entertainment, 0.0);
      expect(updated.emotion, 0.0);
    });

    test('overallScore computes average of all dimensions', () {
      const scores = ViralScores(
        hook: 1.0,
        entertainment: 1.0,
        emotion: 1.0,
        humor: 1.0,
        surprise: 1.0,
        storyImportance: 1.0,
        replayPotential: 1.0,
        shortFormPotential: 1.0,
        longFormPotential: 1.0,
        commentaryPotential: 1.0,
        visualImpact: 1.0,
      );
      expect(scores.overallScore, closeTo(1.0, 0.001));
    });

    test('overallScore computes correct average with mixed values', () {
      const scores = ViralScores(
        hook: 1.0,
        entertainment: 0.0,
        emotion: 0.0,
        humor: 0.0,
        surprise: 0.0,
        storyImportance: 0.0,
        replayPotential: 0.0,
        shortFormPotential: 0.0,
        longFormPotential: 0.0,
        commentaryPotential: 0.0,
        visualImpact: 0.0,
      );
      // 1.0 / 11 ≈ 0.0909
      expect(scores.overallScore, closeTo(1.0 / 11.0, 0.001));
    });

    test('overallScore returns 0 for default scores', () {
      const scores = ViralScores();
      expect(scores.overallScore, 0.0);
    });

    test('topDimension returns highest scoring dimension', () {
      const scores = ViralScores(
        hook: 0.5,
        humor: 0.9,
        surprise: 0.3,
      );
      expect(scores.topDimension, 'humor');
    });

    test('topDimension returns first max when tied', () {
      const scores = ViralScores(
        hook: 0.8,
        entertainment: 0.8,
      );
      // Both 0.8, first in order wins
      expect(scores.topDimension, 'hook');
    });

    test('sortedDimensions returns all dimensions sorted descending', () {
      const scores = ViralScores(
        hook: 0.5,
        humor: 0.9,
        surprise: 0.3,
        entertainment: 0.7,
      );
      final sorted = scores.sortedDimensions;
      expect(sorted.length, 11);
      expect(sorted[0].key, 'humor');
      expect(sorted[0].value, 0.9);
      expect(sorted[1].key, 'entertainment');
      expect(sorted[1].value, 0.7);
    });

    test('toString contains overall score and top dimension', () {
      const scores = ViralScores(hook: 0.8, humor: 0.9);
      final str = scores.toString();
      expect(str, contains('humor'));
    });
  });

  group('ViralMoment', () {
    const testScores = ViralScores(
      hook: 0.8,
      entertainment: 0.7,
      emotion: 0.6,
      humor: 0.5,
      surprise: 0.4,
      storyImportance: 0.3,
      replayPotential: 0.9,
      shortFormPotential: 0.85,
      longFormPotential: 0.2,
      commentaryPotential: 0.35,
      visualImpact: 0.45,
    );

    ViralMoment createTestMoment({
      String id = 'vm-1',
      double startTime = 10.0,
      double endTime = 25.0,
      String description = 'Epic funny moment',
      ViralMomentType type = ViralMomentType.funny,
      ViralScores scores = testScores,
      String reasoning = 'Very engaging',
      double confidence = 0.85,
      List<String> relatedMoments = const [],
    }) {
      return ViralMoment(
        id: id,
        startTime: startTime,
        endTime: endTime,
        description: description,
        type: type,
        scores: scores,
        reasoning: reasoning,
        confidence: confidence,
        relatedMoments: relatedMoments,
      );
    }

    test('creates with required parameters and defaults', () {
      final moment = ViralMoment(
        id: 'vm-1',
        startTime: 5.0,
        endTime: 15.0,
        description: 'Funny moment',
        type: ViralMomentType.funny,
        scores: const ViralScores(),
      );

      expect(moment.id, 'vm-1');
      expect(moment.startTime, 5.0);
      expect(moment.endTime, 15.0);
      expect(moment.description, 'Funny moment');
      expect(moment.type, ViralMomentType.funny);
      expect(moment.reasoning, '');
      expect(moment.confidence, 0.5);
      expect(moment.relatedMoments, isEmpty);
    });

    test('creates with all parameters', () {
      final moment = createTestMoment(
        relatedMoments: ['vm-2', 'vm-3'],
      );
      expect(moment.reasoning, 'Very engaging');
      expect(moment.confidence, 0.85);
      expect(moment.relatedMoments, ['vm-2', 'vm-3']);
    });

    test('fromJson/toJson round-trip', () {
      final original = createTestMoment(
        relatedMoments: ['vm-2', 'vm-3'],
      );

      final json = original.toJson();
      final restored = ViralMoment.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.startTime, original.startTime);
      expect(restored.endTime, original.endTime);
      expect(restored.description, original.description);
      expect(restored.type, original.type);
      expect(restored.reasoning, original.reasoning);
      expect(restored.confidence, original.confidence);
      expect(restored.relatedMoments, original.relatedMoments);
      expect(restored.scores.hook, original.scores.hook);
      expect(restored.scores.humor, original.scores.humor);
    });

    test('fromJson handles missing fields with defaults', () {
      final moment = ViralMoment.fromJson({});
      expect(moment.id, '');
      expect(moment.startTime, 0.0);
      expect(moment.endTime, 0.0);
      expect(moment.description, '');
      expect(moment.type, ViralMomentType.other);
      expect(moment.reasoning, '');
      expect(moment.confidence, 0.5);
      expect(moment.relatedMoments, isEmpty);
      expect(moment.scores, isA<ViralScores>());
    });

    test('fromJson handles all moment types', () {
      for (final type in ViralMomentType.values) {
        final json = {'id': '1', 'type': type.name};
        final moment = ViralMoment.fromJson(json);
        expect(moment.type, type);
      }
    });

    test('copyWith updates selected fields', () {
      final original = createTestMoment();
      final updated = original.copyWith(
        description: 'Updated description',
        confidence: 0.95,
        type: ViralMomentType.hook,
      );
      expect(updated.description, 'Updated description');
      expect(updated.confidence, 0.95);
      expect(updated.type, ViralMomentType.hook);
      expect(updated.id, original.id);
      expect(updated.startTime, original.startTime);
    });

    test('duration getter computes end - start', () {
      final moment = createTestMoment(startTime: 5.0, endTime: 20.0);
      expect(moment.duration, 15.0);
    });

    test('overallScore delegates to scores.overallScore', () {
      final moment = createTestMoment();
      expect(moment.overallScore, moment.scores.overallScore);
    });

    test('shortFormPotential delegates to scores.shortFormPotential', () {
      final moment = createTestMoment();
      expect(moment.shortFormPotential, moment.scores.shortFormPotential);
    });

    test('longFormPotential delegates to scores.longFormPotential', () {
      final moment = createTestMoment();
      expect(moment.longFormPotential, moment.scores.longFormPotential);
    });

    test('equality is based on id', () {
      final m1 = createTestMoment(id: 'same-id', description: 'Desc 1');
      final m2 = createTestMoment(id: 'same-id', description: 'Desc 2');
      expect(m1 == m2, true);
      expect(m1.hashCode, m2.hashCode);
    });

    test('inequality for different ids', () {
      final m1 = createTestMoment(id: 'id-1');
      final m2 = createTestMoment(id: 'id-2');
      expect(m1 == m2, false);
    });

    test('equality with same instance', () {
      final m = createTestMoment();
      expect(m == m, true);
    });

    test('not equal to non-ViralMoment object', () {
      final m = createTestMoment();
      expect(m == 'not a moment', false);
    });

    test('toString contains key info', () {
      final moment = createTestMoment(id: 'vm-1');
      final str = moment.toString();
      expect(str, contains('vm-1'));
      expect(str, contains('funny'));
      expect(str, contains('10.0'));
      expect(str, contains('25.0'));
    });
  });
}
