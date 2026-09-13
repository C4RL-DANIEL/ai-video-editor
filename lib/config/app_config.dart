import 'package:flutter/foundation.dart';

/// Represents the application runtime environment.
enum AppEnvironment { dev, staging, prod }

/// Central configuration for the application.
///
/// Use [AppConfig.instance] to access the global configuration.
/// In tests, set [forTesting] to `true` and call [AppConfig.reset] to
/// create a fresh instance without affecting production defaults.
class AppConfig {
  AppConfig._({
    required this.baseUrl,
    required this.environment,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.sendTimeout,
    required this.featureFlags,
  });

  /// The API base URL (no trailing slash).
  final String baseUrl;

  /// The current runtime environment.
  final AppEnvironment environment;

  /// Timeout for establishing a connection.
  final Duration connectTimeout;

  /// Timeout for receiving a response.
  final Duration receiveTimeout;

  /// Timeout for sending a request body.
  final Duration sendTimeout;

  /// Feature flags keyed by feature name.
  final Map<String, bool> featureFlags;

  /// When `true`, the app can use test doubles and skip certain validations.
  static bool forTesting = false;

  // ---------------------------------------------------------------------------
  // Singleton access
  // ---------------------------------------------------------------------------

  static AppConfig? _instance;

  /// Returns the global [AppConfig] instance.
  ///
  /// On first access (or after [reset]) it is created with sensible defaults.
  static AppConfig get instance {
    _instance ??= AppConfig._default();
    return _instance!;
  }

  /// Replaces the global instance. Useful in integration / golden tests.
  static void setInstance(AppConfig config) {
    _instance = config;
  }

  /// Resets the singleton so the next [instance] access rebuilds defaults.
  static void reset() {
    _instance = null;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Whether the current environment is production.
  bool get isProduction => environment == AppEnvironment.prod;

  /// Whether the current environment is development.
  bool get isDevelopment => environment == AppEnvironment.dev;

  /// Returns the value of a feature flag, defaulting to `false`.
  bool featureFlag(String key) => featureFlags[key] ?? false;

  // ---------------------------------------------------------------------------
  // Defaults
  // ---------------------------------------------------------------------------

  static AppConfig _default() {
    return AppConfig._(
      baseUrl: 'https://api.aivideoeditor.example.com/v1',
      environment: AppEnvironment.dev,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      featureFlags: {
        'ai_analysis': true,
        'auto_shorts': true,
        'collaboration': false,
        'beta_features': false,
      },
    );
  }
}
