/// Shared API response models for the AI Video Editor app.

/// Generic API response wrapper.
class ApiResponse<T> {
  final bool success;
  final T? data;
  final AppError? error;
  final String? message;
  final Pagination? pagination;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
    this.pagination,
  });

  /// Creates a successful response.
  factory ApiResponse.success(T data, {String? message, Pagination? pagination}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      pagination: pagination,
    );
  }

  /// Creates an error response.
  factory ApiResponse.error(AppError error, {String? message}) {
    return ApiResponse<T>(
      success: false,
      error: error,
      message: message ?? error.message,
    );
  }

  /// Creates a response from JSON with a data deserializer.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonData,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      data: json['data'] != null && fromJsonData != null
          ? fromJsonData(json['data'])
          : null,
      error: json['error'] != null
          ? AppError.fromJson(json['error'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson({dynamic Function(T)? toJsonData}) {
    return {
      'success': success,
      'data': data != null && toJsonData != null ? toJsonData(data as T) : data,
      'error': error?.toJson(),
      'message': message,
      'pagination': pagination?.toJson(),
    };
  }

  ApiResponse<T> copyWith({
    bool? success,
    T? data,
    AppError? error,
    String? message,
    Pagination? pagination,
    bool clearError = false,
    bool clearData = false,
    bool clearMessage = false,
    bool clearPagination = false,
  }) {
    return ApiResponse<T>(
      success: success ?? this.success,
      data: clearData ? null : (data ?? this.data),
      error: clearError ? null : (error ?? this.error),
      message: clearMessage ? null : (message ?? this.message),
      pagination: clearPagination ? null : (pagination ?? this.pagination),
    );
  }

  @override
  String toString() =>
      'ApiResponse(success: $success, data: $data, error: $error, message: $message)';
}

/// Pagination metadata for list responses.
class Pagination {
  final int totalCount;
  final int page;
  final int pageSize;
  final bool hasMore;

  const Pagination({
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      totalCount: json['totalCount'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCount': totalCount,
      'page': page,
      'pageSize': pageSize,
      'hasMore': hasMore,
    };
  }

  Pagination copyWith({
    int? totalCount,
    int? page,
    int? pageSize,
    bool? hasMore,
  }) {
    return Pagination(
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  String toString() =>
      'Pagination(totalCount: $totalCount, page: $page, pageSize: $pageSize, hasMore: $hasMore)';
}

/// Paginated response for list endpoints.
class PaginatedResponse<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final bool hasMore;

  const PaginatedResponse({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  /// Creates a paginated response from JSON.
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonItem,
  ) {
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((item) => fromJsonItem(item))
            .toList() ??
        [];
    return PaginatedResponse<T>(
      items: itemsList,
      totalCount: json['totalCount'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson({dynamic Function(T)? toJsonItem}) {
    return {
      'items': items
          .map((item) => toJsonItem != null ? toJsonItem(item) : item)
          .toList(),
      'totalCount': totalCount,
      'page': page,
      'pageSize': pageSize,
      'hasMore': hasMore,
    };
  }

  PaginatedResponse<T> copyWith({
    List<T>? items,
    int? totalCount,
    int? page,
    int? pageSize,
    bool? hasMore,
  }) {
    return PaginatedResponse<T>(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  /// Total number of pages.
  int get totalPages => (totalCount / pageSize).ceil();

  /// Whether this is the first page.
  bool get isFirstPage => page == 1;

  /// Whether this is the last page.
  bool get isLastPage => !hasMore;

  @override
  String toString() =>
      'PaginatedResponse(items: ${items.length}, totalCount: $totalCount, page: $page, hasMore: $hasMore)';
}

/// Application-level error model.
class AppError {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  const AppError({
    required this.code,
    required this.message,
    this.details,
  });

  factory AppError.fromJson(Map<String, dynamic> json) {
    return AppError(
      code: json['code'] as String? ?? 'UNKNOWN',
      message: json['message'] as String? ?? 'An unknown error occurred',
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'details': details,
    };
  }

  AppError copyWith({
    String? code,
    String? message,
    Map<String, dynamic>? details,
    bool clearDetails = false,
  }) {
    return AppError(
      code: code ?? this.code,
      message: message ?? this.message,
      details: clearDetails ? null : (details ?? this.details),
    );
  }

  // Common error factories
  factory AppError.network({String? message}) {
    return AppError(
      code: 'NETWORK_ERROR',
      message: message ?? 'Network connection failed',
    );
  }

  factory AppError.notFound({String? resource}) {
    return AppError(
      code: 'NOT_FOUND',
      message: resource != null ? '$resource not found' : 'Resource not found',
    );
  }

  factory AppError.unauthorized({String? message}) {
    return AppError(
      code: 'UNAUTHORIZED',
      message: message ?? 'Authentication required',
    );
  }

  factory AppError.server({String? message, int? statusCode}) {
    return AppError(
      code: 'SERVER_ERROR',
      message: message ?? 'Internal server error',
      details: statusCode != null ? {'statusCode': statusCode} : null,
    );
  }

  @override
  String toString() => 'AppError(code: $code, message: $message)';
}
