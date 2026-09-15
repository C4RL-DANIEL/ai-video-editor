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

  // ── Helpers ──

  Project _docToProject(Map<String, dynamic> data) {
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

  // ── CRUD ──

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
      return result.documents.map((d) => _docToProject(d.data)).toList();
    } on AppwriteException catch (e) {
      dev.log('Appwrite fetchProjects error: ${e.message}');
      return [];
    } catch (e) {
      dev.log('Unexpected error fetching projects: $e');
      return [];
    }
  }

  @override
  Future<Project?> getProject(String id) async {
    try {
      final doc = await _databases.getDocument(
        databaseId: _dbId,
        collectionId: _colId,
        documentId: id,
      );
      return _docToProject(doc.data);
    } on AppwriteException catch (e) {
      dev.log('Appwrite getProject error: ${e.message}');
      return null;
    }
  }

  @override
  Future<Project> createProject({
    required String name,
    String? description,
    String? videoSource,
    String? thumbnailUrl,
  }) async {
    final id = ID.unique();
    final data = {
      'name': name,
      'description': description ?? '',
      'status': 'draft',
      'videoSource': videoSource ?? '',
      'thumbnailUrl': thumbnailUrl ?? '',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'shortsCount': 0,
      'longFormCount': 0,
    };

    try {
      final doc = await _databases.createDocument(
        databaseId: _dbId,
        collectionId: _colId,
        documentId: id,
        data: data,
      );
      return _docToProject(doc.data);
    } on AppwriteException catch (e) {
      dev.log('Appwrite createProject error: ${e.message}');
      // Return a local project if database write fails
      return Project(
        id: id,
        name: name,
        description: description,
        status: ProjectStatus.draft,
        createdAt: DateTime.now(),
      );
    }
  }

  @override
  Future<Project> updateProject(Project project) async {
    final data = {
      'name': project.name,
      'description': project.description ?? '',
      'status': project.status.name,
      'thumbnailUrl': project.thumbnailUrl ?? '',
      'updatedAt': DateTime.now().toIso8601String(),
      'shortsCount': project.shortsCount,
      'longFormCount': project.longFormCount,
    };

    try {
      await _databases.updateDocument(
        databaseId: _dbId,
        collectionId: _colId,
        documentId: project.id,
        data: data,
      );
      return project;
    } on AppwriteException catch (e) {
      dev.log('Appwrite updateProject error: ${e.message}');
      return project;
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
      dev.log('Appwrite deleteProject error: ${e.message}');
    }
  }
}
