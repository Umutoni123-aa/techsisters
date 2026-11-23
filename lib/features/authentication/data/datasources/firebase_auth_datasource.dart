import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:techsisters/features/authentication/data/datasources/local_auth_datasource.dart';
import 'package:techsisters/features/authentication/data/models/user_model.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class FirebaseAuthDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final LocalAuthDataSource localDataSource;

  FirebaseAuthDataSource({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.localDataSource,
  });

  Future<UserModel> registerWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.updateDisplayName(displayName);
      await userCredential.user!.reload();

      final user = UserModel(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email ?? '',
        displayName: userCredential.user!.displayName,
        photoUrl: userCredential.user!.photoURL,
        emailVerified: userCredential.user!.emailVerified,
      );

      await localDataSource.saveUserSession(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoUrl,
        emailVerified: user.emailVerified,
      );

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code));
    }
  }

  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email ?? '',
        displayName: userCredential.user!.displayName,
        photoUrl: userCredential.user!.photoURL,
        emailVerified: userCredential.user!.emailVerified,
      );

      await localDataSource.saveUserSession(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoUrl,
        emailVerified: user.emailVerified,
      );

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code));
    }
  }

  Future<UserModel> loginWithGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw AuthException('Google sign in cancelled');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );

      final user = UserModel(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email ?? '',
        displayName: userCredential.user!.displayName,
        photoUrl: userCredential.user!.photoURL,
        emailVerified: userCredential.user!.emailVerified,
      );

      await localDataSource.saveUserSession(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoUrl,
        emailVerified: user.emailVerified,
      );

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code));
    }
  }

  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
      await googleSignIn.signOut();
      await localDataSource.clearUserSession();
    } catch (e) {
      throw AuthException('Logout failed');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code));
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      if (firebaseAuth.currentUser != null) {
        await firebaseAuth.currentUser!.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code));
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        final isLoggedIn = await localDataSource.isUserLoggedIn();
        if (isLoggedIn) {
          return UserModel(
            uid: localDataSource.getCachedUID() ?? '',
            email: localDataSource.getCachedEmail() ?? '',
            displayName: localDataSource.getCachedDisplayName(),
            photoUrl: localDataSource.getCachedPhotoUrl(),
            emailVerified: localDataSource.getCachedEmailVerified(),
          );
        }
        return null;
      }

      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
        emailVerified: user.emailVerified,
      );

      await localDataSource.saveUserSession(
        uid: userModel.uid,
        email: userModel.email,
        displayName: userModel.displayName,
        photoUrl: userModel.photoUrl,
        emailVerified: userModel.emailVerified,
      );

      return userModel;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isEmailVerified() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return false;

      await user.reload();
      return user.emailVerified;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    try {
      if (firebaseAuth.currentUser != null) {
        await firebaseAuth.currentUser!.updateDisplayName(displayName);
        await firebaseAuth.currentUser!.reload();

        await localDataSource.saveUserSession(
          uid: firebaseAuth.currentUser!.uid,
          email: firebaseAuth.currentUser!.email ?? '',
          displayName: displayName,
          photoUrl: firebaseAuth.currentUser!.photoURL,
          emailVerified: firebaseAuth.currentUser!.emailVerified,
        );
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code));
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'User not found. Please check your email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'Email is already in use. Please use a different email.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'operation-not-allowed':
        return 'Operation not allowed.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
