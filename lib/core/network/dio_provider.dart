import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';

/// Provides a pre-configured [Dio] instance.
class DioProvider {
  DioProvider._();

  static Dio? _instance;

  /// Returns a shared [Dio] instance with interceptors already attached.
  static Future<Dio> getInstance() async {
    if (_instance != null) return _instance!;

    final config = AppConfig.instance;

    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        sendTimeout: config.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Auth interceptor — attaches Bearer token.
    final prefs = await SharedPreferences.getInstance();
    dio.interceptors.addAll([
      AuthInterceptor(prefs: prefs),
      ErrorInterceptor(),
      // Request/response logging in debug builds.
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) {
          if (kDebugMode) {
            debugPrint('[API LOG] $obj');
          }
        },
      ),
    ]);

    _instance = dio;
    return _instance!;
  }

  /// Replaces the shared instance. Primarily for testing.
  static void setInstance(Dio dio) {
    _instance = dio;
  }

  /// Clears the cached instance so the next call to [getInstance] builds fresh.
  static void reset() {
    _instance = null;
  }
}
