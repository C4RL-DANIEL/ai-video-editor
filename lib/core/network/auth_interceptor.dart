import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Interceptor that attaches the stored session token to every request.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.prefs});

  final SharedPreferences prefs;

  static const _tokenKey = 'appwrite_session';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = prefs.getString(_tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['X-Appwrite-Session'] = token;
    }
    handler.next(options);
  }
}
