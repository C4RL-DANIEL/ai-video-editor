import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ── Feature screen imports ──────────────────────────────────────────
import '../../features/splash/presentation/splash_page.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/projects/presentation/projects_list_page.dart';
import '../../features/projects/presentation/project_detail_page.dart';
import '../../features/projects/presentation/create_project_page.dart';
import '../../features/shorts/presentation/shorts_discovery_page.dart';
import '../../features/shorts/presentation/short_preview_page.dart';
import '../../features/editor/presentation/editor_page.dart';
import '../../features/editor/presentation/short_editor_page.dart';
import '../../features/longform/presentation/long_form_builder_page.dart';
import '../../features/longform/presentation/long_form_editor_page.dart';
import '../../features/upload/presentation/upload_page.dart';
import '../../features/settings/presentation/settings_page.dart';

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
    debugLogDiagnostics: false,

    // Tell GoRouter to re-evaluate the redirect whenever auth state changes.
    refreshListenable: authRefreshNotifier,

    // ── Redirect logic ────────────────────────────────────────────
    redirect: (BuildContext context, GoRouterState state) {
      final location = state.matchedLocation;

      // Read the auth state from Riverpod.
      // During the first frame, the auth state may still be 'unknown'.
      final authState = ref.read(authStateProvider);

      // Still checking auth – stay on splash.
      if (authState == AuthState.unknown) {
        return location == RoutePaths.splash ? null : RoutePaths.splash;
      }

      // Unauthenticated: only allow auth routes.
      final isAuthRoute =
          location == RoutePaths.splash ||
          location == RoutePaths.login ||
          location == RoutePaths.register;

      if (authState == AuthState.unauthenticated && !isAuthRoute) {
        return RoutePaths.login;
      }

      // Authenticated on splash → go to dashboard.
      if (authState == AuthState.authenticated &&
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
                      projectId: state.pathParameters['id'] ?? '',
                    ),
                    routes: [
                      // ── Shorts ────────────────────────────
                      GoRoute(
                        path: 'shorts',
                        name: RouteNames.shorts,
                        builder: (context, state) => ShortsDiscoveryPage(
                          projectId: state.pathParameters['id'] ?? '',
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
                                projectId: state.pathParameters['id'] ?? '',
                                shortId: state.pathParameters['shortId'] ?? '',
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
                          projectId: state.pathParameters['id'] ?? '',
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
                                projectId: state.pathParameters['id'] ?? '',
                                shortId: state.pathParameters['shortId'] ?? '',
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
                          projectId: state.pathParameters['id'] ?? '',
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
                                projectId: state.pathParameters['id'] ?? '',
                                longFormId: state.pathParameters['longFormId'] ?? '',
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

// ── All screen widgets are now imported from their feature files ────
// See imports at top of file.

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
