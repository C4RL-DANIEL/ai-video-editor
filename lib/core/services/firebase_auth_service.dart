import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../network/api_response.dart';

/// Firebase Authentication service wrapping `firebase_auth`.
///
/// Provides email/password and Google sign-in, password reset, profile
/// management, and reactive auth-state observation.
class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
      : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  // ---------------------------------------------------------------------------
  // Auth state
  // ---------------------------------------------------------------------------

  /// Stream that emits whenever the Firebase auth state changes.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// The currently signed-in [User], or `null`.
  User? get currentUser => _auth.currentUser;

  /// Convenience check: `true` when a user is currently authenticated.
  bool get isAuthenticated => _auth.currentUser != null;

  // ---------------------------------------------------------------------------
  // Email / Password
  // ---------------------------------------------------------------------------

  /// Sign in with an [email] and [password].
  ///
  /// Returns an [ApiResponse] wrapping the [UserCredential] on success.
  Future<ApiResponse<UserCredential>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return ApiResponse.success(credential);
    } on FirebaseAuthException catch (e) {
      return ApiResponse.error(_mapAuthError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Register a new account with [email], [password], and optional
  /// [displayName].
  Future<ApiResponse<UserCredential>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name if provided.
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
      }

      return ApiResponse.success(credential);
    } on FirebaseAuthException catch (e) {
      return ApiResponse.error(_mapAuthError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Google Sign-In
  // ---------------------------------------------------------------------------

  /// Sign in using the user's Google account.
  ///
  /// Opens the native Google sign-in flow and exchanges the resulting id-token
  /// for a Firebase credential.
  Future<ApiResponse<UserCredential>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return ApiResponse.error('Google sign-in was cancelled.');
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return ApiResponse.success(userCredential);
    } on FirebaseAuthException catch (e) {
      return ApiResponse.error(_mapAuthError(e));
    } catch (e) {
      return ApiResponse.error('Google sign-in failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Sign Out
  // ---------------------------------------------------------------------------

  /// Sign out from Firebase and Google (if linked).
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (_) {
      // Best-effort: even if Google sign-out fails we still sign out Firebase.
      await _auth.signOut();
    }
  }

  // ---------------------------------------------------------------------------
  // Password Reset
  // ---------------------------------------------------------------------------

  /// Send a password-reset email to [email].
  Future<ApiResponse<void>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return ApiResponse.success(null);
    } on FirebaseAuthException catch (e) {
      return ApiResponse.error(_mapAuthError(e));
    } catch (e) {
      return ApiResponse.error('Failed to send reset email: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Profile
  // ---------------------------------------------------------------------------

  /// Update the current user's profile.
  ///
  /// Pass `null` for fields you do not wish to change.
  Future<ApiResponse<void>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse.error('No authenticated user.');
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      return ApiResponse.success(null);
    } on FirebaseAuthException catch (e) {
      return ApiResponse.error(_mapAuthError(e));
    } catch (e) {
      return ApiResponse.error('Failed to update profile: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Maps common [FirebaseAuthException] codes to human-readable messages.
  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'Authentication error (${e.code}).';
    }
  }
}
