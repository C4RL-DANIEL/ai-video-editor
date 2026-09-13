import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../projects/presentation/project_providers.dart';

// ═══════════════════════════════════════════════════════════════════════
// Domain models
// ═══════════════════════════════════════════════════════════════════════

enum ShortStatus { generating, ready, failed }

enum ShortStyle { talkingHead, bRoll, splitScreen, montage }

class ShortVideo {
  final String id;
  final String projectId;
  final String title;
  final ShortStatus status;
  final ShortStyle style;
  final double duration; // seconds
  final String? thumbnailUrl;
  final String? videoUrl;
  final List<String> tags;
  final double viralScore;
  final String? hookText;
  final DateTime createdAt;

  const ShortVideo({
    required this.id,
    required this.projectId,
    required this.title,
    this.status = ShortStatus.generating,
    this.style = ShortStyle.talkingHead,
    this.duration = 0,
    this.thumbnailUrl,
    this.videoUrl,
    this.tags = const [],
    this.viralScore = 0.0,
    this.hookText,
    required this.createdAt,
  });

  ShortVideo copyWith({
    String? title,
    ShortStatus? status,
    ShortStyle? style,
    double? duration,
    String? thumbnailUrl,
    String? videoUrl,
    List<String>? tags,
    double? viralScore,
    String? hookText,
  }) {
    return ShortVideo(
      id: id,
      projectId: projectId,
      title: title ?? this.title,
      status: status ?? this.status,
      style: style ?? this.style,
      duration: duration ?? this.duration,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      tags: tags ?? this.tags,
      viralScore: viralScore ?? this.viralScore,
      hookText: hookText ?? this.hookText,
      createdAt: createdAt,
    );
  }
}

class HookSuggestion {
  final String text;
  final String style; // "question", "boldStatement", "curiosityGap", etc.
  final double score;

  const HookSuggestion({
    required this.text,
    required this.style,
    this.score = 0.0,
  });
}

class ShortsGenerationRequest {
  final String projectId;
  final ShortStyle style;
  final double? startTime;
  final double? endTime;
  final int count;
  final String? customPrompt;

  const ShortsGenerationRequest({
    required this.projectId,
    this.style = ShortStyle.talkingHead,
    this.startTime,
    this.endTime,
    this.count = 3,
    this.customPrompt,
  });
}

// ═══════════════════════════════════════════════════════════════════════
// Service abstraction
// ═══════════════════════════════════════════════════════════════════════

abstract class ShortsService {
  Future<List<ShortVideo>> fetchShorts(String projectId);
  Future<ShortVideo> getShort(String projectId, String shortId);
  Stream<List<ShortVideo>> generateShorts(ShortsGenerationRequest request);
  Future<ShortVideo> updateShort(String shortId, {String? title, ShortStyle? style});
  Future<void> deleteShort(String shortId);
  Future<List<HookSuggestion>> generateHooks(String shortId, {int count = 5});
}

class MockShortsService implements ShortsService {
  final Map<String, List<ShortVideo>> _shortsByProject = {};

