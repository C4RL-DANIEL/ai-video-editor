import 'dart:developer' as dev;
import 'package:appwrite/appwrite.dart';

import '../../../config/appwrite_config.dart';
import '../presentation/project_providers.dart';

/// Concrete [ProjectService] backed by Appwrite TablesDB.
class AppwriteProjectService implements ProjectService {
  final Databases _databases;
  final String _dbId = AppwriteConfig.databaseId;
  final String _colId = AppwriteConfig.projectsCollectionId;

  AppwriteProjectService(Client client) : _databases = Databases(client);

  // ── Helpers ──

  Project _rowToProject(Map<String, dynamic> data) {
    return Project(
      id: data[r'$id'] as String? ?? data['id'] as String? ?? '',
      name: data['name'] as String? ?? 'Untitled',
      description: data['description'] as String?,
      status: ProjectStatus.fromString(data['status'] as String? ?? 'draft'),
      thumbnailUrl: data['thumbnailUrl'] as String?,
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
      shortsCount: _parseInt(data['shortsCount']),
      longFormCount: _parseInt(data['longFormCount']),
    );
  }

  DateTime _parseDate(dynamic v) {
    if (v is String) return DateTime.tryParse(v) ?? DateTime(2025);
    if (v is DateTime) return v;
    return DateTime(2025);
  }

  int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  // ── ProjectService implementation ──

  @override
  Future<List<Project>> fetchProjects() async {
    try {
      final result = await _databases.listDocuments(
        databaseId: _dbId,
        collectionId: _colId,
        queries: [
          Query.orderDesc('createdAt'),
          Query.limit(100),
        ],
      );
      return result.documents.map((d) => _rowToProject(d.data)).toList();
    } on AppwriteException catch (e) {
      dev.log('Appwrite fetchProjects error: ${e.message}');
      return []; // Graceful degradation
    } catch (e) {
      dev.log('Unexpected error fetching projects: $e');
      return [];
    }
  }

  @override
  Future<Project> getProject(String id) async {
    try {
      final doc = await _databases.getDocument(
        databaseId: _dbId,
        collectionId: _colId,
        documentId: id,
      );
      return _rowToProject(doc.data);
    } on AppwriteException catch (e) {
      throw StateError('Failed to get project: ${e.message}');
    }
  }

  @override
  Future<Project> createProject(String name, {String? description}) async {
    try {
      final now = DateTime.now().toIso8601String();
      final doc = await _databases.createDocument(
        databaseId: _dbId,
        collectionId: _colId,
        documentId: ID.unique(),
        data: {
          'name': name,
          'description': description ?? '',
          'status': 'draft',
          'shortsCount': 0,
          'longFormCount': 0,
          'createdAt': now,
          'updatedAt': now,
        },
        permissions: [
          Permission.read(Role.any()),
          Permission.write(Role.any()),
        ],
      );
      return _rowToProject(doc.data);
    } on AppwriteException catch (e) {
      throw StateError('Failed to create project: ${e.message}');
    }
  }

  @override
  Future<Project> updateProject(
    String id, {
    String? name,
    String? description,
    ProjectStatus? status,
  }) async {
    try {
      final data = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (status != null) data['status'] = status.value;

      final doc = await _databases.updateDocument(
        databaseId: _dbId,
        collectionId: _colId,
        documentId: id,
        data: data,
      );
      return _rowToProject(doc.data);
    } on AppwriteException catch (e) {
      throw StateError('Failed to update project: ${e.message}');
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    try {
      await _databases.deleteDocument(
        databaseId: _dbId,
        collectionId: _colId,
        documentId: id,
      );
    } on AppwriteException catch (e) {
      throw StateError('Failed to delete project: ${e.message}');
    }
  }

  @override
  Future<ProjectAnalysis> analyzeProject(String projectId) async {
    // TODO: integrate with AI analysis service
    return ProjectAnalysis(
      projectId: projectId,
      viralMoments: const [],
      transcript: const TranscriptData(),
      contentMap: const ContentMap(),
      analyzedAt: DateTime.now(),
    );
  }
}
