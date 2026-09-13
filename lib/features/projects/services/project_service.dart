import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';

/// Represents a project entity.
class Project {
  const Project({
    required this.id,
    required this.name,
    required this.createdAt,
    this.description,
    this.videoPath,
    this.status = ProjectStatus.draft,
    this.analysisId,
    this.updatedAt,
    this.metadata,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      description: json['description'] as String?,
      videoPath: json['videoPath'] as String?,
      status: ProjectStatus.fromString(json['status'] as String? ?? 'draft'),
      analysisId: json['analysisId'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  final String id;
  final String name;
  final DateTime createdAt;
  final String? description;
  final String? videoPath;
  final ProjectStatus status;
  final String? analysisId;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'description': description,
        'videoPath': videoPath,
        'status': status.value,
        'analysisId': analysisId,
        'updatedAt': updatedAt?.toIso8601String(),
        'metadata': metadata,
      };
}

/// Status lifecycle of a project.
enum ProjectStatus {
  draft('draft'),
  uploaded('uploaded'),
  analyzing('analyzing'),
  ready('ready'),
  processing('processing'),
  completed('completed'),
  failed('failed');

  const ProjectStatus(this.value);

  final String value;

  factory ProjectStatus.fromString(String value) {
    return ProjectStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ProjectStatus.draft,
    );
  }
}

/// Analysis result returned from the AI backend.
class ProjectAnalysis {
  const ProjectAnalysis({
    required this.projectId,
    required this.status,
    this.moments,
    this.transcript,
    this.contentMap,
    this.completedAt,
  });

  factory ProjectAnalysis.fromJson(Map<String, dynamic> json) {
    return ProjectAnalysis(
      projectId: json['projectId'] as String,
      status: json['status'] as String,
      moments: (json['moments'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      transcript: json['transcript'] as String?,
      contentMap: json['contentMap'] as Map<String, dynamic>?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  final String projectId;
  final String status;
  final List<Map<String, dynamic>>? moments;
  final String? transcript;
  final Map<String, dynamic>? contentMap;
  final DateTime? completedAt;
}

/// Service layer for project-related API operations.
///
/// The concrete implementation delegates to [ApiClient] and always returns
/// results via [ApiResponse].
class ProjectService {
  ProjectService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  // ---------------------------------------------------------------------------
  // CRUD
  // ---------------------------------------------------------------------------

  /// Fetches all projects for the current user.
  Future<ApiResponse<List<Project>>> getProjects({
    int page = 1,
    int pageSize = 20,
  }) async {
    return _api.get<List<Project>>(
      '/projects',
      queryParameters: {'page': page, 'pageSize': pageSize},
      fromJson: (data) {
        final list = data as List<dynamic>;
        return list
            .map((e) => Project.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Fetches a single project by [id].
  Future<ApiResponse<Project>> getProject(String id) async {
    return _api.get<Project>(
      '/projects/$id',
      fromJson: (data) => Project.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Creates a new project with [data].
  Future<ApiResponse<Project>> createProject(Map<String, dynamic> data) async {
    return _api.post<Project>(
      '/projects',
      data: data,
      fromJson: (data) => Project.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Updates an existing project identified by [id].
  Future<ApiResponse<Project>> updateProject(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _api.patch<Project>(
      '/projects/$id',
      data: data,
      fromJson: (data) => Project.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Deletes a project by [id].
  Future<ApiResponse<void>> deleteProject(String id) async {
    return _api.delete<void>('/projects/$id');
  }

  // ---------------------------------------------------------------------------
  // Analysis
  // ---------------------------------------------------------------------------

  /// Kicks off AI analysis for the given project.
  Future<ApiResponse<Map<String, dynamic>>> analyzeProject(String id) async {
    return _api.post<Map<String, dynamic>>(
      '/projects/$id/analyze',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// Retrieves the current analysis result for the project.
  Future<ApiResponse<ProjectAnalysis>> getProjectAnalysis(String id) async {
    return _api.get<ProjectAnalysis>(
      '/projects/$id/analysis',
      fromJson: (data) =>
          ProjectAnalysis.fromJson(data as Map<String, dynamic>),
    );
  }
}
