import 'package:flutter_test/flutter_test.dart';
import 'package:ai_video_editor/features/analysis/models/transcript.dart';

void main() {
  group('Word', () {
    test('creates with required parameters and defaults', () {
      const word = Word(text: 'hello', startTime: 0.0, endTime: 0.5);
      expect(word.text, 'hello');
      expect(word.startTime, 0.0);
      expect(word.endTime, 0.5);
      expect(word.confidence, 1.0);
    });

    test('creates with all parameters', () {
      const word = Word(
        text: 'world',
        startTime: 1.0,
        endTime: 1.8,
        confidence: 0.95,
      );
      expect(word.text, 'world');
      expect(word.startTime, 1.0);
      expect(word.endTime, 1.8);
      expect(word.confidence, 0.95);
    });

    test('fromJson/toJson round-trip', () {
      const original = Word(
        text: 'test',
        startTime: 2.5,
        endTime: 3.0,
        confidence: 0.88,
      );

      final json = original.toJson();
      final restored = Word.fromJson(json);

      expect(restored.text, original.text);
      expect(restored.startTime, original.startTime);
      expect(restored.endTime, original.endTime);
      expect(restored.confidence, original.confidence);
    });

    test('fromJson handles missing fields with defaults', () {
      final word = Word.fromJson({});
      expect(word.text, '');
      expect(word.startTime, 0.0);
      expect(word.endTime, 0.0);
      expect(word.confidence, 1.0);
    });

    test('copyWith updates selected fields', () {
      const original = Word(text: 'old', startTime: 0.0, endTime: 1.0);
      final updated = original.copyWith(text: 'new', confidence: 0.5);
      expect(updated.text, 'new');
      expect(updated.confidence, 0.5);
      expect(updated.startTime, 0.0);
      expect(updated.endTime, 1.0);
    });

    test('duration getter computes end - start', () {
      const word = Word(text: 'test', startTime: 2.0, endTime: 5.0);
      expect(word.duration, 3.0);
    });

    test('duration is zero when start equals end', () {
      const word = Word(text: 'test', startTime: 3.0, endTime: 3.0);
      expect(word.duration, 0.0);
    });

    test('toString returns formatted string', () {
      const word = Word(text: 'hello', startTime: 0.0, endTime: 1.0);
      final str = word.toString();
      expect(str, contains('hello'));
      expect(str, contains('0.0'));
      expect(str, contains('1.0'));
    });
  });

  group('TranscriptSegment', () {
    test('creates with required parameters and defaults', () {
      const segment = TranscriptSegment(
        id: 'seg-1',
        text: 'Hello world',
        startTime: 0.0,
        endTime: 5.0,
      );

      expect(segment.id, 'seg-1');
      expect(segment.text, 'Hello world');
      expect(segment.startTime, 0.0);
      expect(segment.endTime, 5.0);
      expect(segment.speaker, null);
      expect(segment.confidence, 1.0);
      expect(segment.words, isEmpty);
    });

    test('creates with all parameters', () {
      const segment = TranscriptSegment(
        id: 'seg-1',
        text: 'Hello world',
        startTime: 0.0,
        endTime: 5.0,
        speaker: 'Speaker A',
        confidence: 0.92,
        words: [
          Word(text: 'Hello', startTime: 0.0, endTime: 0.5),
          Word(text: 'world', startTime: 0.5, endTime: 1.0),
        ],
      );

      expect(segment.speaker, 'Speaker A');
      expect(segment.confidence, 0.92);
      expect(segment.words.length, 2);
    });

    test('fromJson/toJson round-trip', () {
      final original = TranscriptSegment(
        id: 'seg-2',
        text: 'Test segment',
        startTime: 1.0,
        endTime: 4.0,
        speaker: 'Speaker B',
        confidence: 0.85,
        words: const [
          Word(text: 'Test', startTime: 1.0, endTime: 1.5),
          Word(text: 'segment', startTime: 1.5, endTime: 2.0),
        ],
      );

      final json = original.toJson();
      final restored = TranscriptSegment.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.text, original.text);
      expect(restored.startTime, original.startTime);
      expect(restored.endTime, original.endTime);
      expect(restored.speaker, original.speaker);
      expect(restored.confidence, original.confidence);
      expect(restored.words.length, original.words.length);
      expect(restored.words[0].text, 'Test');
    });

    test('fromJson handles missing fields with defaults', () {
      final segment = TranscriptSegment.fromJson({});
      expect(segment.id, '');
      expect(segment.text, '');
      expect(segment.startTime, 0.0);
      expect(segment.endTime, 0.0);
      expect(segment.speaker, null);
      expect(segment.confidence, 1.0);
      expect(segment.words, isEmpty);
    });

    test('copyWith updates selected fields', () {
      const original = TranscriptSegment(
        id: 'seg-1',
        text: 'Old text',
        startTime: 0.0,
        endTime: 5.0,
        speaker: 'Speaker A',
      );

      final updated = original.copyWith(
        text: 'New text',
        confidence: 0.7,
      );

      expect(updated.text, 'New text');
      expect(updated.confidence, 0.7);
      expect(updated.id, 'seg-1');
      expect(updated.speaker, 'Speaker A');
    });

    test('copyWith clears speaker', () {
      const original = TranscriptSegment(
        id: 'seg-1',
        text: 'Text',
        startTime: 0.0,
        endTime: 5.0,
        speaker: 'Speaker A',
      );

      final cleared = original.copyWith(clearSpeaker: true);
      expect(cleared.speaker, null);
      expect(cleared.text, 'Text');
    });

    test('duration getter computes end - start', () {
      const segment = TranscriptSegment(
        id: 'seg-1',
        text: 'Text',
        startTime: 2.0,
        endTime: 8.0,
      );
      expect(segment.duration, 6.0);
    });

    test('hasWordTimestamps returns true when words are present', () {
      const segment = TranscriptSegment(
        id: 'seg-1',
        text: 'Text',
        startTime: 0.0,
        endTime: 5.0,
        words: [Word(text: 'word', startTime: 0.0, endTime: 0.5)],
      );
      expect(segment.hasWordTimestamps, true);
    });

    test('hasWordTimestamps returns false when words are empty', () {
      const segment = TranscriptSegment(
        id: 'seg-1',
        text: 'Text',
        startTime: 0.0,
        endTime: 5.0,
      );
      expect(segment.hasWordTimestamps, false);
    });

    test('equality is based on id', () {
      const s1 = TranscriptSegment(
        id: 'same-id',
        text: 'Text 1',
        startTime: 0.0,
        endTime: 5.0,
      );
      const s2 = TranscriptSegment(
        id: 'same-id',
        text: 'Text 2',
        startTime: 10.0,
        endTime: 15.0,
      );
      expect(s1 == s2, true);
      expect(s1.hashCode, s2.hashCode);
    });

    test('inequality for different ids', () {
      const s1 = TranscriptSegment(
        id: 'id-1',
        text: 'Text',
        startTime: 0.0,
        endTime: 5.0,
      );
      const s2 = TranscriptSegment(
        id: 'id-2',
        text: 'Text',
        startTime: 0.0,
        endTime: 5.0,
      );
      expect(s1 == s2, false);
    });

    test('toString truncates long text', () {
      final segment = TranscriptSegment(
        id: 'seg-1',
        text: 'This is a very long text that should be truncated because it exceeds thirty characters',
        startTime: 0.0,
        endTime: 5.0,
      );
      final str = segment.toString();
      expect(str, contains('...'));
    });

    test('toString does not truncate short text', () {
      const segment = TranscriptSegment(
        id: 'seg-1',
        text: 'Short',
        startTime: 0.0,
        endTime: 5.0,
      );
      final str = segment.toString();
      expect(str, contains('Short'));
      expect(str.contains('...'), false);
    });
  });

  group('Transcript', () {
    final segment1 = TranscriptSegment(
      id: 'seg-1',
      text: 'Hello world',
      startTime: 0.0,
      endTime: 5.0,
      speaker: 'Speaker A',
      words: const [
        Word(text: 'Hello', startTime: 0.0, endTime: 0.5),
        Word(text: 'world', startTime: 0.5, endTime: 1.0),
      ],
    );

    final segment2 = TranscriptSegment(
      id: 'seg-2',
      text: 'How are you?',
      startTime: 5.0,
      endTime: 10.0,
      speaker: 'Speaker B',
      words: const [
        Word(text: 'How', startTime: 5.0, endTime: 5.3),
        Word(text: 'are', startTime: 5.3, endTime: 5.5),
        Word(text: 'you', startTime: 5.5, endTime: 5.8),
      ],
    );

    final segment3 = TranscriptSegment(
      id: 'seg-3',
      text: 'I am fine!',
      startTime: 10.0,
      endTime: 15.0,
      speaker: 'Speaker A',
      words: const [
        Word(text: 'I', startTime: 10.0, endTime: 10.1),
        Word(text: 'am', startTime: 10.1, endTime: 10.3),
        Word(text: 'fine', startTime: 10.3, endTime: 10.7),
      ],
    );

    test('creates with default empty segments', () {
      const transcript = Transcript();
      expect(transcript.segments, isEmpty);
    });

    test('creates with segments', () {
      final transcript =
          Transcript(segments: [segment1, segment2, segment3]);
      expect(transcript.segments.length, 3);
    });

    test('fromJson/toJson round-trip', () {
      final original = Transcript(segments: [segment1, segment2]);
      final json = original.toJson();
      final restored = Transcript.fromJson(json);

      expect(restored.segments.length, original.segments.length);
      expect(restored.segments[0].id, 'seg-1');
      expect(restored.segments[0].words.length, 2);
      expect(restored.segments[1].speaker, 'Speaker B');
    });

    test('fromJson handles missing segments', () {
      final transcript = Transcript.fromJson({});
      expect(transcript.segments, isEmpty);
    });

    test('copyWith updates segments', () {
      const original = Transcript();
      final updated = original.copyWith(segments: [segment1]);
      expect(updated.segments.length, 1);
      expect(original.segments, isEmpty);
    });

    test('segmentCount returns number of segments', () {
      final transcript =
          Transcript(segments: [segment1, segment2, segment3]);
      expect(transcript.segmentCount, 3);
    });

    test('wordCount returns total words across segments', () {
      final transcript =
          Transcript(segments: [segment1, segment2, segment3]);
      // segment1: 2 words, segment2: 3 words, segment3: 3 words
      expect(transcript.wordCount, 8);
    });

    test('fullText joins segment texts', () {
      final transcript = Transcript(segments: [segment1, segment2]);
      expect(transcript.fullText, 'Hello world How are you?');
    });

    test('fullText is empty for empty transcript', () {
      const transcript = Transcript();
      expect(transcript.fullText, '');
    });

    test('duration returns total time span', () {
      final transcript =
          Transcript(segments: [segment1, segment2, segment3]);
      // First segment starts at 0.0, last ends at 15.0
      expect(transcript.duration, 15.0);
    });

    test('duration returns 0 for empty transcript', () {
      const transcript = Transcript();
      expect(transcript.duration, 0.0);
    });

    test('segmentsBySpeaker filters correctly', () {
      final transcript =
          Transcript(segments: [segment1, segment2, segment3]);
      final speakerASegments = transcript.segmentsBySpeaker('Speaker A');
      expect(speakerASegments.length, 2);
      expect(speakerASegments[0].id, 'seg-1');
      expect(speakerASegments[1].id, 'seg-3');
    });

    test('segmentsBySpeaker returns empty for unknown speaker', () {
      final transcript =
          Transcript(segments: [segment1, segment2, segment3]);
      final result = transcript.segmentsBySpeaker('Unknown');
      expect(result, isEmpty);
    });

    test('segmentsInRange filters correctly', () {
      final transcript =
          Transcript(segments: [segment1, segment2, segment3]);
      // segment1: 0-5, segment2: 5-10
      final inRange = transcript.segmentsInRange(0.0, 10.0);
      expect(inRange.length, 2);
    });

    test('segmentsInRange returns empty when no matches', () {
      final transcript =
          Transcript(segments: [segment1, segment2, segment3]);
      final inRange = transcript.segmentsInRange(100.0, 200.0);
      expect(inRange, isEmpty);
    });

    test('speakers returns unique non-null speakers', () {
      final transcript =
          Transcript(segments: [segment1, segment2, segment3]);
      final speakers = transcript.speakers;
      expect(speakers.length, 2);
      expect(speakers, contains('Speaker A'));
      expect(speakers, contains('Speaker B'));
    });

    test('speakers returns empty for empty transcript', () {
      const transcript = Transcript();
      expect(transcript.speakers, isEmpty);
    });

    test('segmentAt finds segment at given timestamp', () {
      final transcript =
          Transcript(segments: [segment1, segment2, segment3]);
      final seg = transcript.segmentAt(3.0);
      expect(seg, isNotNull);
      expect(seg!.id, 'seg-1');
    });

    test('segmentAt returns null for timestamp not in any segment', () {
      final transcript =
          Transcript(segments: [segment1, segment2, segment3]);
      final seg = transcript.segmentAt(100.0);
      expect(seg, null);
    });

    test('segmentAt finds segment at exact start time', () {
      final transcript = Transcript(segments: [segment1, segment2]);
      final seg = transcript.segmentAt(5.0);
      expect(seg, isNotNull);
      expect(seg!.id, 'seg-2');
    });

    test('segmentAt finds segment at exact end time', () {
      final transcript = Transcript(segments: [segment1, segment2]);
      final seg = transcript.segmentAt(5.0);
      expect(seg, isNotNull);
    });

    test('toString returns formatted string', () {
      final transcript =
          Transcript(segments: [segment1, segment2, segment3]);
      final str = transcript.toString();
      expect(str, contains('3'));
    });
  });
}
