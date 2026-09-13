import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/navigation_provider.dart';

// ═══════════════════════════════════════════════════════════════════════
// Domain models
// ═══════════════════════════════════════════════════════════════════════

enum ProjectStatus { draft, processing, ready, archived }

class Project {
  final String id;
  final String name;
  final String? description;
  final ProjectStatus status;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> mediaIds;
  final Map<String, dynamic> metadata;

  const Project({
    required this.id,
    required this.name,
    this.description,
    this.status = ProjectStatus.draft,
    this.thumbnailUrl,
    required this.createdAt,
    required this.updatedAt,
    this.mediaIds = const [],
    this.metadata = const {},
  });

  Project copyWith({
    String? name,
    String? description,
    ProjectStatus? status,
    String? thumbnailUrl,
    List<String>? mediaIds,
    Map<String, dynamic>? metadata,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      mediaIds: mediaIds ?? this.mediaIds,
      metadata: metadata ?? this.metadata,
    );
  }
}

class ProjectAnalysis {
  final String projectId;
  final List<ViralMoment> viralMoments;
  final TranscriptData transcript;
  final ContentMap contentMap;
  final DateTime analyzedAt;

  const ProjectAnalysis({
    required this.projectId,
    this.viralMoments = const [],
    required this.transcript,
    required this.contentMap,
    required this.analyzedAt,
  });
}

class ViralMoment {
  final String id;
  final double startTime;
  final double endTime;
  final double viralityScore;
  final String reason;
  final List<String> tags;

  const ViralMoment({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.viralityScore,
    required this.reason,
    this.tags = const [],
  });
}

class TranscriptData {
  final List<TranscriptSegment> segments;
  final String fullText;
  final String detectedLanguage;

  const TranscriptData({
    this.segments = const [],
    this.fullText = '',
    this.detectedLanguage = 'en',
  });
}

class TranscriptSegment {
  final String text;
  final double startTime;
  final double endTime;

  const TranscriptSegment({
    required this.text,
    required this.startTime,
    required this.endTime,
  });
}

class ContentMap {
  final List<ContentSection> sections;

  const ContentMap({this.sections = const []});
}

class ContentSection {
  final String title;
  final double startTime;
  final double endTime;
  final String summary;

  const ContentSection({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.summary,
  });
}

// ═══════════════════════════════════════════════════════════════════════
// Service abstraction (to be implemented by data layer)
// ═══════════════════════════════════════════════════════════════════════

abstract class ProjectService {
  Future<List<Project>> fetchProjects();
  Future<Project> getProject(String id);
  Future<Project> createProject(String name, {String? description});
  Future<Project> updateProject(String id, {String? name, String? description, ProjectStatus? status});
  Future<void> deleteProject(String id);
  Future<ProjectAnalysis> analyzeProject(String projectId);
}

/// In-memory mock for development — replace with real implementation.
class MockProjectService implements ProjectService {
  final List<Project> _projects = [];

