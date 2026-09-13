import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_response.dart';
import 'dio_provider.dart';

/// High-level HTTP client that wraps [Dio] and returns [ApiResponse]s.
///
/// All public methods catch errors gracefully and always return an
/// [ApiResponse] — never throw.
class ApiClient {
  ApiClient({Dio? dio}) : _dioOverride = dio;

  final Dio? _dioOverride;
  Dio? _dio;

  Future<Dio> _client() async {
    _dio ??= _dioOverride ?? await DioProvider.getInstance();
    return _dio!;
  }

  // ---------------------------------------------------------------------------
  // Public methods
  // ---------------------------------------------------------------------------

  /// Sends a GET request and deserialises the response.
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? fromJson,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _request(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      fromJson: fromJson,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Sends a POST request.
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? fromJson,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    return _request(
      method: 'POST',
      path: path,
      data: data,
      queryParameters: queryParameters,
      fromJson: fromJson,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    );
  }

  /// Sends a PUT request.
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? fromJson,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _request(
      method: 'PUT',
      path: path,
      data: data,
      queryParameters: queryParameters,
      fromJson: fromJson,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Sends a PATCH request.
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? fromJson,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _request(
      method: 'PATCH',
      path: path,
      data: data,
      queryParameters: queryParameters,
      fromJson: fromJson,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Sends a DELETE request.
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? fromJson,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _request(
      method: 'DELETE',
      path: path,
      data: data,
      queryParameters: queryParameters,
      fromJson: fromJson,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  Future<ApiResponse<T>> _request<T>({
    required String method,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? fromJson,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final dio = await _client();
      final response = await dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method)..merge(options),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );

      final responseData = response.data;

      // If no deserialiser is provided, return raw data.
      if (fromJson == null) {
        return ApiResponse.success(
          responseData as T,
          statusCode: response.statusCode ?? 200,
        );
      }

      return ApiResponse.fromJson(
        responseData as Map<String, dynamic>,
        fromJson,
        defaultStatusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      debugPrint('[ApiClient] $method $path failed: ${e.message}');
      return ApiResponse.error(
        e.message ?? 'An unknown network error occurred.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      debugPrint('[ApiClient] $method $path unexpected error: $e');
      return ApiResponse.error('An unexpected error occurred: $e');
    }
  }
}
