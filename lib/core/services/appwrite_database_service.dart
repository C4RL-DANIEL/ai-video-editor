import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';

import '../../config/appwrite_config.dart';
import '../../core/network/api_response.dart';

/// Database service using Appwrite (free tier: 75K MAU, unlimited documents).
class AppwriteDatabaseService {
  final Databases _databases;
  final String _dbId = AppwriteConfig.databaseId;

  AppwriteDatabaseService(Client client) : _databases = Databases(client);

  // ═══════════════════════════════════════════════════════════════════
  // Projects
  // ═══════════════════════════════════════════════════════════════════

  /// Create a new project document.
  Future<ApiResponse<String>> createProject({
    required String name,
    String? description,
    required String sourceType,
    String? sourcePath,
    String? sourceUrl,
  }) async {
    try {
      final doc = await _databases.createDocument(
        databaseId: _dbId,
        collectionId: AppwriteConfig.projectsCollectionId,
        documentId: ID.unique(),
        data: {
          'name': name,
          'description': description ?? '',
          'status': 'draft',
          'sourceType': sourceType,
          'sourcePath': sourcePath ?? '',
          'sourceUrl': sourceUrl ?? '',
          'shortsCount': 0,
          'longFormCount': 0,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        permissions: [
          Permission.read(Role.any()),
          Permission.write(Role.any()),
        ],
      );
      return ApiResponse.success(doc.$id);
    } on AppwriteException catch (e) {
      debugPrint('Appwrite createProject error: ${e.message}');
      return ApiResponse.error(
        'Failed to create project: ${e.message}',
        statusCode: e.code ?? 500,
      );
    }
  }

  /// Get a single project by ID.
  Future<ApiResponse<Map<String, dynamic>>> getProject(String id) async {
    try {
      final doc = await _databases.getDocument(
        databaseId: _dbId,
        collectionId: AppwriteConfig.projectsCollectionId,
        documentId: id,
      );
      return ApiResponse.success(doc.data);
    } on AppwriteException catch (e) {
      debugPrint('Appwrite getProject error: ${e.message}');
      return ApiResponse.error(
        'Failed to get project: ${e.message}',
        statusCode: e.code ?? 500,
      );
    }
  }

  /// List all projects, newest first.
  Future<ApiResponse<List<Map<String, dynamic>>>> listProjects({
    int limit = 25,
    int offset = 0,
  }) async {
    try {
      final result = await _databases.listDocuments(
        databaseId: _dbId,
        collectionId: AppwriteConfig.projectsCollectionId,
        queries: [
          Query.orderDesc('createdAt'),
          Query.limit(limit),
          Query.offset(offset),
        ],
      );
      return ApiResponse.success(
        result.documents.map((d) => d.data).toList(),
      );
    } on AppwriteException catch (e) {
      debugPrint('Appwrite listProjects error: ${e.message}');
      return ApiResponse.error(
        'Failed to list projects: ${e.message}',
        statusCode: e.code ?? 500,
      );
    }
  }

  /// Update a project.
  Future<ApiResponse<void>> updateProject(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = DateTime.now().toIso8601String();
      await _databases.updateDocument(
        databaseId: _dbId,
        collectionId: AppwriteConfig.projectsCollectionId,
        documentId: id,
        data: data,
      );
      return ApiResponse.success(null);
    } on AppwriteException catch (e) {
      debugPrint('Appwrite updateProject error: ${e.message}');
      return ApiResponse.error(
        'Failed to update project: ${e.message}',
        statusCode: e.code ?? 500,
      );
    }
  }

  /// Delete a project.
  Future<ApiResponse<void>> deleteProject(String id) async {
    try {
      await _databases.deleteDocument(
        databaseId: _dbId,
        collectionId: AppwriteConfig.projectsCollectionId,
        documentId: id,
      );
      return ApiResponse.success(null);
    } on AppwriteException catch (e) {
      debugPrint('Appwrite deleteProject error: ${e.message}');
      return ApiResponse.error(
        'Failed to delete project: ${e.message}',
        statusCode: e.code ?? 500,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Shorts
  // ═══════════════════════════════════════════════════════════════════

  /// Create a short video document.
  Future<ApiResponse<String>> createShort({
    required String projectId,
    required String title,
    required double sourceStartTime,
    required double sourceEndTime,
    String? hookText,
    int? viralScore,
  }) async {
    try {
      final doc = await _databases.createDocument(
        databaseId: _dbId,
        collectionId: AppwriteConfig.shortsCollectionId,
        documentId: ID.unique(),
        data: {
          'projectId': projectId,
          'title': title,
          'sourceStartTime': sourceStartTime,
          'sourceEndTime': sourceEndTime,
          'hookText': hookText ?? '',
          'viralScore': viralScore ?? 0,
          'status': 'draft',
          'createdAt': DateTime.now().toIso8601String(),
        },
        permissions: [
          Permission.read(Role.any()),
          Permission.write(Role.any()),
        ],
      );
      return ApiResponse.success(doc.$id);
    } on AppwriteException catch (e) {
      return ApiResponse.error(
        'Failed to create short: ${e.message}',
        statusCode: e.code ?? 500,
      );
    }
  }

  /// List shorts for a project.
  Future<ApiResponse<List<Map<String, dynamic>>>> listShorts(
    String projectId,
  ) async {
    try {
      final result = await _databases.listDocuments(
        databaseId: _dbId,
        collectionId: AppwriteConfig.shortsCollectionId,
        queries: [
          Query.equal('projectId', projectId),
          Query.orderDesc('viralScore'),
        ],
      );
      return ApiResponse.success(
        result.documents.map((d) => d.data).toList(),
      );
    } on AppwriteException catch (e) {
      return ApiResponse.error(
        'Failed to list shorts: ${e.message}',
        statusCode: e.code ?? 500,
      );
    }
  }

  /// Update a short.
  Future<ApiResponse<void>> updateShort(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _databases.updateDocument(
        databaseId: _dbId,
        collectionId: AppwriteConfig.shortsCollectionId,
        documentId: id,
        data: data,
      );
      return ApiResponse.success(null);
    } on AppwriteException catch (e) {
      return ApiResponse.error(
        'Failed to update short: ${e.message}',
        statusCode: e.code ?? 500,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Generic document operations
  // ═══════════════════════════════════════════════════════════════════

  /// Create a document in any collection.
  Future<ApiResponse<String>> createDocument({
    required String collectionId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final doc = await _databases.createDocument(
        databaseId: _dbId,
        collectionId: collectionId,
        documentId: ID.unique(),
        data: data,
        permissions: [
          Permission.read(Role.any()),
          Permission.write(Role.any()),
        ],
      );
      return ApiResponse.success(doc.$id);
    } on AppwriteException catch (e) {
      return ApiResponse.error(
        'Failed to create document: ${e.message}',
        statusCode: e.code ?? 500,
      );
    }
  }

  /// List documents in any collection with queries.
  Future<ApiResponse<List<Map<String, dynamic>>>> listDocuments({
    required String collectionId,
    List<Query>? queries,
  }) async {
    try {
      final result = await _databases.listDocuments(
        databaseId: _dbId,
        collectionId: collectionId,
        queries: queries,
      );
      return ApiResponse.success(
        result.documents.map((d) => d.data).toList(),
      );
    } on AppwriteException catch (e) {
      return ApiResponse.error(
        'Failed to list documents: ${e.message}',
        statusCode: e.code ?? 500,
      );
    }
  }
}
