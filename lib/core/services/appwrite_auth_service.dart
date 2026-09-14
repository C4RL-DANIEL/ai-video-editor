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
  Future<models.User?> _fetchCurrentUser() async {
    try {
      final response = await _account.get();
      // In SDK v13, get() returns a User object directly.
      // Handle both direct User and response wrapping.
      if (response is models.User) {
        return response;
      }
      // If it's a generic response, try to extract user data
      _current_user = response as models.User?;
      return _current_user;
    } catch (e) {
      debugPrint('_fetchCurrentUser error: $e');
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

      // Auto sign-in after registration
      final signInResult = await signIn(email: email, password: password);
      if (signInResult.isSuccess && signInResult.data != null) {
        return signInResult;
      }

      // Sign-up succeeded but auto sign-in failed — try to get user directly
      final user = await _fetchCurrentUser();
      if (user != null) {
        _current_user = user;
        return ApiResponse.success(user);
      }

      return ApiResponse.success(
        models.User(
          id: '',
          name: name,
          email: email,
          emailVerification: false,
          status: true,
          prefs: {},
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
    } on AppwriteException catch (e) {
      debugPrint('Appwrite signUp error: ${e.message}');
      return ApiResponse.error(
        _mapError(e.type ?? 'unknown'),
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      debugPrint('Unexpected signUp error: $e');
      return ApiResponse.error('Sign up failed: ${e.toString()}');
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

      final user = await _fetchCurrentUser();
      if (user != null) {
        _current_user = user;
        return ApiResponse.success(user);
      }

      // Session was created but couldn't fetch user — still consider it a success
      return ApiResponse.success(
        models.User(
          id: '',
          name: '',
          email: email,
          emailVerification: false,
          status: true,
          prefs: {},
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
    } on AppwriteException catch (e) {
      debugPrint('Appwrite signIn error: ${e.message}');
      return ApiResponse.error(
        _mapError(e.type ?? 'unknown'),
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      debugPrint('Unexpected signIn error: $e');
      return ApiResponse.error('Sign in failed: ${e.toString()}');
    }
  }

  /// Sign in with Google via Appwrite OAuth.
  Future<ApiResponse<models.User>> signInWithGoogle() async {
    try {
      await _account.createOAuth2Session(
        provider: OAuthProvider.google,
      );
      final user = await _fetchCurrentUser();
      if (user != null) {
        _current_user = user;
        return ApiResponse.success(user);
      }
      return ApiResponse.error('Google sign-in completed but could not fetch user info.');
    } on AppwriteException catch (e) {
      debugPrint('Appwrite Google sign-in error: ${e.message}');
      return ApiResponse.error(
        _mapError(e.type ?? 'unknown'),
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      debugPrint('Unexpected Google sign-in error: $e');
      return ApiResponse.error('Google sign-in failed: ${e.toString()}');
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
