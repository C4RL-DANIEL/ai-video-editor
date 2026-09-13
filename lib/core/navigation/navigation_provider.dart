import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';

// ── Current route information ───────────────────────────────────────

/// Holds the current GoRouter location/path.
class NavigationState {
  final String location;
  final String name;
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;

  const NavigationState({
    required this.location,
    this.name = '',
    this.pathParameters = const {},
    this.queryParameters = const {},
  });

  NavigationState copyWith({
    String? location,
    String? name,
    Map<String, String>? pathParameters,
    Map<String, String>? queryParameters,
  }) {
    return NavigationState(
      location: location ?? this.location,
      name: name ?? this.name,
      pathParameters: pathParameters ?? this.pathParameters,
      queryParameters: queryParameters ?? this.queryParameters,
    );
  }

  /// Convenience: extract project id from path if present.
  /// Supports both 'id' (current) and 'projectId' (legacy) parameter names.
  String? get projectId => pathParameters['id'] ?? pathParameters['projectId'];

  /// Convenience: is the user on a project sub-page?
  bool get isInProject => projectId != null;

  /// Convenience helpers for which feature section is active.
  bool get isOnProjects => location == '/projects';
  bool get isOnAnalysis => location.contains('/analysis');
  bool get isOnShorts => location.contains('/shorts');
  bool get isOnLongForm => location.contains('/longform');
  bool get isOnEditor => location.contains('/editor');
  bool get isOnSettings => location.contains('/settings');
  bool get isOnUpload => location.contains('/upload');

  @override
  String toString() =>
      'NavigationState(location: $location, name: $name, projectId: $projectId)';
}

// ── Navigation state notifier ───────────────────────────────────────

class NavigationNotifier extends StateNotifier<NavigationState> {
  final GoRouter _router;
  late final GoRouterObserver _observer;

  NavigationNotifier(this._router) : super(const NavigationState(location: '/')) {
    _observer = _AppRouterObserver(_onRouteChanged);
    _router.routerDelegate.addListener(_onRouteChanged);
    // Capture initial route
    _onRouteChanged();
  }

  void _onRouteChanged() {
    final RouteMatch lastMatch =
        _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList =
        _router.routerDelegate.currentConfiguration;
    final location = matchList.uri.toString();

    final routeData = lastMatch.route;
    final name = routeData.name ?? '';

    state = NavigationState(
      location: location,
      name: name,
      pathParameters: Map.from(matchList.pathParameters),
      queryParameters: Map.from(matchList.queryParameters),
    );
  }

  /// Push a named route.
  void navigateTo(String location) {
    _router.go(location);
  }

  /// Push with path parameters substitution.
  void navigateToProject(String projectId) {
    _router.go('/projects/$projectId');
  }

  /// Go back if possible.
  void goBack() {
    if (_router.canPop()) {
      _router.pop();
    } else {
      _router.go(RoutePaths.projects);
    }
  }

  @override
  void dispose() {
    _router.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }
}

// ── Providers ───────────────────────────────────────────────────────

/// Provides the full navigation state, updated on every route change.
final navigationStateProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  final router = ref.watch(appRouterProvider);
  return NavigationNotifier(router);
});

/// Derived provider: current route location string.
final currentRouteProvider = Provider<String>((ref) {
  return ref.watch(navigationStateProvider).location;
});

/// Derived provider: current project ID (nullable).
final currentProjectIdProvider = Provider<String?>((ref) {
  return ref.watch(navigationStateProvider).projectId;
});

/// Derived provider: current route name.
final currentRouteNameProvider = Provider<String>((ref) {
  return ref.watch(navigationStateProvider).name;
});

// ── Observer (internal) ─────────────────────────────────────────────

class _AppRouterObserver extends GoRouterObserver {
  final VoidCallback onChange;

  _AppRouterObserver(this.onChange);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onChange();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onChange();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    onChange();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onChange();
  }
}
