/// Viral moment models for the AI Video Editor app.
///
/// Models representing detected viral-worthy moments in a video with
/// multi-dimensional scoring and reasoning.

/// The type of viral moment.
enum ViralMomentType {
  hook,
  punchline,
  emotionalPeak,
  surprising,
  informative,
  funny,
  controversial,
  inspiring,
  relatable,
  other;

  factory ViralMomentType.fromString(String value) {
    return ViralMomentType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ViralMomentType.other,
    );
  }

  String toJson() => name;
}

/// Multi-dimensional viral score breakdown.
class ViralScores {
  final double hook;
  final double entertainment;
  final double emotion;
  final double humor;
  final double surprise;
  final double storyImportance;
  final double replayPotential;
  final double shortFormPotential;
  final double longFormPotential;
  final double commentaryPotential;
  final double visualImpact;

  const ViralScores({
    this.hook = 0.0,
    this.entertainment = 0.0,
    this.emotion = 0.0,
    this.humor = 0.0,
    this.surprise = 0.0,
    this.storyImportance = 0.0,
    this.replayPotential = 0.0,
    this.shortFormPotential = 0.0,
    this.longFormPotential = 0.0,
    this.commentaryPotential = 0.0,
    this.visualImpact = 0.0,
  });

  factory ViralScores.fromJson(Map<String, dynamic> json) {
    return ViralScores(
      hook: (json['hook'] as num?)?.toDouble() ?? 0.0,
      entertainment: (json['entertainment'] as num?)?.toDouble() ?? 0.0,
      emotion: (json['emotion'] as num?)?.toDouble() ?? 0.0,
      humor: (json['humor'] as num?)?.toDouble() ?? 0.0,
      surprise: (json['surprise'] as num?)?.toDouble() ?? 0.0,
      storyImportance: (json['storyImportance'] as num?)?.toDouble() ?? 0.0,
      replayPotential:
          (json['replayPotential'] as num?)?.toDouble() ?? 0.0,
      shortFormPotential:
          (json['shortFormPotential'] as num?)?.toDouble() ?? 0.0,
      longFormPotential:
          (json['longFormPotential'] as num?)?.toDouble() ?? 0.0,
      commentaryPotential:
          (json['commentaryPotential'] as num?)?.toDouble() ?? 0.0,
      visualImpact: (json['visualImpact'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hook': hook,
      'entertainment': entertainment,
      'emotion': emotion,
      'humor': humor,
      'surprise': surprise,
      'storyImportance': storyImportance,
      'replayPotential': replayPotential,
      'shortFormPotential': shortFormPotential,
      'longFormPotential': longFormPotential,
      'commentaryPotential': commentaryPotential,
      'visualImpact': visualImpact,
    };
  }

  ViralScores copyWith({
    double? hook,
    double? entertainment,
    double? emotion,
    double? humor,
    double? surprise,
    double? storyImportance,
    double? replayPotential,
    double? shortFormPotential,
    double? longFormPotential,
    double? commentaryPotential,
    double? visualImpact,
  }) {
    return ViralScores(
      hook: hook ?? this.hook,
      entertainment: entertainment ?? this.entertainment,
      emotion: emotion ?? this.emotion,
      humor: humor ?? this.humor,
      surprise: surprise ?? this.surprise,
      storyImportance: storyImportance ?? this.storyImportance,
      replayPotential: replayPotential ?? this.replayPotential,
      shortFormPotential: shortFormPotential ?? this.shortFormPotential,
      longFormPotential: longFormPotential ?? this.longFormPotential,
      commentaryPotential:
          commentaryPotential ?? this.commentaryPotential,
      visualImpact: visualImpact ?? this.visualImpact,
    );
  }

  /// Overall viral score (average of all dimensions).
  double get overallScore {
    final scores = [
      hook,
      entertainment,
      emotion,
      humor,
      surprise,
      storyImportance,
      replayPotential,
      shortFormPotential,
      longFormPotential,
      commentaryPotential,
      visualImpact,
    ];
    if (scores.isEmpty) return 0.0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  /// Get the highest-scoring dimension name.
  String get topDimension {
    final map = <String, double>{
      'hook': hook,
      'entertainment': entertainment,
      'emotion': emotion,
      'humor': humor,
      'surprise': surprise,
      'storyImportance': storyImportance,
      'replayPotential': replayPotential,
      'shortFormPotential': shortFormPotential,
      'longFormPotential': longFormPotential,
      'commentaryPotential': commentaryPotential,
      'visualImpact': visualImpact,
    };
    return map.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  /// Get all dimensions sorted by score descending.
  List<MapEntry<String, double>> get sortedDimensions {
    final map = <String, double>{
      'hook': hook,
      'entertainment': entertainment,
      'emotion': emotion,
      'humor': humor,
      'surprise': surprise,
      'storyImportance': storyImportance,
      'replayPotential': replayPotential,
      'shortFormPotential': shortFormPotential,
      'longFormPotential': longFormPotential,
      'commentaryPotential': commentaryPotential,
      'visualImpact': visualImpact,
    };
    final entries = map.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  @override
  String toString() =>
      'ViralScores(overall: ${overallScore.toStringAsFixed(2)}, top: $topDimension)';
}

/// A viral-worthy moment detected in the video.
class ViralMoment {
  final String id;
  final double startTime;
  final double endTime;
  final String description;
  final ViralMomentType type;
  final ViralScores scores;
  final String reasoning;
  final double confidence;
  final List<String> relatedMoments; // IDs of related moments

  const ViralMoment({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.type,
    required this.scores,
    this.reasoning = '',
    this.confidence = 0.5,
    this.relatedMoments = const [],
  });

  /// Creates a ViralMoment from JSON.
  factory ViralMoment.fromJson(Map<String, dynamic> json) {
    return ViralMoment(
      id: json['id'] as String? ?? '',
      startTime: (json['startTime'] as num?)?.toDouble() ?? 0.0,
      endTime: (json['endTime'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      type: json['type'] != null
          ? ViralMomentType.fromString(json['type'] as String)
          : ViralMomentType.other,
      scores: json['scores'] != null
          ? ViralScores.fromJson(json['scores'] as Map<String, dynamic>)
          : const ViralScores(),
      reasoning: json['reasoning'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      relatedMoments: (json['relatedMoments'] as List<dynamic>?)
              ?.map((r) => r as String)
              .toList() ??
          [],
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime,
      'endTime': endTime,
      'description': description,
      'type': type.toJson(),
      'scores': scores.toJson(),
      'reasoning': reasoning,
      'confidence': confidence,
      'relatedMoments': relatedMoments,
    };
  }

  /// Creates a copy with selective field updates.
  ViralMoment copyWith({
    String? id,
    double? startTime,
    double? endTime,
    String? description,
    ViralMomentType? type,
    ViralScores? scores,
    String? reasoning,
    double? confidence,
    List<String>? relatedMoments,
  }) {
    return ViralMoment(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      description: description ?? this.description,
      type: type ?? this.type,
      scores: scores ?? this.scores,
      reasoning: reasoning ?? this.reasoning,
      confidence: confidence ?? this.confidence,
      relatedMoments: relatedMoments ?? this.relatedMoments,
    );
  }

  /// Duration of this moment in seconds.
  double get duration => endTime - startTime;

  /// Overall viral score (convenience accessor).
  double get overallScore => scores.overallScore;

  /// Short form potential score (convenience accessor).
  double get shortFormPotential => scores.shortFormPotential;

  /// Long form potential score (convenience accessor).
  double get longFormPotential => scores.longFormPotential;

  @override
  String toString() =>
      'ViralMoment(id: $id, type: ${type.name}, overallScore: ${overallScore.toStringAsFixed(2)}, '
      '${startTime.toStringAsFixed(1)}-${endTime.toStringAsFixed(1)}s)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViralMoment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
