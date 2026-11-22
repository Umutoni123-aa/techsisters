import 'package:techsisters/features/authentication/domain/entities/user_entity.dart';

/// Abstract repository for authentication operations
abstract class AuthRepository {
  /// Register a new user with email and password
  Future<UserEntity> registerWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
  });

  /// Login user with email and password
  Future<UserEntity> loginWithEmailPassword({
    required String email,
    required String password,
  });

  /// Login user with Google Sign-In
  Future<UserEntity> loginWithGoogle();

  /// Logout the current user
  Future<void> logout();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Send email verification
  Future<void> sendEmailVerification();

  /// Get current user
  Future<UserEntity?> getCurrentUser();

  /// Check if user email is verified
  Future<bool> isEmailVerified();

  /// Update user display name
  Future<void> updateDisplayName(String displayName);
}
