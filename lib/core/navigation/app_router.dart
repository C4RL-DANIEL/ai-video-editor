import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/projects/presentation/project_providers.dart';

// ── Route path constants ─────────────────────────────────────────────
abstract final class RoutePaths {
  RoutePaths._();

  // ── Root ────────────────────────────────────────────────────────
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';

  // ── Dashboard shell ─────────────────────────────────────────────
  static const String dashboard = '/dashboard';

  // ── Projects ────────────────────────────────────────────────────
  static const String projects = '/dashboard/projects';
  static const String createProject = '/dashboard/projects/new';
  static const String projectDetail = '/dashboard/projects/:id';

  // ── Shorts ──────────────────────────────────────────────────────
  static const String shorts = '/dashboard/projects/:id/shorts';
  static const String shortDetail =
      '/dashboard/projects/:id/shorts/:shortId';

  // ── Editor ──────────────────────────────────────────────────────
  static const String editor = '/dashboard/projects/:id/editor';
  static const String shortEditor =
      '/dashboard/projects/:id/editor/:shortId';

  // ── Long-form ───────────────────────────────────────────────────
  static const String longForm = '/dashboard/projects/:id/longform';
  static const String longFormDetail =
      '/dashboard/projects/:id/longform/:longFormId';

  // ── Standalone ──────────────────────────────────────────────────
  static const String upload = '/upload';
  static const String settings = '/settings';

  // ── Builder helpers ─────────────────────────────────────────────

  /// `/dashboard/projects/{id}`
  static String projectById(String id) => '/dashboard/projects/$id';

  /// `/dashboard/projects/{id}/shorts`
  static String shortsForProject(String id) =>
      '/dashboard/projects/$id/shorts';

  /// `/dashboard/projects/{id}/shorts/{shortId}`
  static String shortDetailPath(String id, String shortId) =>
      '/dashboard/projects/$id/shorts/$shortId';

  /// `/dashboard/projects/{id}/editor`
  static String editorForProject(String id) =>
      '/dashboard/projects/$id/editor';

  /// `/dashboard/projects/{id}/editor/{shortId}`
  static String shortEditorPath(String id, String shortId) =>
      '/dashboard/projects/$id/editor/$shortId';

  /// `/dashboard/projects/{id}/longform`
  static String longFormForProject(String id) =>
      '/dashboard/projects/$id/longform';

  /// `/dashboard/projects/{id}/longform/{longFormId}`
  static String longFormDetailPath(String id, String longFormId) =>
      '/dashboard/projects/$id/longform/$longFormId';
}

// ── Named route constants ───────────────────────────────────────────
abstract final class RouteNames {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String dashboard = 'dashboard';
  static const String projects = 'projects';
  static const String createProject = 'createProject';
  static const String projectDetail = 'projectDetail';
  static const String shorts = 'shorts';
  static const String shortDetail = 'shortDetail';
  static const String editor = 'editor';
  static const String shortEditor = 'shortEditor';
  static const String longForm = 'longForm';
  static const String longFormDetail = 'longFormDetail';
  static const String upload = 'upload';
  static const String settings = 'settings';
}

// ── Auth abstraction ────────────────────────────────────────────────
enum AuthStatus { authenticated, unauthenticated, loading }

/// Replace with a Riverpod provider when real auth is wired up.
AuthStatus get currentAuthStatus => AuthStatus.unauthenticated;

// ── Shell navigator keys ────────────────────────────────────────────
final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

// ── Page transitions ────────────────────────────────────────────────

CustomTransitionPage<void> _noTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (_, __, ___, child) => child,
  );
}

CustomTransitionPage<void> _fadeTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      );
    },
  );
}

CustomTransitionPage<void> _slideUpTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));

      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}

// ── Dashboard shell with bottom navigation ──────────────────────────

class DashboardShell extends StatelessWidget {
  const DashboardShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          // Branch 0 = projects, 1 = upload, 2 = settings
          if (index == 1) {
            // Upload is a root-level route, not a shell branch
            context.go(RoutePaths.upload);
          } else if (index == 2) {
            // Settings is a root-level route, not a shell branch
            context.go(RoutePaths.settings);
          } else {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_upload_outlined),
            selectedIcon: Icon(Icons.cloud_upload),
            label: 'Upload',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ── GoRouter provider ───────────────────────────────────────────────

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,

    // ── Redirect logic ────────────────────────────────────────────
    redirect: (BuildContext context, GoRouterState state) {
      final location = state.matchedLocation;
      final authStatus = currentAuthStatus;

      // Still loading – stay on splash.
      if (authStatus == AuthStatus.loading) {
        return location == RoutePaths.splash ? null : RoutePaths.splash;
      }

      // Unauthenticated: only allow auth routes.
      final isAuthRoute =
          location == RoutePaths.splash ||
          location == RoutePaths.login ||
          location == RoutePaths.register;

      if (authStatus == AuthStatus.unauthenticated && !isAuthRoute) {
        return '${RoutePaths.login}?redirect=${Uri.encodeComponent(location)}';
      }

      // Authenticated on splash → go to dashboard.
      if (authStatus == AuthStatus.authenticated &&
          location == RoutePaths.splash) {
        return RoutePaths.dashboard;
      }

      return null;
    },

