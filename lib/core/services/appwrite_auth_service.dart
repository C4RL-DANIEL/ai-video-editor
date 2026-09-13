import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';

import '../../config/appwrite_config.dart';
import '../../core/network/api_response.dart';

/// Authentication service using Appwrite (free tier).
///
/// Free tier: 75,000 monthly active users, unlimited teams.
class AppwriteAuthService {
  final Account _account;

  AppwriteAuthService(Client client) : _account = Account(client);

  /// Current authenticated user (null if not signed in).
  models.User? get currentUser => _current_user;
  models.User? _current_user;

  /// Whether a user is currently authenticated.
  bool get isAuthenticated => _current_user != null;

  /// Sign up with email and password.
  Future<ApiResponse<models.User>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      _current_user = user;

      // Auto sign-in after registration
      await signIn(email: email, password: password);

      return ApiResponse.success(data: user);
    } on AppwriteException catch (e) {
      debugPrint('Appwrite signUp error: ${e.message}');
      return ApiResponse.error(
        statusCode: e.code ?? 500,
        message: _mapError(e.type ?? 'unknown'),
      );
    }
  }

  /// Sign in with email and password.
  Future<ApiResponse<models.User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      _current_user = await _account.get();
      return ApiResponse.success(data: _current_user!);
    } on AppwriteException catch (e) {
      debugPrint('Appwrite signIn error: ${e.message}');
      return ApiResponse.error(
        statusCode: e.code ?? 500,
        message: _mapError(e.type ?? 'unknown'),
      );
    }
  }

  /// Sign in anonymously (no email required — good for testing/MVP).
  Future<ApiResponse<models.User>> signInAnonymously() async {
    try {
      final user = await _account.createAnonymousSession();
      _current_user = await _account.get();
      return ApiResponse.success(data: _current_user!);
    } on AppwriteException catch (e) {
      debugPrint('Appwrite anonymous sign-in error: ${e.message}');
      return ApiResponse.error(
        statusCode: e.code ?? 500,
        message: _mapError(e.type ?? 'unknown'),
      );
    }
  }

  /// Sign out the current user.
  Future<ApiResponse<void>> signOut() async {
    try {
      await _account.deleteSession(sessionId: 'current');
      _current_user = null;
      return ApiResponse.success(data: null);
    } on AppwriteException catch (e) {
      debugPrint('Appwrite signOut error: ${e.message}');
      return ApiResponse.error(
        statusCode: e.code ?? 500,
        message: _mapError(e.type ?? 'unknown'),
      );
    }
  }

  /// Send a password reset email.
  Future<ApiResponse<void>> resetPassword(String email) async {
    try {
      await _account.createRecovery(
        email: email,
        url: 'https://your-app.com/reset-password',
      );
      return ApiResponse.success(data: null);
    } on AppwriteException catch (e) {
      debugPrint('Appwrite resetPassword error: ${e.message}');
      return ApiResponse.error(
        statusCode: e.code ?? 500,
        message: _mapError(e.type ?? 'unknown'),
      );
    }
  }

  /// Update the current user's profile.
  Future<ApiResponse<models.User>> updateProfile({
    String? name,
    String? photoUrl,
  }) async {
    try {
      if (name != null) {
        _current_user = await _account.updateName(name: name);
      }
      if (photoUrl != null) {
        // Appwrite doesn't support photo URL directly;
        // store it in user prefs instead
        await _account.updatePrefs(prefs: {'photoUrl': photoUrl});
      }
      _current_user = await _account.get();
      return ApiResponse.success(data: _current_user!);
    } on AppwriteException catch (e) {
      debugPrint('Appwrite updateProfile error: ${e.message}');
      return ApiResponse.error(
        statusCode: e.code ?? 500,
        message: _mapError(e.type ?? 'unknown'),
      );
    }
  }

  /// Get the current session to verify auth state.
  Future<bool> checkAuthState() async {
    try {
      _current_user = await _account.get();
      return true;
    } on AppwriteException {
      _current_user = null;
      return false;
    }
  }

  /// Map Appwrite error types to human-readable messages.
  String _mapError(String type) {
    switch (type) {
      case 'user_invalid_credentials':
        return 'Invalid email or password.';
      case 'user_already_exists':
        return 'An account with this email already exists.';
      case 'user_not_found':
        return 'No account found with this email.';
      case 'general_argument_invalid':
        return 'Invalid input. Please check your details.';
      case 'user_email_not_whitelisted':
        return 'This email is not authorized.';
      case 'user_blocked':
        return 'This account has been blocked.';
      case 'password_recently_used':
        return 'This password was recently used. Choose a different one.';
      case 'password_invalid':
        return 'Password does not meet requirements.';
      case 'team_not_found':
        return 'Team not found.';
      case 'session_not_found':
        return 'Session expired. Please sign in again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
