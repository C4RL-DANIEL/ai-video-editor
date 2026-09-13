import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../projects/presentation/project_providers.dart';

// ═══════════════════════════════════════════════════════════════════════
// Domain models (re-export from projects for convenience)
// ═══════════════════════════════════════════════════════════════════════

// ViralMoment, TranscriptData, TranscriptSegment, ContentMap,
// ContentSection are defined in project_providers.dart.

// ═══════════════════════════════════════════════════════════════════════
// Analysis-specific state
// ═══════════════════════════════════════════════════════════════════════

enum AnalysisPhase { idle, transcribing, detectingViral, mappingContent, completed, failed }

class AnalysisState {
  final AnalysisPhase phase;
  final double progress;
  final String? errorMessage;
  final Duration? elapsed;

  const AnalysisState({
    this.phase = AnalysisPhase.idle,
    this.progress = 0.0,
    this.errorMessage,
    this.elapsed,
  });

  AnalysisState copyWith({
    AnalysisPhase? phase,
    double? progress,
    String? errorMessage,
    Duration? elapsed,
  }) {
    return AnalysisState(
      phase: phase ?? this.phase,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      elapsed: elapsed ?? this.elapsed,
    );
  }

  bool get isRunning =>
      phase != AnalysisPhase.idle &&
      phase != AnalysisPhase.completed &&
      phase != AnalysisPhase.failed;

  bool get isCompleted => phase == AnalysisPhase.completed;
  bool get isFailed => phase == AnalysisPhase.failed;
}

// ═══════════════════════════════════════════════════════════════════════
// Service abstraction
// ═══════════════════════════════════════════════════════════════════════

abstract class AnalysisService {
  /// Runs full analysis, emitting phase updates via the stream.
  Stream<AnalysisState> analyze(String projectId);

  /// Fetch cached analysis results for a project.
  Future<ProjectAnalysis?> getCachedAnalysis(String projectId);
}

class MockAnalysisService implements AnalysisService {
  @override
  Stream<AnalysisState> analyze(String projectId) async* {
    // Phase 1: Transcription
    yield const AnalysisState(
      phase: AnalysisPhase.transcribing,
      progress: 0.0,
    );
    for (double p = 0.0; p <= 1.0; p += 0.1) {
      await Future.delayed(const Duration(milliseconds: 200));
      yield AnalysisState(
        phase: AnalysisPhase.transcribing,
        progress: p * 0.33, // 33% of total
      );
    }

    // Phase 2: Viral moment detection
    yield const AnalysisState(
      phase: AnalysisPhase.detectingViral,
      progress: 0.33,
    );
    for (double p = 0.0; p <= 1.0; p += 0.1) {
      await Future.delayed(const Duration(milliseconds: 250));
      yield AnalysisState(
        phase: AnalysisPhase.detectingViral,
        progress: 0.33 + p * 0.33,
      );
    }

    // Phase 3: Content mapping
    yield const AnalysisState(
      phase: AnalysisPhase.mappingContent,
      progress: 0.66,
    );
    for (double p = 0.0; p <= 1.0; p += 0.1) {
      await Future.delayed(const Duration(milliseconds: 200));
      yield AnalysisState(
        phase: AnalysisPhase.mappingContent,
        progress: 0.66 + p * 0.34,
      );
    }

    yield const AnalysisState(
      phase: AnalysisPhase.completed,
      progress: 1.0,
    );
  }

  @override
  Future<ProjectAnalysis?> getCachedAnalysis(String projectId) async {
    return null; // No cache in mock.
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Analysis progress notifier
// ═══════════════════════════════════════════════════════════════════════

class AnalysisProgressNotifier extends StateNotifier<AnalysisState> {
  final AnalysisService _service;
  StreamSubscription<AnalysisState>? _subscription;

  AnalysisProgressNotifier(this._service) : super(const AnalysisState());

  Future<void> startAnalysis(String projectId) async {
    _subscription?.cancel();
    state = const AnalysisState(phase: AnalysisPhase.transcribing, progress: 0.0);

    final stopwatch = Stopwatch()..start();

    _subscription = _service.analyze(projectId).listen(
      (update) {
        state = update.copyWith(elapsed: stopwatch.elapsed);
      },
      onError: (Object error) {
        state = AnalysisState(
          phase: AnalysisPhase.failed,
          errorMessage: error.toString(),
          elapsed: stopwatch.elapsed,
        );
      },
      onDone: () {
        stopwatch.stop();
      },
    );
  }

  void cancel() {
    _subscription?.cancel();
    state = const AnalysisState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Viral moments filter / sorting
// ═══════════════════════════════════════════════════════════════════════

class ViralMomentFilter {
  final double minScore;
  final String? tagFilter;

  const ViralMomentFilter({this.minScore = 0.0, this.tagFilter});

  ViralMomentFilter copyWith({double? minScore, String? tagFilter}) {
    return ViralMomentFilter(
      minScore: minScore ?? this.minScore,
      tagFilter: tagFilter ?? this.tagFilter,
    );
  }
}

class ViralMomentFilterNotifier extends StateNotifier<ViralMomentFilter> {
  ViralMomentFilterNotifier() : super(const ViralMomentFilter());

  void setMinScore(double score) => state = state.copyWith(minScore: score);
  void setTagFilter(String? tag) => state = state.copyWith(tagFilter: tag);
  void reset() => state = const ViralMomentFilter();
}

// ═══════════════════════════════════════════════════════════════════════
// Providers
// ═══════════════════════════════════════════════════════════════════════

final analysisServiceProvider = Provider<AnalysisService>((ref) {
  return MockAnalysisService();
});

/// Analysis progress / phase state.
final analysisStateProvider =
    StateNotifierProvider<AnalysisProgressNotifier, AnalysisState>(
  (ref) => AnalysisProgressNotifier(ref.read(analysisServiceProvider)),
);

/// Filter for viral moments.
final viralMomentFilterProvider =
    StateNotifierProvider<ViralMomentFilterNotifier, ViralMomentFilter>(
  (ref) => ViralMomentFilterNotifier(),
);

/// Derived: filtered viral moments from the completed analysis.
final viralMomentsProvider = Provider<List<ViralMoment>>((ref) {
  final analysis = ref.watch(projectAnalysisProvider);
  final filter = ref.watch(viralMomentFilterProvider);

  return analysis.whenOrNull(
    data: (data) {
      if (data == null) return <ViralMoment>[];
      final moments = data.viralMoments.where((m) {
        if (m.viralityScore < filter.minScore) return false;
        if (filter.tagFilter != null && filter.tagFilter!.isNotEmpty) {
          return m.tags.contains(filter.tagFilter);
        }
        return true;
      }).toList();
      moments.sort((a, b) => b.viralityScore.compareTo(a.viralityScore));
      return moments;
    },
  ) ?? <ViralMoment>[];
});

/// Derived: transcript from the completed analysis.
final transcriptProvider = Provider<TranscriptData?>((ref) {
  final analysis = ref.watch(projectAnalysisProvider);
  return analysis.whenOrNull(
    data: (data) => data?.transcript,
  );
});

/// Derived: content map from the completed analysis.
final contentMapProvider = Provider<ContentMap?>((ref) {
  final analysis = ref.watch(projectAnalysisProvider);
  return analysis.whenOrNull(
    data: (data) => data?.contentMap,
  );
});