    // ── Error page ────────────────────────────────────────────────
    errorBuilder: (context, state) => _ErrorPage(
      error: state.error,
      path: state.uri.toString(),
    ),

    // ── Routes ────────────────────────────────────────────────────
    routes: [
      // ── Splash ────────────────────────────────────────────────
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        pageBuilder: (context, state) =>
            _fadeTransition(context, state, const SplashPage()),
      ),

      // ── Login ─────────────────────────────────────────────────
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        pageBuilder: (context, state) =>
            _fadeTransition(context, state, const LoginPage()),
      ),

      // ── Register ──────────────────────────────────────────────
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        pageBuilder: (context, state) =>
            _fadeTransition(context, state, const RegisterPage()),
      ),

      // ── Upload (standalone, opened from bottom nav) ───────────
      GoRoute(
        path: RoutePaths.upload,
        name: RouteNames.upload,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _slideUpTransition(context, state, const UploadPage()),
      ),

      // ── Settings (standalone, opened from bottom nav) ─────────
      GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _slideUpTransition(context, state, const SettingsPage()),
      ),

      // ── Dashboard shell ───────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return DashboardShell(navigationShell: navigationShell);
        },
        branches: [
          // ── Branch 0: Projects ──────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.dashboard,
                name: RouteNames.dashboard,
                redirect: (_, __) => RoutePaths.projects,
              ),
              GoRoute(
                path: RoutePaths.projects,
                name: RouteNames.projects,
                pageBuilder: (context, state) =>
                    _noTransition(context, state, const ProjectsListPage()),
                routes: [
                  // Create new project
                  GoRoute(
                    path: 'new',
                    name: RouteNames.createProject,
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) =>
                        _slideUpTransition(context, state, const CreateProjectPage()),
                  ),

                  // Project detail → nested routes
                  GoRoute(
                    path: ':id',
                    name: RouteNames.projectDetail,
                    builder: (context, state) => ProjectDetailPage(
                      projectId: state.pathParameters['id'],
                    ),
                    routes: [
                      // ── Shorts ────────────────────────────
                      GoRoute(
                        path: 'shorts',
                        name: RouteNames.shorts,
                        builder: (context, state) => ShortsDiscoveryPage(
                          projectId: state.pathParameters['id'],
                        ),
                        routes: [
                          GoRoute(
                            path: ':shortId',
                            name: RouteNames.shortDetail,
                            pageBuilder: (context, state) =>
                                _slideUpTransition(
                              context,
                              state,
                              ShortPreviewPage(
                                projectId: state.pathParameters['id'],
                                shortId: state.pathParameters['shortId'],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ── Editor ────────────────────────────
                      GoRoute(
                        path: 'editor',
                        name: RouteNames.editor,
                        builder: (context, state) => EditorPage(
                          projectId: state.pathParameters['id'],
                        ),
                        routes: [
                          GoRoute(
                            path: ':shortId',
                            name: RouteNames.shortEditor,
                            parentNavigatorKey: _rootNavigatorKey,
                            pageBuilder: (context, state) =>
                                _slideUpTransition(
                              context,
                              state,
                              ShortEditorPage(
                                projectId: state.pathParameters['id'],
                                shortId: state.pathParameters['shortId'],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ── Long-form ──────────────────────────
                      GoRoute(
                        path: 'longform',
                        name: RouteNames.longForm,
                        builder: (context, state) => LongFormBuilderPage(
                          projectId: state.pathParameters['id'],
                        ),
                        routes: [
                          GoRoute(
                            path: ':longFormId',
                            name: RouteNames.longFormDetail,
                            parentNavigatorKey: _rootNavigatorKey,
                            pageBuilder: (context, state) =>
                                _slideUpTransition(
                              context,
                              state,
                              LongFormEditorPage(
                                projectId: state.pathParameters['id'],
                                longFormId: state.pathParameters['longFormId'],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

// ── Helper: convenience navigation methods ──────────────────────────
class AppNavigator {
  AppNavigator._();

  static void goToSplash(BuildContext context) =>
      context.go(RoutePaths.splash);

  static void goToLogin(BuildContext context) =>
      context.go(RoutePaths.login);

  static void goToRegister(BuildContext context) =>
      context.go(RoutePaths.register);

  static void goToDashboard(BuildContext context) =>
      context.go(RoutePaths.dashboard);

  static void goToProjects(BuildContext context) =>
      context.go(RoutePaths.projects);

  static void goToCreateProject(BuildContext context) =>
      context.go(RoutePaths.createProject);

  static void goToProjectDetail(BuildContext context, String id) =>
      context.go(RoutePaths.projectById(id));

  static void goToShorts(BuildContext context, String projectId) =>
      context.go(RoutePaths.shortsForProject(projectId));

  static void goToShortDetail(
          BuildContext context, String projectId, String shortId) =>
      context.go(RoutePaths.shortDetailPath(projectId, shortId));

  static void goToEditor(BuildContext context, String projectId) =>
      context.go(RoutePaths.editorForProject(projectId));

  static void goToShortEditor(
          BuildContext context, String projectId, String shortId) =>
      context.go(RoutePaths.shortEditorPath(projectId, shortId));

  static void goToLongForm(BuildContext context, String projectId) =>
      context.go(RoutePaths.longFormForProject(projectId));

  static void goToLongFormDetail(
          BuildContext context, String projectId, String longFormId) =>
      context.go(RoutePaths.longFormDetailPath(projectId, longFormId));

  static void goToUpload(BuildContext context) =>
      context.go(RoutePaths.upload);

  static void goToSettings(BuildContext context) =>
      context.go(RoutePaths.settings);

  /// Pushes a route on top of the current stack (full-screen modal).
  static void pushShortEditor(
          BuildContext context, String projectId, String shortId) =>
      context.push(RoutePaths.shortEditorPath(projectId, shortId));
}

// ── Placeholder screens (replace with real feature pages) ───────────

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_circle_fill, size: 72),
            SizedBox(height: 16),
            Text('AI Video Editor', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(title: 'Login', icon: Icons.login);
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(title: 'Register', icon: Icons.person_add);
  }
}

class ProjectsListPage extends StatelessWidget {
  const ProjectsListPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(title: 'Projects', icon: Icons.folder_open);
  }
}

class CreateProjectPage extends StatelessWidget {
  const CreateProjectPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(title: 'Create Project', icon: Icons.add_circle_outline);
  }
}

class ProjectDetailPage extends StatelessWidget {
  const ProjectDetailPage({super.key, this.projectId});
  final String? projectId;
  @override
  Widget build(BuildContext context) {
    return _PlaceholderPage(
      title: 'Project ${projectId ?? ""}',
      icon: Icons.movie_creation_outlined,
    );
  }
}

class ShortsDiscoveryPage extends StatelessWidget {
  const ShortsDiscoveryPage({super.key, this.projectId});
  final String? projectId;
  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(title: 'Shorts Discovery', icon: Icons.short_text);
  }
}

class ShortPreviewPage extends StatelessWidget {
  const ShortPreviewPage({super.key, this.projectId, this.shortId});
  final String? projectId;
  final String? shortId;
  @override
  Widget build(BuildContext context) {
    return _PlaceholderPage(
      title: 'Short ${shortId ?? ""}',
      icon: Icons.play_circle_outline,
    );
  }
}

class EditorPage extends StatelessWidget {
  const EditorPage({super.key, this.projectId});
  final String? projectId;
  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(title: 'Video Editor', icon: Icons.edit_video_camera);
  }
}

class ShortEditorPage extends StatelessWidget {
  const ShortEditorPage({super.key, this.projectId, this.shortId});
  final String? projectId;
  final String? shortId;
  @override
  Widget build(BuildContext context) {
    return _PlaceholderPage(
      title: 'Short Editor ${shortId ?? ""}',
      icon: Icons.movie_edit,
    );
  }
}

class LongFormBuilderPage extends StatelessWidget {
  const LongFormBuilderPage({super.key, this.projectId});
  final String? projectId;
  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(title: 'Long-Form Builder', icon: Icons.movie_filter);
  }
}

class LongFormEditorPage extends StatelessWidget {
  const LongFormEditorPage({super.key, this.projectId, this.longFormId});
  final String? projectId;
  final String? longFormId;
  @override
  Widget build(BuildContext context) {
    return _PlaceholderPage(
      title: 'Long-Form Editor ${longFormId ?? ""}',
      icon: Icons.movie_creation,
    );
  }
}

class UploadPage extends StatelessWidget {
  const UploadPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(
      title: 'Upload',
      subtitle: 'File upload & link paste',
      icon: Icons.cloud_upload_outlined,
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(title: 'Settings', icon: Icons.settings);
  }
}

// ── Shared placeholder ──────────────────────────────────────────────

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({
    required this.title,
    required this.icon,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              subtitle ?? 'Screen under construction',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white54,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error page ──────────────────────────────────────────────────────

class _ErrorPage extends StatelessWidget {
  const _ErrorPage({this.error, required this.path});
  final Exception? error;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 72, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                '404 – Page Not Found',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'The route "$path" does not exist.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white38,
                      ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.go(RoutePaths.dashboard),
                icon: const Icon(Icons.home),
                label: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
