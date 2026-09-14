import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/appwrite_config.dart';
import '../../../core/services/appwrite_auth_service.dart';

/// Provides the Appwrite auth service singleton.
final authServiceProvider = Provider<AppwriteAuthService>((ref) {
  return AppwriteAuthService(createAppwriteClient());
});

/// Tracks the current authentication state.
/// Starts as `unknown` and resolves to `authenticated` or `unauthenticated`
/// after checking the Appwrite session.
enum AuthState { unknown, authenticated, unauthenticated }

/// Global notifier that GoRouter listens to for redirect re-evaluation.
/// When the auth state changes, this fires and GoRouter re-runs its redirect.
final authRefreshNotifier = ValueNotifier<AuthState>(AuthState.unknown);

/// Notifier that manages auth state and exposes login/logout methods.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService) : super(AuthState.unknown) {
    _checkInitialAuth();
  }

  final AppwriteAuthService _authService;

  AppwriteAuthService get authService => _authService;

  /// Updates both the Riverpod state and the GoRouter refresh notifier.
  void _setAuthState(AuthState newState) {
    state = newState;
    authRefreshNotifier.value = newState;
  }

  Future<void> _checkInitialAuth() async {
    final isAuth = await _authService.checkAuthState();
    _setAuthState(isAuth ? AuthState.authenticated : AuthState.unauthenticated);
  }

  Future<String?> signIn({required String email, required String password}) async {
    final result = await _authService.signIn(email: email, password: password);
    if (result.isSuccess) {
      _setAuthState(AuthState.authenticated);
      return null; // no error
    }
    return result.message ?? 'Sign in failed. Please try again.';
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final result = await _authService.signUp(
      email: email,
      password: password,
      name: name,
    );
    if (result.isSuccess) {
      _setAuthState(AuthState.authenticated);
      return null; // no error
    }
    return result.message ?? 'Registration failed. Please try again.';
  }

  Future<String?> signInWithGoogle() async {
    final result = await _authService.signInWithGoogle();
    if (result.isSuccess) {
      _setAuthState(AuthState.authenticated);
      return null;
    }
    return result.message ?? 'Google sign-in failed.';
  }

  Future<String?> signInWithApple() async {
    final result = await _authService.signInWithApple();
    if (result.isSuccess) {
      _setAuthState(AuthState.authenticated);
      return null;
    }
    return result.message ?? 'Apple sign-in failed.';
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _setAuthState(AuthState.unauthenticated);
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
