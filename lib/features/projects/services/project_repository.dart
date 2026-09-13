import 'package:flutter/foundation.dart';

import '../../../core/network/api_response.dart';
import 'project_service.dart';

/// In-memory cache entry with optional expiry.
class _CacheEntry<T> {
  _CacheEntry(this.data, {Duration ttl = const Duration(minutes: 5)})
      : expiry = DateTime.now().add(ttl);

  final T data;
  final DateTime expiry;

  bool get isExpired => DateTime.now().isAfter(expiry);
}

/// Wraps [ProjectService] with in-memory caching and observable state.
///
/// Consumers (e.g. Blocs / ViewModels) should call through this repository
/// rather than directly hitting the service so that identical network calls are
/// de-duplicated and cached for a short period.
class ProjectRepository {
  ProjectRepository({ProjectService? service, Duration? cacheTtl})
      : _service = service ?? ProjectService(),
        _cacheTtl = cacheTtl ?? const Duration(minutes: 5);

  final ProjectService _service;
  final Duration _cacheTtl;

  // ---------------------------------------------------------------------------
  // Cache helpers
  // ---------------------------------------------------------------------------

  final Map<String, _CacheEntry<dynamic>> _cache = {};

  String _listKey(int page, int pageSize) => 'list:$page:$pageSize';
  String _detailKey(String id) => 'detail:$id';
  String _analysisKey(String id) => 'analysis:$id';

  T? _hit<T>(String key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      return entry.data as T;
    }
    if (entry != null) _cache.remove(key);
    return null;
  }

  void _put<T>(String key, T data) {
    _cache[key] = _CacheEntry<T>(data, ttl: _cacheTtl);
  }

  void invalidateCache({String? projectId}) {
    if (projectId != null) {
      _cache.remove(_detailKey(projectId));
      _cache.remove(_analysisKey(projectId));
    }
    _cache.removeWhere((key, _) => key.startsWith('list:'));
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Fetches projects, returning a cached list when available.
  Future<ApiResponse<List<Project>>> getProjects({
    int page = 1,
    int pageSize = 20,
    bool forceRefresh = false,
  }) async {
    final key = _listKey(page, pageSize);
    if (!forceRefresh) {
      final cached = _hit<List<Project>>(key);
      if (cached != null) return ApiResponse.success(cached);
    }

    final response = await _service.getProjects(page: page, pageSize: pageSize);
    if (response.isSuccess && response.data != null) {
      _put(key, response.data);
    }
    return response;
  }

  /// Fetches a single project by [id].
  Future<ApiResponse<Project>> getProject(
    String id, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = _hit<Project>(_detailKey(id));
      if (cached != null) return ApiResponse.success(cached);
    }

    final response = await _service.getProject(id);
    if (response.isSuccess && response.data != null) {
      _put(_detailKey(id), response.data);
    }
    return response;
  }

  /// Creates a project and invalidates the list cache.
  Future<ApiResponse<Project>> createProject(Map<String, dynamic> data) async {
    final response = await _service.createProject(data);
    if (response.isSuccess) invalidateCache();
    return response;
  }

  /// Updates a project and invalidates related caches.
  Future<ApiResponse<Project>> updateProject(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _service.updateProject(id, data);
    if (response.isSuccess) invalidateCache(projectId: id);
    return response;
  }

  /// Deletes a project and invalidates related caches.
  Future<ApiResponse<void>> deleteProject(String id) async {
    final response = await _service.deleteProject(id);
    if (response.isSuccess) invalidateCache(projectId: id);
    return response;
  }

  /// Triggers AI analysis. Invalidates analysis cache.
  Future<ApiResponse<Map<String, dynamic>>> analyzeProject(String id) async {
    final response = await _service.analyzeProject(id);
    if (response.isSuccess) _cache.remove(_analysisKey(id));
    return response;
  }

  /// Returns the analysis result, using cache when available.
  Future<ApiResponse<ProjectAnalysis>> getProjectAnalysis(
    String id, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = _hit<ProjectAnalysis>(_analysisKey(id));
      if (cached != null) return ApiResponse.success(cached);
    }

    final response = await _service.getProjectAnalysis(id);
    if (response.isSuccess && response.data != null) {
      _put(_analysisKey(id), response.data);
    }
    return response;
  }

  /// Debug helper.
  void debugPrintCache() {
    debugPrint('[ProjectRepository] Cache entries: ${_cache.length}');
    for (final key in _cache.keys) {
      final entry = _cache[key];
      debugPrint('  $key → expired=${entry?.isExpired}');
    }
  }
}
