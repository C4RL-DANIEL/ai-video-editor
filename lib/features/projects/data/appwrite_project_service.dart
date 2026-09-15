import 'dart:developer' as dev;
import 'package:appwrite/appwrite.dart';

import '../../../config/appwrite_config.dart';
import '../presentation/project_providers.dart';

/// Concrete [ProjectService] backed by Appwrite Database (SDK v13).
class AppwriteProjectService implements ProjectService {
  final Databases _databases;
  final String _dbId = AppwriteConfig.databaseId;
  final String _colId = AppwriteConfig.projectsCollectionId;

  AppwriteProjectService(Client client) : _databases = Databases(client);

  Project _docToProject(Map<String, dynamic> data) {
    return Project(
      id: data[r'$id'] as String? ?? '',
      name: data['name'] as String? ?? 'Untitled',
      description: data['description'] as String?,
      status: ProjectStatus.fromString(data['status'] as String? ?? 'draft'),
      thumbnailUrl: data['thumbnailUrl'] as String?,
      createdAt: _parseDate(data['createdAt']),
      shortsCount: _parseInt(data['shortsCount']),
      longFormCount: _parseInt(data['longFormCount']),
    );
  }

  DateTime _parseDate(dynamic v) {
    if (v is String) return DateTime.tryParse(v) ?? DateTime(2025);
    return DateTime(2025);
  }

  int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  @override
  Future<List<Project>> fetchProjects() async {
    try {
      final result = await _databases.listDocuments(
        databaseId: _dbId,
        collectionId: _colId,
        queries: [Query.orderDesc('createdAt'), Query.limit(100)],
      );
      return result.documents.map((d) => _docToProject(d.data)).toList();
    } catch (e) {
      dev.log('fetchProjects error: $e');
      return [];
    }
  }

  @override
  Future<Project> getProject(String id) async {
    try {
      final doc = await _databases.getDocument(
        databaseId: _dbId, collectionId: _colId, documentId: id,
      );
      return _docToProject(doc.data);
    } catch (e) {
      dev.log('getProject error: $e');
      return Project(id: id, name: 'Project', createdAt: DateTime.now());
    }
  }

  @override
  Future<Project> createProject(String name, {String? description}) async {
    final id = ID.unique();
    try {
      final doc = await _databases.createDocument(
        databaseId: _dbId, collectionId: _colId, documentId: id,
        data: {
          'name': name, 'description': description ?? '',
          'status': 'draft', 'createdAt': DateTime.now().toIso8601String(),
          'shortsCount': 0, 'longFormCount': 0,
        },
      );
      return _docToProject(doc.data);
    } catch (e) {
      dev.log('createProject error: $e');
      return Project(id: id, name: name, description: description, createdAt: DateTime.now());
    }
  }

  @override
  Future<Project> updateProject(String id, {String? name, String? description, ProjectStatus? status}) async {
    try {
      final data = <String, dynamic>{
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (status != null) 'status': status.name,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await _databases.updateDocument(
        databaseId: _dbId, collectionId: _colId, documentId: id, data: data,
      );
      return getProject(id);
    } catch (e) {
      dev.log('updateProject error: $e');
      return Project(id: id, name: name ?? '', createdAt: DateTime.now());
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    try {
      await _databases.deleteDocument(databaseId: _dbId, collectionId: _colId, documentId: id);
    } catch (e) {
      dev.log('deleteProject error: $e');
    }
  }

  @override
  Future<ProjectAnalysis> analyzeProject(String projectId) async {
    // Placeholder — real analysis would call the Appwrite Function
    return ProjectAnalysis(
      projectId: projectId,
      viralMoments: const [],
      transcript: const TranscriptData(segments: [], fullText: ''),
      contentMap: const ContentMap(),
      analyzedAt: DateTime.now(),
    );
  }
}
