import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../projects/presentation/project_providers.dart';

// ═══════════════════════════════════════════════════════════════════════
// Domain models
// ═══════════════════════════════════════════════════════════════════════

enum LongFormStatus { draft, generating, ready, failed }

class LongFormVideo {
  final String id;
  final String projectId;
  final String title;
  final String? description;
  final LongFormStatus status;
  final double totalDuration;
  final String? thumbnailUrl;
  final String? videoUrl;
  final List<String> chapterIds;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LongFormVideo({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    this.status = LongFormStatus.draft,
    this.totalDuration = 0,
    this.thumbnailUrl,
    this.videoUrl,
    this.chapterIds = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  LongFormVideo copyWith({
    String? title,
    String? description,
    LongFormStatus? status,
    double? totalDuration,
    String? thumbnailUrl,
    String? videoUrl,
    List<String>? chapterIds,
    Map<String, dynamic>? metadata,
  }) {
    return LongFormVideo(
      id: id,
      projectId: projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      totalDuration: totalDuration ?? this.totalDuration,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      chapterIds: chapterIds ?? this.chapterIds,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class Chapter {
  final String id;
  final String longFormId;
  final String title;
  final String? description;
  final int order;
  final double startTime;
  final double endTime;
  final String? thumbnailUrl;

  const Chapter({
    required this.id,
    required this.longFormId,
    required this.title,
    this.description,
    required this.order,
    required this.startTime,
    required this.endTime,
    this.thumbnailUrl,
  });

  double get duration => endTime - startTime;

  Chapter copyWith({
    String? title,
    String? description,
    int? order,
    double? startTime,
    double? endTime,
    String? thumbnailUrl,
  }) {
    return Chapter(
      id: id,
      longFormId: longFormId,
      title: title ?? this.title,
      description: description ?? this.description,
      order: order ?? this.order,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Service abstraction
// ═══════════════════════════════════════════════════════════════════════

abstract class LongFormService {
  Future<List<LongFormVideo>> fetchLongForms(String projectId);
  Future<LongFormVideo> getLongForm(String longFormId);
  Future<LongFormVideo> createLongForm(String projectId, String title, {String? description});
  Future<LongFormVideo> updateLongForm(String longFormId, {String? title, String? description, LongFormStatus? status});
  Future<void> deleteLongForm(String longFormId);

  Future<List<Chapter>> fetchChapters(String longFormId);
  Future<Chapter> addChapter(String longFormId, String title, {String? description});
  Future<Chapter> updateChapter(String chapterId, {String? title, String? description, double? startTime, double? endTime, int? order});
  Future<void> deleteChapter(String chapterId);
  Future<List<Chapter>> autoGenerateChapters(String longFormId);
}

class MockLongFormService implements LongFormService {
  final Map<String, List<LongFormVideo>> _longFormsByProject = {};
  final Map<String, List<Chapter>> _chaptersByLongForm = {};

  @override
  Future<List<LongFormVideo>> fetchLongForms(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_longFormsByProject[projectId] ?? []);
  }

  @override
  Future<LongFormVideo> getLongForm(String longFormId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (final list in _longFormsByProject.values) {
      try {
        return list.firstWhere((lf) => lf.id == longFormId);
      } catch (_) {}
    }
    throw StateError('Long-form video not found: $longFormId');
  }

  @override
  Future<LongFormVideo> createLongForm(String projectId, String title, {String? description}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    final video = LongFormVideo(
      id: 'longform_${now.millisecondsSinceEpoch}',
      projectId: projectId,
      title: title,
      description: description,
      createdAt: now,
      updatedAt: now,
    );
    _longFormsByProject.putIfAbsent(projectId, () => []).add(video);
    return video;
  }

  @override
  Future<LongFormVideo> updateLongForm(String longFormId,
      {String? title, String? description, LongFormStatus? status}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (final list in _longFormsByProject.values) {
      final idx = list.indexWhere((lf) => lf.id == longFormId);
      if (idx != -1) {
        list[idx] = list[idx].copyWith(title: title, description: description, status: status);
        return list[idx];
      }
    }
    throw StateError('Long-form video not found: $longFormId');
  }

  @override
  Future<void> deleteLongForm(String longFormId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (final list in _longFormsByProject.values) {
      list.removeWhere((lf) => lf.id == longFormId);
    }
    _chaptersByLongForm.remove(longFormId);
  }

  @override
  Future<List<Chapter>> fetchChapters(String longFormId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_chaptersByLongForm[longFormId] ?? []);
  }

  @override
  Future<Chapter> addChapter(String longFormId, String title, {String? description}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final chapters = _chaptersByLongForm.putIfAbsent(longFormId, () => []);
    final order = chapters.length;
    final chapter = Chapter(
      id: 'ch_${DateTime.now().millisecondsSinceEpoch}',
      longFormId: longFormId,
      title: title,
      description: description,
      order: order,
      startTime: chapters.isEmpty ? 0 : chapters.last.endTime,
      endTime: chapters.isEmpty ? 30 : chapters.last.endTime + 30,
    );
    chapters.add(chapter);
    return chapter;
  }

  @override
  Future<Chapter> updateChapter(String chapterId,
      {String? title, String? description, double? startTime, double? endTime, int? order}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (final chapters in _chaptersByLongForm.values) {
      final idx = chapters.indexWhere((c) => c.id == chapterId);
      if (idx != -1) {
        chapters[idx] = chapters[idx].copyWith(
          title: title,
          description: description,
          startTime: startTime,
          endTime: endTime,
          order: order,
        );
        return chapters[idx];
      }
    }
    throw StateError('Chapter not found: $chapterId');
  }

  @override
  Future<void> deleteChapter(String chapterId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (final chapters in _chaptersByLongForm.values) {
      chapters.removeWhere((c) => c.id == chapterId);
    }
  }

  @override
  Future<List<Chapter>> autoGenerateChapters(String longFormId) async {
    await Future.delayed(const Duration(seconds: 2));
    final chapters = _chaptersByLongForm.putIfAbsent(longFormId, () => []);
    chapters.clear();

    final autoChapters = [
      Chapter(id: 'auto_1', longFormId: longFormId, title: 'Introduction', order: 0, startTime: 0, endTime: 60),
      Chapter(id: 'auto_2', longFormId: longFormId, title: 'Main Topic', order: 1, startTime: 60, endTime: 240),
      Chapter(id: 'auto_3', longFormId: longFormId, title: 'Deep Dive', order: 2, startTime: 240, endTime: 420),
      Chapter(id: 'auto_4', longFormId: longFormId, title: 'Conclusion', order: 3, startTime: 420, endTime: 480),
    ];
    chapters.addAll(autoChapters);
    return autoChapters;
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Notifiers
// ═══════════════════════════════════════════════════════════════════════

/// List of long-form videos for a project.
class LongFormListNotifier extends AsyncNotifier<List<LongFormVideo>> {
  LongFormService get _service => ref.read(longFormServiceProvider);

  @override
  Future<List<LongFormVideo>> build() async {
    final project = ref.watch(currentProjectProvider);
    if (project == null) return [];
    return _service.fetchLongForms(project.id);
  }

  Future<LongFormVideo> create(String title, {String? description}) async {
    final project = ref.read(currentProjectProvider);
    if (project == null) throw StateError('No project selected');
    final video = await _service.createLongForm(project.id, title, description: description);
    ref.invalidateSelf();
    return video;
  }

  Future<void> updateLongForm(String longFormId, {String? title, String? description}) async {
    await _service.updateLongForm(longFormId, title: title, description: description);
    ref.invalidateSelf();
  }

  Future<void> delete(String longFormId) async {
    await _service.deleteLongForm(longFormId);
    ref.invalidateSelf();
    if (ref.read(currentLongFormProvider)?.id == longFormId) {
      ref.read(currentLongFormProvider.notifier).clear();
    }
  }
}

/// Currently selected long-form video.
class CurrentLongFormNotifier extends Notifier<LongFormVideo?> {
  LongFormService get _service => ref.read(longFormServiceProvider);

  @override
  LongFormVideo? build() => null;

  Future<void> load(String longFormId) async {
    state = await _service.getLongForm(longFormId);
  }

  void set(LongFormVideo video) => state = video;
  void clear() => state = null;
}

/// Chapter list for the current long-form video.
class ChapterListNotifier extends AsyncNotifier<List<Chapter>> {
  LongFormService get _service => ref.read(longFormServiceProvider);

  @override
  Future<List<Chapter>> build() async {
    final lf = ref.watch(currentLongFormProvider);
    if (lf == null) return [];
    return _service.fetchChapters(lf.id);
  }

  Future<Chapter> add(String title, {String? description}) async {
    final lf = ref.read(currentLongFormProvider);
    if (lf == null) throw StateError('No long-form video selected');
    final chapter = await _service.addChapter(lf.id, title, description: description);
    ref.invalidateSelf();
    return chapter;
  }

  Future<void> updateChapter(String chapterId, {String? title, String? description, double? startTime, double? endTime}) async {
    await _service.updateChapter(chapterId, title: title, description: description, startTime: startTime, endTime: endTime);
    ref.invalidateSelf();
  }

  Future<void> delete(String chapterId) async {
    await _service.deleteChapter(chapterId);
    ref.invalidateSelf();
  }

  Future<void> autoGenerate() async {
    final lf = ref.read(currentLongFormProvider);
    if (lf == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.autoGenerateChapters(lf.id));
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final currentChapters = state.valueOrNull;
    if (currentChapters == null) return;
    final list = List<Chapter>.from(currentChapters);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
    // Update order values
    for (int i = 0; i < list.length; i++) {
      if (list[i].order != i) {
        await _service.updateChapter(list[i].id, order: i);
      }
    }
    state = AsyncValue.data(list);
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Providers
// ═══════════════════════════════════════════════════════════════════════

final longFormServiceProvider = Provider<LongFormService>((ref) {
  return MockLongFormService();
});

/// List of long-form videos for the current project.
final longFormListProvider =
    AsyncNotifierProvider<LongFormListNotifier, List<LongFormVideo>>(
  LongFormListNotifier.new,
);

/// Currently selected long-form video.
final currentLongFormProvider =
    NotifierProvider<CurrentLongFormNotifier, LongFormVideo?>(
  CurrentLongFormNotifier.new,
);

/// Chapters for the current long-form video.
final chapterProvider =
    AsyncNotifierProvider<ChapterListNotifier, List<Chapter>>(
  ChapterListNotifier.new,
);

/// Derived: total chapter count.
final chapterCountProvider = Provider<int>((ref) {
  return ref.watch(chapterProvider).valueOrNull?.length ?? 0;
});

/// Derived: total long-form video count.
final longFormCountProvider = Provider<int>((ref) {
  return ref.watch(longFormListProvider).valueOrNull?.length ?? 0;
});
