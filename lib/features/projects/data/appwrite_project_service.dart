import 'dart:developer' as dev;
import 'package:appwrite/appwrite.dart';

import '../../../config/appwrite_config.dart';
import '../presentation/project_providers.dart';

/// Concrete [ProjectService] backed by Appwrite TablesDB.
class AppwriteProjectService implements ProjectService {
  final TablesDB _tablesDB;
  final String _dbId = AppwriteConfig.databaseId;
  final String _tableId = AppwriteConfig.projectsCollectionId;

  AppwriteProjectService(Client client) : _tablesDB = TablesDB(client);

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
      final result = await _tablesDB.listRows(
        databaseId: _dbId,
        tableId: _tableId,
        queries: [
          Query.orderDesc('createdAt'),
          Query.limit(100),
        ],
      );
      return result.rows.map((r) => _rowToProject(r.data)).toList();
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
      final row = await _tablesDB.getRow(
        databaseId: _dbId,
        tableId: _tableId,
        rowId: id,
      );
      return _rowToProject(row.data);
    } on AppwriteException catch (e) {
      throw StateError('Failed to get project: ${e.message}');
    }
  }

  @override
  Future<Project> createProject(String name, {String? description}) async {
    try {
      final now = DateTime.now().toIso8601String();
      final row = await _tablesDB.createRow(
        databaseId: _dbId,
        tableId: _tableId,
        rowId: ID.unique(),
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
      return _rowToProject(row.data);
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

      final row = await _tablesDB.updateRow(
        databaseId: _dbId,
        tableId: _tableId,
        rowId: id,
        data: data,
      );
      return _rowToProject(row.data);
    } on AppwriteException catch (e) {
      throw StateError('Failed to update project: ${e.message}');
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    try {
      await _tablesDB.deleteRow(
        databaseId: _dbId,
        tableId: _tableId,
        rowId: id,
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
