import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartexpencemanager/services/firestore_database.dart';

class FirebaseAuthService {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _userPhotoUrlKey = 'user_photo_url';

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Email & Password Sign In
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email.trim(), password: password);

      // Save user data to SharedPreferences

      await _saveUserDataToPrefs(userCredential.user);

      return userCredential;
    } catch (e) {
      throw Exception('Email sign-in failed: ${_getAuthErrorMessage(e)}');
    }
  }

  // Email & Password Sign Up
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      // Update display name
      await userCredential.user?.updateDisplayName(name.trim());
      await userCredential.user?.reload();

      // Save user data to SharedPreferences
      await _saveUserDataToPrefs(_firebaseAuth.currentUser);

      return userCredential;
    } catch (e) {
      throw Exception('Email sign-up failed: ${_getAuthErrorMessage(e)}');
    }
  }

  // Password Reset
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      throw Exception('Password reset failed: ${_getAuthErrorMessage(e)}');
    }
  }

  // Helper method to get user-friendly error messages
  String _getAuthErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email address.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'email-already-in-use':
          return 'An account already exists with this email address.';
        case 'weak-password':
          return 'Password is too weak. Please choose a stronger password.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'too-many-requests':
          return 'Too many failed attempts. Please try again later.';
        default:
          return error.message ?? 'An error occurred.';
      }
    }
    return error.toString();
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      FirebaseFirestoreDb().adduser(userCredential.user!);
      // Save user data to SharedPreferences
      await _saveUserDataToPrefs(userCredential.user);

      return userCredential;
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);

      // Clear stored auth data
      await _clearUserDataFromPrefs();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserDataToPrefs(User? user) async {
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userEmailKey, user.email ?? '');
      await prefs.setString(_userNameKey, user.displayName ?? '');
      await prefs.setString(_userPhotoUrlKey, user.photoURL ?? '');
    }
  }

  // Clear user data from SharedPreferences
  Future<void> _clearUserDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userPhotoUrlKey);
  }

  // Check if user is logged in from SharedPreferences
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Get user data from SharedPreferences
  Future<Map<String, String?>> getUserDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString(_userEmailKey),
      'name': prefs.getString(_userNameKey),
      'photoUrl': prefs.getString(_userPhotoUrlKey),
    };
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.delete();
        await _googleSignIn.signOut();
        await _clearUserDataFromPrefs();
      }
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // Reauthenticate user (required for sensitive operations)
  Future<void> reauthenticateWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Reauthentication canceled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.reauthenticateWithCredential(credential);
      }
    } catch (e) {
      throw Exception('Reauthentication failed: $e');
    }
  }
}
