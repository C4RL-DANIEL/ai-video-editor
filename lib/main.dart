import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Initialize platform services, SharedPreferences, Firebase, etc.
  // await Firebase.initializeApp();
  // await SharedPreferences.getInstance();

  runApp(const ProviderScope(child: AiVideoEditorApp()));
}

/// Root widget of the AI Video Editor app.
class AiVideoEditorApp extends ConsumerWidget {
  const AiVideoEditorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'AI Video Editor',
      debugShowCheckedModeBanner: false,

      // Dark theme only – light theme could be added later.
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,

      // GoRouter integration
      routerConfig: router,

      // Global builder for overlays, locale, etc.
      builder: (context, child) {
        // Wraps every screen – useful for global providers, overlays, or
        // a custom scroll behavior.
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
