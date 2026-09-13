/// Transcript models for the AI Video Editor app.
///
/// Models for word-level and segment-level transcription data.

/// A single word with its timing and confidence.
class Word {
  final String text;
  final double startTime;
  final double endTime;
  final double confidence;

  const Word({
    required this.text,
    required this.startTime,
    required this.endTime,
    this.confidence = 1.0,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      text: json['text'] as String? ?? '',
      startTime: (json['startTime'] as num?)?.toDouble() ?? 0.0,
      endTime: (json['endTime'] as num?)?.toDouble() ?? 0.0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'startTime': startTime,
      'endTime': endTime,
      'confidence': confidence,
    };
  }

  Word copyWith({
    String? text,
    double? startTime,
    double? endTime,
    double? confidence,
  }) {
    return Word(
      text: text ?? this.text,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      confidence: confidence ?? this.confidence,
    );
  }

  /// Duration of this word in seconds.
  double get duration => endTime - startTime;

  @override
  String toString() => 'Word("$text", $startTime-$endTime)';
}

/// A segment of the transcript associated with a time range and speaker.
class TranscriptSegment {
  final String id;
  final String text;
  final double startTime;
  final double endTime;
  final String? speaker;
  final double confidence;
  final List<Word> words;

  const TranscriptSegment({
    required this.id,
    required this.text,
    required this.startTime,
    required this.endTime,
    this.speaker,
    this.confidence = 1.0,
    this.words = const [],
  });

  factory TranscriptSegment.fromJson(Map<String, dynamic> json) {
    return TranscriptSegment(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      startTime: (json['startTime'] as num?)?.toDouble() ?? 0.0,
      endTime: (json['endTime'] as num?)?.toDouble() ?? 0.0,
      speaker: json['speaker'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      words: (json['words'] as List<dynamic>?)
              ?.map((w) => Word.fromJson(w as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'startTime': startTime,
      'endTime': endTime,
      'speaker': speaker,
      'confidence': confidence,
      'words': words.map((w) => w.toJson()).toList(),
    };
  }

  TranscriptSegment copyWith({
    String? id,
    String? text,
    double? startTime,
    double? endTime,
    String? speaker,
    double? confidence,
    List<Word>? words,
    bool clearSpeaker = false,
  }) {
    return TranscriptSegment(
      id: id ?? this.id,
      text: text ?? this.text,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      speaker: clearSpeaker ? null : (speaker ?? this.speaker),
      confidence: confidence ?? this.confidence,
      words: words ?? this.words,
    );
  }

  /// Duration of this segment in seconds.
  double get duration => endTime - startTime;

  /// Whether this segment has word-level timestamps.
  bool get hasWordTimestamps => words.isNotEmpty;

  @override
  String toString() =>
      'TranscriptSegment(id: $id, text: "${text.length > 30 ? '${text.substring(0, 30)}...' : text}", speaker: $speaker)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptSegment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Complete transcript for a video.
class Transcript {
  final List<TranscriptSegment> segments;

  const Transcript({this.segments = const []});

  factory Transcript.fromJson(Map<String, dynamic> json) {
    return Transcript(
      segments: (json['segments'] as List<dynamic>?)
              ?.map(
                  (s) => TranscriptSegment.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'segments': segments.map((s) => s.toJson()).toList(),
    };
  }

  Transcript copyWith({List<TranscriptSegment>? segments}) {
    return Transcript(
      segments: segments ?? this.segments,
    );
  }

  /// Total number of segments.
  int get segmentCount => segments.length;

  /// Total number of words across all segments.
  int get wordCount => segments.fold(0, (sum, s) => sum + s.words.length);

  /// Full transcript text as a single string.
  String get fullText => segments.map((s) => s.text).join(' ');

  /// Total duration of the transcript in seconds.
  double get duration {
    if (segments.isEmpty) return 0.0;
    return segments.last.endTime - segments.first.startTime;
  }

  /// Returns segments filtered by speaker.
  List<TranscriptSegment> segmentsBySpeaker(String speaker) {
    return segments.where((s) => s.speaker == speaker).toList();
  }

  /// Returns segments within a time range.
  List<TranscriptSegment> segmentsInRange(double start, double end) {
    return segments
        .where((s) => s.startTime >= start && s.endTime <= end)
        .toList();
  }

  /// Returns all unique speakers in the transcript.
  List<String> get speakers {
    return segments
        .map((s) => s.speaker)
        .where((s) => s != null)
        .cast<String>()
        .toSet()
        .toList();
  }

  /// Finds the segment at a specific timestamp.
  TranscriptSegment? segmentAt(double timestamp) {
    try {
      return segments.firstWhere(
        (s) => timestamp >= s.startTime && timestamp <= s.endTime,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() => 'Transcript(segments: ${segments.length})';
}