  @override
  Future<List<ShortVideo>> fetchShorts(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_shortsByProject[projectId] ?? []);
  }

  @override
  Future<ShortVideo> getShort(String projectId, String shortId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final shorts = _shortsByProject[projectId] ?? [];
    return shorts.firstWhere((s) => s.id == shortId,
        orElse: () => throw StateError('Short not found: $shortId'));
  }

  @override
  Stream<List<ShortVideo>> generateShorts(ShortsGenerationRequest request) async* {
    final generated = <ShortVideo>[];
    final now = DateTime.now();

    for (int i = 0; i < request.count; i++) {
      await Future.delayed(const Duration(seconds: 1));
      final short = ShortVideo(
        id: 'short_${now.millisecondsSinceEpoch}_$i',
        projectId: request.projectId,
        title: 'AI Short #${i + 1}',
        status: ShortStatus.ready,
        style: request.style,
        duration: 30 + (i * 5).toDouble(),
        viralScore: 0.7 + (i * 0.05),
        tags: ['ai-generated', request.style.name],
        hookText: 'This will blow your mind... 🤯',
        createdAt: now,
      );
      generated.add(short);
      yield List.unmodifiable(generated);
    }
  }

  @override
  Future<ShortVideo> updateShort(String shortId, {String? title, ShortStyle? style}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (final shorts in _shortsByProject.values) {
      final idx = shorts.indexWhere((s) => s.id == shortId);
      if (idx != -1) {
        final updated = shorts[idx].copyWith(title: title, style: style);
        shorts[idx] = updated;
        return updated;
      }
    }
    throw StateError('Short not found: $shortId');
  }

  @override
  Future<void> deleteShort(String shortId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (final shorts in _shortsByProject.values) {
      shorts.removeWhere((s) => s.id == shortId);
    }
  }

  @override
  Future<List<HookSuggestion>> generateHooks(String shortId, {int count = 5}) async {
    await Future.delayed(const Duration(seconds: 1));
    return const [
      HookSuggestion(text: "What happens next will change everything...", style: "curiosityGap", score: 0.95),
      HookSuggestion(text: "POV: You discover the secret everyone missed", style: "boldStatement", score: 0.88),
      HookSuggestion(text: "Did you know this about...?", style: "question", score: 0.82),
      HookSuggestion(text: "Stop scrolling. This is important.", style: "imperative", score: 0.79),
      HookSuggestion(text: "The #1 mistake everyone makes", style: "listicle", score: 0.75),
    ];
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Notifiers
// ═══════════════════════════════════════════════════════════════════════

/// Manages the list of shorts for a specific project.
class ShortsListNotifier extends AsyncNotifier<List<ShortVideo>> {
  ShortsService get _service => ref.read(shortsServiceProvider);

  String? _currentProjectId;

  @override
  Future<List<ShortVideo>> build() async {
    // Watch the current project to auto-reload.
    final project = ref.watch(currentProjectProvider);
    _currentProjectId = project?.id;

    if (_currentProjectId == null) return [];
    return _service.fetchShorts(_currentProjectId!);
  }

  /// Generate new shorts for the given project.
  Stream<List<ShortVideo>> generate(ShortsGenerationRequest request) {
    return _service.generateShorts(request);
  }

  Future<void> updateShort(String shortId, {String? title, ShortStyle? style}) async {
    await _service.updateShort(shortId, title: title, style: style);
    ref.invalidateSelf();
  }

  Future<void> deleteShort(String shortId) async {
    await _service.deleteShort(shortId);
    ref.invalidateSelf();
  }
}

/// Currently selected short for detail view / editing.
class CurrentShortNotifier extends Notifier<ShortVideo?> {
  ShortsService get _service => ref.read(shortsServiceProvider);

  @override
  ShortVideo? build() => null;

  Future<void> load(String projectId, String shortId) async {
    state = await _service.getShort(projectId, shortId);
  }

  void set(ShortVideo short) => state = short;
  void clear() => state = null;
}

/// Manages hook generation for a specific short.
class HookGeneratorNotifier extends AsyncNotifier<List<HookSuggestion>> {
  ShortsService get _service => ref.read(shortsServiceProvider);

  @override
  Future<List<HookSuggestion>> build() async => [];

  Future<void> generate(String shortId, {int count = 5}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _service.generateHooks(shortId, count: count),
    );
  }
}

/// Controls the shorts generation process and its status.
class ShortsGeneratorNotifier extends StateNotifier<ShortsGeneratorState> {
  final ShortsService _service;
  StreamSubscription<List<ShortVideo>>? _subscription;

  ShortsGeneratorNotifier(this._service) : super(const ShortsGeneratorState());

  void generate(ShortsGenerationRequest request) {
    _subscription?.cancel();
    state = state.copyWith(isGenerating: true, generatedCount: 0);

    _subscription = _service.generateShorts(request).listen(
      (shorts) {
        state = state.copyWith(
          generatedCount: shorts.length,
          latestBatch: shorts,
        );
      },
      onDone: () {
        state = state.copyWith(isGenerating: false);
      },
      onError: (Object error) {
        state = state.copyWith(isGenerating: false, error: error.toString());
      },
    );
  }

  void cancel() {
    _subscription?.cancel();
    state = const ShortsGeneratorState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class ShortsGeneratorState {
  final bool isGenerating;
  final int generatedCount;
  final List<ShortVideo>? latestBatch;
  final String? error;

  const ShortsGeneratorState({
    this.isGenerating = false,
    this.generatedCount = 0,
    this.latestBatch,
    this.error,
  });

  ShortsGeneratorState copyWith({
    bool? isGenerating,
    int? generatedCount,
    List<ShortVideo>? latestBatch,
    String? error,
  }) {
    return ShortsGeneratorState(
      isGenerating: isGenerating ?? this.isGenerating,
      generatedCount: generatedCount ?? this.generatedCount,
      latestBatch: latestBatch ?? this.latestBatch,
      error: error ?? this.error,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Providers
// ═══════════════════════════════════════════════════════════════════════

final shortsServiceProvider = Provider<ShortsService>((ref) {
  return MockShortsService();
});

/// List of shorts for the current project.
final shortsListProvider =
    AsyncNotifierProvider<ShortsListNotifier, List<ShortVideo>>(
  ShortsListNotifier.new,
);

/// Currently selected short video.
final currentShortProvider =
    NotifierProvider<CurrentShortNotifier, ShortVideo?>(
  CurrentShortNotifier.new,
);

/// Short generation orchestrator.
final shortsGeneratorProvider =
    StateNotifierProvider<ShortsGeneratorNotifier, ShortsGeneratorState>(
  (ref) => ShortsGeneratorNotifier(ref.read(shortsServiceProvider)),
);

/// Hook suggestions for a short.
final hookGeneratorProvider =
    AsyncNotifierProvider<HookGeneratorNotifier, List<HookSuggestion>>(
  HookGeneratorNotifier.new,
);

/// Derived: total shorts count.
final shortsCountProvider = Provider<int>((ref) {
  return ref.watch(shortsListProvider).valueOrNull?.length ?? 0;
});
