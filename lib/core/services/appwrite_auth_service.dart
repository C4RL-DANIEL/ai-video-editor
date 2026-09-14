import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart' show OAuthProvider;
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

  /// Safely fetch the current user after any auth operation.
  /// Returns the User on success, or null on failure.
  /// This method is intentionally bulletproof — it should NEVER throw.
  Future<models.User?> _fetchCurrentUser() async {
    try {
      final dynamic response = await _account.get();
      if (response == null) {
        debugPrint('_fetchCurrentUser: response is null');
        return null;
      }
      if (response is models.User) {
        return response;
      }
      // Not a User object — this shouldn't happen but handle gracefully
      debugPrint('_fetchCurrentUser: unexpected type ${response.runtimeType}, value: $response');
      return null;
    } on AppwriteException catch (e) {
      debugPrint('_fetchCurrentUser AppwriteException: ${e.message} (code: ${e.code})');
      return null;
    } catch (e) {
      debugPrint('_fetchCurrentUser error: ${e.runtimeType}: $e');
      return null;
    }
  }

  /// Sign up with email and password.
  Future<ApiResponse<models.User>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      // Auto sign-in after registration — but don't fail if we can't get user details
      try {
        await signIn(email: email, password: password);
      } catch (_) {
        // Sign-in attempt failed, but account was created. Return success anyway.
      }

      // Try to get user details, but don't fail if we can't
      final user = await _fetchCurrentUser();
      if (user != null) {
        _current_user = user;
        return ApiResponse.success(user);
      }

      // Account was created and session should exist — return success
      return ApiResponse.success(null);
    } on AppwriteException catch (e) {
      debugPrint('Appwrite signUp error: ${e.message} (type: ${e.type}, code: ${e.code})');
      return ApiResponse.error(
        _mapError(e.type ?? 'unknown'),
        statusCode: e.code ?? 500,
      );
    } catch (e, stackTrace) {
      debugPrint('Unexpected signUp error: ${e.runtimeType}: $e');
      debugPrint('Stack trace: $stackTrace');
      return ApiResponse.error('Sign up failed. Please try again.');
    }
  }

  /// Sign in with email and password.
  Future<ApiResponse<models.User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      // Try to get user details, but don't fail if we can't
      final user = await _fetchCurrentUser();
      if (user != null) {
        _current_user = user;
        return ApiResponse.success(user);
      }

      // Session was created — sign-in succeeded even if we can't get user details.
      return ApiResponse.success(null);
    } on AppwriteException catch (e) {
      debugPrint('Appwrite signIn error: ${e.message} (type: ${e.type}, code: ${e.code})');
      return ApiResponse.error(
        _mapError(e.type ?? 'unknown'),
        statusCode: e.code ?? 500,
      );
    } catch (e, stackTrace) {
      debugPrint('Unexpected signIn error: ${e.runtimeType}: $e');
      debugPrint('Stack trace: $stackTrace');
      return ApiResponse.error('Sign in failed. Please try again.');
    }
  }

  /// Sign in with Google via Appwrite OAuth.
  Future<ApiResponse<models.User>> signInWithGoogle() async {
    try {
      // Create OAuth2 session - this opens the browser for Google auth
      // After auth, Google redirects to Appwrite, which redirects back to the app
      // using the appwrite-callback-{projectId}:// scheme
      await _account.createOAuth2Session(
        provider: OAuthProvider.google,
      );

      // After browser closes and app receives callback, check auth state
      // Give the session a moment to be established
      await Future.delayed(const Duration(milliseconds: 500));

      final user = await _fetchCurrentUser();
      if (user != null) {
        _current_user = user;
        return ApiResponse.success(user);
      }

      // Even if we can't get user details, the session might exist
      // Try checking if there's a session
      try {
        final sessions = await _account.listSessions();
        if (sessions.sessions.isNotEmpty) {
          return ApiResponse.success(null);
        }
      } catch (_) {}

      return ApiResponse.error('Google sign-in completed but could not verify session.');
    } on AppwriteException catch (e) {
      debugPrint('Appwrite Google sign-in error: ${e.message} (type: ${e.type}, code: ${e.code})');
      return ApiResponse.error(
        _mapError(e.type ?? 'unknown'),
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      debugPrint('Unexpected Google sign-in error: ${e.runtimeType}: $e');
      return ApiResponse.error('Google sign-in failed. Please try again.');
    }
  }

  /// Sign in with Apple via Appwrite OAuth.
  Future<ApiResponse<models.User>> signInWithApple() async {
    try {
      await _account.createOAuth2Session(
        provider: OAuthProvider.apple,
      );
      final user = await _fetchCurrentUser();
      if (user != null) {
        _current_user = user;
        return ApiResponse.success(user);
      }
      return ApiResponse.error('Apple sign-in completed but could not fetch user info.');
    } on AppwriteException catch (e) {
      debugPrint('Appwrite Apple sign-in error: ${e.message}');
      return ApiResponse.error(
        _mapError(e.type ?? 'unknown'),
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      debugPrint('Unexpected Apple sign-in error: $e');
      return ApiResponse.error('Apple sign-in failed: ${e.toString()}');
    }
  }

  /// Sign out the current user.
  Future<ApiResponse<void>> signOut() async {
    try {
      await _account.deleteSession(sessionId: 'current');
      _current_user = null;
      return ApiResponse.success(null);
    } on AppwriteException catch (e) {
      debugPrint('Appwrite signOut error: ${e.message}');
      return ApiResponse.error(
        _mapError(e.type ?? 'unknown'),
        statusCode: e.code ?? 500,
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
      return ApiResponse.success(null);
    } on AppwriteException catch (e) {
      debugPrint('Appwrite resetPassword error: ${e.message}');
      return ApiResponse.error(
        _mapError(e.type ?? 'unknown'),
        statusCode: e.code ?? 500,
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
        await _account.updateName(name: name);
      }
      if (photoUrl != null) {
        await _account.updatePrefs(prefs: {'photoUrl': photoUrl});
      }
      final user = await _fetchCurrentUser();
      if (user != null) {
        _current_user = user;
        return ApiResponse.success(user);
      }
      return ApiResponse.error('Profile updated but could not fetch user info.');
    } on AppwriteException catch (e) {
      debugPrint('Appwrite updateProfile error: ${e.message}');
      return ApiResponse.error(
        _mapError(e.type ?? 'unknown'),
        statusCode: e.code ?? 500,
      );
    }
  }

  /// Get the current session to verify auth state.
  Future<bool> checkAuthState() async {
    try {
      final user = await _fetchCurrentUser();
      _current_user = user;
      return user != null;
    } catch (e) {
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
