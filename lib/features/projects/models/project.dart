/// Project model for the AI Video Editor app.
///
/// Represents a video editing project with its source, status, and metadata.

/// The source type of a project's video.
enum ProjectSourceType {
  file,
  link;

  factory ProjectSourceType.fromString(String value) {
    return ProjectSourceType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ProjectSourceType.file,
    );
  }

  String toJson() => name;
}

/// The processing status of a project.
enum ProjectStatus {
  draft,
  uploading,
  processing,
  analyzing,
  ready,
  editing,
  exporting,
  completed,
  failed;

  factory ProjectStatus.fromString(String value) {
    return ProjectStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ProjectStatus.draft,
    );
  }

  String toJson() => name;

  bool get isActive =>
      this == uploading ||
      this == processing ||
      this == analyzing ||
      this == editing ||
      this == exporting;

  bool get isTerminal => this == completed || this == failed;
}

/// The analysis status of a project's video.
enum AnalysisStatus {
  pending,
  inProgress,
  completed,
  failed;

  factory AnalysisStatus.fromString(String value) {
    return AnalysisStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AnalysisStatus.pending,
    );
  }

  String toJson() => name;
}

/// Represents a video editing project.
class Project {
  final String id;
  final String name;
  final ProjectSourceType sourceType;
  final String? sourcePath;
  final String? sourceUrl;
  final ProjectStatus status;
  final AnalysisStatus analysisStatus;
  final int shortsCount;
  final int longFormCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;
  final String? thumbnailUrl;

  const Project({
    required this.id,
    required this.name,
    required this.sourceType,
    this.sourcePath,
    this.sourceUrl,
    required this.status,
    required this.analysisStatus,
    this.shortsCount = 0,
    this.longFormCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
    this.thumbnailUrl,
  });

  /// Creates a Project from JSON.
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sourceType: json['sourceType'] != null
          ? ProjectSourceType.fromString(json['sourceType'] as String)
          : ProjectSourceType.file,
      sourcePath: json['sourcePath'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
      status: json['status'] != null
          ? ProjectStatus.fromString(json['status'] as String)
          : ProjectStatus.draft,
      analysisStatus: json['analysisStatus'] != null
          ? AnalysisStatus.fromString(json['analysisStatus'] as String)
          : AnalysisStatus.pending,
      shortsCount: json['shortsCount'] as int? ?? 0,
      longFormCount: json['longFormCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sourceType': sourceType.toJson(),
      'sourcePath': sourcePath,
      'sourceUrl': sourceUrl,
      'status': status.toJson(),
      'analysisStatus': analysisStatus.toJson(),
      'shortsCount': shortsCount,
      'longFormCount': longFormCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  /// Creates a copy with selective field updates.
  Project copyWith({
    String? id,
    String? name,
    ProjectSourceType? sourceType,
    String? sourcePath,
    String? sourceUrl,
    ProjectStatus? status,
    AnalysisStatus? analysisStatus,
    int? shortsCount,
    int? longFormCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
    String? thumbnailUrl,
    bool clearSourcePath = false,
    bool clearSourceUrl = false,
    bool clearThumbnailUrl = false,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      sourceType: sourceType ?? this.sourceType,
      sourcePath: clearSourcePath ? null : (sourcePath ?? this.sourcePath),
      sourceUrl: clearSourceUrl ? null : (sourceUrl ?? this.sourceUrl),
      status: status ?? this.status,
      analysisStatus: analysisStatus ?? this.analysisStatus,
      shortsCount: shortsCount ?? this.shortsCount,
      longFormCount: longFormCount ?? this.longFormCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
      thumbnailUrl: clearThumbnailUrl ? null : (thumbnailUrl ?? this.thumbnailUrl),
    );
  }

  /// Whether the project has been analyzed.
  bool get isAnalyzed => analysisStatus == AnalysisStatus.completed;

  /// Whether the project has a local source file.
  bool get hasLocalSource => sourcePath != null && sourcePath!.isNotEmpty;

  /// Whether the project has a remote source URL.
  bool get hasRemoteSource => sourceUrl != null && sourceUrl!.isNotEmpty;

  /// Total number of generated videos (shorts + long form).
  int get totalVideos => shortsCount + longFormCount;

  @override
  String toString() =>
      'Project(id: $id, name: $name, status: $status, analysisStatus: $analysisStatus)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Project &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
