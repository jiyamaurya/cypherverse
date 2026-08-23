import 'package:firebase_auth/firebase_auth.dart';

/// Simple AuthService that ensures an anonymous Firebase user exists and
/// provides access to the current user's UID.
class AuthService {
  AuthService._(); // private constructor to prevent instantiation

  /// Ensure a user is signed in and return the current User.
  /// Signs in anonymously if no current user exists.
  static Future<User> ensureSignedIn() async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      if (user == null) {
        final credential = await auth.signInAnonymously();
        user = credential.user;
      }
      if (user == null) {
        throw FirebaseAuthException(
            code: 'no-user', message: 'Failed to obtain anonymous user');
      }
      return user;
    } on FirebaseAuthException {
      rethrow; // let caller decide how to handle FirebaseAuthException
    } catch (e) {
      // Wrap other errors
      throw FirebaseAuthException(
          code: 'auth-error', message: 'Auth failed: $e');
    }
  }

  /// Returns the current user's UID if available, otherwise throws.
  static String get uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('No current Firebase user. Call ensureSignedIn() first.');
    }
    return user.uid;
  }

  /// Convenience: ensure signed in and return the uid.
  static Future<String> getCurrentUserId() async {
    final user = await ensureSignedIn();
    return user.uid;
  }
}
