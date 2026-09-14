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

/// Notifier that manages auth state and exposes login/logout methods.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService) : super(AuthState.unknown) {
    _checkInitialAuth();
  }

  final AppwriteAuthService _authService;

  AppwriteAuthService get authService => _authService;

  Future<void> _checkInitialAuth() async {
    final isAuth = await _authService.checkAuthState();
    state = isAuth ? AuthState.authenticated : AuthState.unauthenticated;
  }

  Future<bool> signIn({required String email, required String password}) async {
    final result = await _authService.signIn(email: email, password: password);
    if (result.isSuccess) {
      state = AuthState.authenticated;
      return true;
    }
    return false;
  }

  Future<bool> signUp({
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
      state = AuthState.authenticated;
      return true;
    }
    return false;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = AuthState.unauthenticated;
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
