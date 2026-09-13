import 'package:flutter/foundation.dart';

/// Application-wide configuration values.
class AppConfig {
  AppConfig._();

  static final AppConfig instance = AppConfig._();

  String get baseUrl => const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:8000',
      );

  Duration get connectTimeout => const Duration(seconds: 15);
  Duration get receiveTimeout => const Duration(seconds: 15);
  Duration get sendTimeout => const Duration(seconds: 15);
}
