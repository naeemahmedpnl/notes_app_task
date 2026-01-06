import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../services/firebase_service.dart';

class AuthRepository {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  Stream<User?> get userChanges => _auth.userChanges();

  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (email.trim().isEmpty) {
        throw Exception('Email cannot be empty');
      }

      if (password.isEmpty) {
        throw Exception('Password cannot be empty');
      }
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Failed to sign in user');
      }

      final user = credential.user!;
      await _firebaseService.createUserDocument(
        userId: user.uid,
        email: user.email!,
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );

      // Convert to UserModel
      final userModel = UserModel.fromFirebaseUser(user);

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      if (email.trim().isEmpty) {
        throw Exception('Email cannot be empty');
      }

      if (password.isEmpty) {
        throw Exception('Password cannot be empty');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters long');
      }
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Failed to create user account');
      }

      final user = credential.user!;
      if (displayName != null && displayName.trim().isNotEmpty) {
        await user.updateDisplayName(displayName.trim());
        await user.reload();
      }
      await _firebaseService.createUserDocument(
        userId: user.uid,
        email: user.email!,
        displayName: displayName?.trim() ?? user.email!.split('@')[0],
        photoUrl: user.photoURL,
      );

      // Convert to UserModel
      final userModel = UserModel.fromFirebaseUser(user);

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // Validate email
      if (email.trim().isEmpty) {
        throw Exception('Email cannot be empty');
      }

      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }
      if (displayName.trim().isEmpty) {
        throw Exception('Display name cannot be empty');
      }

      final trimmedName = displayName.trim();
      await user.updateDisplayName(trimmedName);
      await user.reload();
      await _firebaseService.updateUserProfile(
        userId: user.uid,
        displayName: trimmedName,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }
      if (newEmail.trim().isEmpty) {
        throw Exception('Email cannot be empty');
      }

      final trimmedEmail = newEmail.trim().toLowerCase();
      await user.updateEmail(trimmedEmail);
      await user.reload();
      await _firebaseService.updateUserProfile(
        userId: user.uid,
        additionalData: {'email': trimmedEmail},
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }
      if (newPassword.isEmpty) {
        throw Exception('Password cannot be empty');
      }

      if (newPassword.length < 6) {
        throw Exception('Password must be at least 6 characters long');
      }
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reauthenticateWithPassword(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      if (user.email == null) {
        throw Exception('User email not available');
      }
      if (password.isEmpty) {
        throw Exception('Password cannot be empty');
      }
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      if (user.emailVerified) {
        throw Exception('Email is already verified');
      }

      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reloadUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      await user.reload();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      final userId = user.uid;
      await _firebaseService.cleanupUserData(userId);
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> getCurrentUserModel() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return null;
      }
      await user.reload();

      return UserModel.fromFirebaseUser(user);
    } catch (e) {
      return null;
    }
  }

  //Check if user is signed in
  bool isSignedIn() {
    return _auth.currentUser != null;
  }

  //Check if current user's email is verified
  bool isEmailVerified() {
    final user = _auth.currentUser;
    return user?.emailVerified ?? false;
  }

  //Get user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final userDoc = await _firebaseService.getUserDocument(userId);

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  //Update user profile in Firestore
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      await _firebaseService.updateUserProfile(
        userId: user.uid,
        displayName: displayName,
        photoUrl: photoUrl,
        additionalData: additionalData,
      );
    } catch (e) {
      rethrow;
    }
  }

  //Check if email exists in Firebase Auth
  Future<bool> doesEmailExist(String email) async {
    try {
      final methods =
          await _auth.fetchSignInMethodsForEmail(email.trim().toLowerCase());
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  //Get user creation timestamp
  DateTime? getUserCreationTime() {
    final user = _auth.currentUser;
    return user?.metadata.creationTime;
  }

  //Get user last sign in timestamp
  DateTime? getUserLastSignInTime() {
    final user = _auth.currentUser;
    return user?.metadata.lastSignInTime;
  }

  //Handle FirebaseAuth exceptions and convert to user-friendly messages
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No account found with this email address');
      case 'wrong-password':
        return Exception('Incorrect password');
      case 'email-already-in-use':
        return Exception('An account already exists with this email address');
      case 'weak-password':
        return Exception(
            'Password is too weak. Please choose a stronger password');
      case 'invalid-email':
        return Exception('Please enter a valid email address');
      case 'user-disabled':
        return Exception('This account has been disabled');
      case 'too-many-requests':
        return Exception('Too many attempts. Please try again later');
      case 'requires-recent-login':
        return Exception('Please sign in again to continue');
      case 'invalid-credential':
        return Exception(
            'Invalid credentials. Please check your email and password');
      case 'network-request-failed':
        return Exception(
            'Network error. Please check your connection and try again');
      case 'operation-not-allowed':
        return Exception('This operation is not allowed');
      default:
        return Exception(e.message ?? 'An authentication error occurred');
    }
  }

  //Link anonymous account with email/password
  Future<UserModel> linkWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      if (!user.isAnonymous) {
        throw Exception('User is not anonymous');
      }

      // Validate input
      if (email.trim().isEmpty) {
        throw Exception('Email cannot be empty');
      }

      if (password.isEmpty) {
        throw Exception('Password cannot be empty');
      }

      // Create credential
      final credential = EmailAuthProvider.credential(
        email: email.trim().toLowerCase(),
        password: password,
      );

      // Link account
      final userCredential = await user.linkWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Failed to link account');
      }

      final linkedUser = userCredential.user!;

      // Update display name if provided
      if (displayName != null && displayName.trim().isNotEmpty) {
        await linkedUser.updateDisplayName(displayName.trim());
        await linkedUser.reload();
      }

      // Create/update user document in Firestore
      await _firebaseService.createUserDocument(
        userId: linkedUser.uid,
        email: linkedUser.email!,
        displayName: displayName?.trim() ?? linkedUser.email!.split('@')[0],
        photoUrl: linkedUser.photoURL,
      );

      return UserModel.fromFirebaseUser(linkedUser);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  //Sign in anonymously
  Future<UserModel> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();

      if (credential.user == null) {
        throw Exception('Failed to sign in anonymously');
      }

      final user = credential.user!;

      return UserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      rethrow;
    }
  }
}
