import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dio interceptor that attaches the stored Bearer token to every request.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({SharedPreferences? prefs}) : _prefs = prefs;

  final SharedPreferences? _prefs;

  /// SharedPreferences key where the auth token is stored.
  static const String tokenKey = 'auth_token';

  /// Returns the stored token, or `null` if the user is not authenticated.
  String? get token => _prefs?.getString(tokenKey);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final tokenValue = token;
    if (tokenValue != null && tokenValue.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $tokenValue';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // If we get a 401 the token is probably stale — clear it so the UI can
    // react and force a re-login.
    if (err.response?.statusCode == 401) {
      _prefs?.remove(tokenKey);
    }
    handler.next(err);
  }
}
