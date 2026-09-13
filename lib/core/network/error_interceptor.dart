import 'package:dio/dio.dart';

/// Interceptor that handles common HTTP errors.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log error for debugging
    print('[ErrorInterceptor] ${err.type}: ${err.message}');
    handler.next(err);
  }
}