  @override
  Future<List<Project>> fetchProjects() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_projects);
  }

  @override
  Future<Project> getProject(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _projects.firstWhere((p) => p.id == id,
        orElse: () => throw StateError('Project not found: $id'));
  }

  @override
  Future<Project> createProject(String name, {String? description}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    final project = Project(
      id: 'proj_${now.millisecondsSinceEpoch}',
      name: name,
      description: description,
      createdAt: now,
      updatedAt: now,
    );
    _projects.insert(0, project);
    return project;
  }

  @override
  Future<Project> updateProject(String id,
      {String? name, String? description, ProjectStatus? status}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _projects.indexWhere((p) => p.id == id);
    if (index == -1) throw StateError('Project not found: $id');
    final updated = _projects[index].copyWith(
      name: name,
      description: description,
      status: status,
    );
    _projects[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteProject(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _projects.removeWhere((p) => p.id == id);
  }

  @override
  Future<ProjectAnalysis> analyzeProject(String projectId) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate AI work
    return ProjectAnalysis(
      projectId: projectId,
      viralMoments: const [
        ViralMoment(
          id: 'vm_1', startTime: 12.0, endTime: 18.5,
          viralityScore: 0.92,
          reason: 'High emotional intensity and unexpected twist',
          tags: ['hook', 'emotional'],
        ),
        ViralMoment(
          id: 'vm_2', startTime: 45.0, endTime: 52.0,
          viralityScore: 0.85,
          reason: 'Funny reaction moment',
          tags: ['humor', 'reaction'],
        ),
      ],
      transcript: const TranscriptData(
        segments: [
          TranscriptSegment(text: 'Welcome to today\'s video.', startTime: 0, endTime: 3.5),
          TranscriptSegment(text: 'We\'re going to cover something amazing.', startTime: 3.5, endTime: 7.0),
        ],
        fullText: 'Welcome to today\'s video. We\'re going to cover something amazing.',
        detectedLanguage: 'en',
      ),
      contentMap: const ContentMap(sections: [
        ContentSection(
          title: 'Introduction',
          startTime: 0, endTime: 10,
          summary: 'Video opening and topic introduction',
        ),
        ContentSection(
          title: 'Main Content',
          startTime: 10, endTime: 50,
          summary: 'Core discussion and demonstration',
        ),
      ]),
      analyzedAt: DateTime.now(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Notifiers
// ═══════════════════════════════════════════════════════════════════════

/// List of all projects (async).
class ProjectListNotifier extends AsyncNotifier<List<Project>> {
  ProjectService get _service => ref.read(projectServiceProvider);

  @override
  Future<List<Project>> build() async {
    return _service.fetchProjects();
  }

  Future<Project> create(String name, {String? description}) async {
    final project = await _service.createProject(name, description: description);
    ref.invalidateSelf();
    return project;
  }

  Future<void> update(String id, {String? name, String? description, ProjectStatus? status}) async {
    await _service.updateProject(id, name: name, description: description, status: status);
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    await _service.deleteProject(id);
    ref.invalidateSelf();
    if (ref.read(currentProjectIdProvider) == id) {
      ref.read(currentProjectProvider.notifier).clear();
    }
  }
}

/// Currently selected project.
class CurrentProjectNotifier extends Notifier<Project?> {
  ProjectService get _service => ref.read(projectServiceProvider);

  @override
  Project? build() => null;

  Future<void> load(String id) async {
    state = await _service.getProject(id);
  }

  void set(Project project) {
    state = project;
  }

  void clear() {
    state = null;
  }
}

/// Holds the analysis result for the current project.
class ProjectAnalysisNotifier extends AsyncNotifier<ProjectAnalysis?> {
  ProjectService get _service => ref.read(projectServiceProvider);

  @override
  Future<ProjectAnalysis?> build() async {
    return null; // No analysis until explicitly requested.
  }

  Future<void> analyze(String projectId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.analyzeProject(projectId));
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Providers
// ═══════════════════════════════════════════════════════════════════════

/// Service provider — swap [MockProjectService] for a real impl.
final projectServiceProvider = Provider<ProjectService>((ref) {
  return MockProjectService();
});

/// All projects.
final projectListProvider =
    AsyncNotifierProvider<ProjectListNotifier, List<Project>>(
  ProjectListNotifier.new,
);

/// Currently selected project.
final currentProjectProvider =
    NotifierProvider<CurrentProjectNotifier, Project?>(
  CurrentProjectNotifier.new,
);

/// Project analysis result (lazily populated).
final projectAnalysisProvider =
    AsyncNotifierProvider<ProjectAnalysisNotifier, ProjectAnalysis?>(
  ProjectAnalysisNotifier.new,
);

/// Convenience: current project ID derived from the current project.
final currentProjectIdFromModelProvider = Provider<String?>((ref) {
  final project = ref.watch(currentProjectProvider);
  return project?.id;
});
