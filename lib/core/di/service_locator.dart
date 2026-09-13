/// A lightweight service locator for dependency injection.
///
/// Usage:
/// ```dart
/// ServiceLocator.register<AuthService>(() => AuthServiceImpl());
/// final auth = ServiceLocator.get<AuthService>();
/// ```
class ServiceLocator {
  ServiceLocator._();

  static final Map<Type, dynamic Function()> _factories = {};
  static final Map<Type, dynamic> _singletons = {};

  /// Registers a factory that creates a new instance of [T] on each [get] call.
  static void register<T>(T Function() factory, {bool singleton = false}) {
    _factories[T] = factory;
    if (singleton) {
      _singletons[T] = factory();
    }
  }

  /// Registers an existing instance of [T] as a singleton.
  static void registerInstance<T>(T instance) {
    _singletons[T] = instance;
  }

  /// Returns the registered instance of [T].
  ///
  /// Throws [ServiceLocatorException] if nothing is registered for [T].
  static T get<T>() {
    // Return cached singleton if available.
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    }
    // Otherwise create via factory and cache.
    final factory = _factories[T];
    if (factory == null) {
      throw ServiceLocatorException(
        'No registration found for ${T.toString()}. '
        'Call ServiceLocator.register<${T.toString()}>() first.',
      );
    }
    final instance = factory() as T;
    // Cache if singleton was requested.
    if (_factories.containsKey(T)) {
      _singletons[T] = instance;
    }
    return instance;
  }

  /// Returns `true` if [T] has been registered.
  static bool isRegistered<T>() {
    return _factories.containsKey(T) || _singletons.containsKey(T);
  }

  /// Clears all registrations. Useful for testing.
  static void reset() {
    _factories.clear();
    _singletons.clear();
  }
}

class ServiceLocatorException implements Exception {
  final String message;
  const ServiceLocatorException(this.message);

  @override
  String toString() => 'ServiceLocatorException: $message';
}
