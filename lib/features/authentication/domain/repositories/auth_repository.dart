import 'package:techsisters/features/authentication/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> registerWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
  });

  Future<UserEntity> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<UserEntity> loginWithGoogle();

  Future<void> logout();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> sendEmailVerification();

  Future<UserEntity?> getCurrentUser();

  Future<bool> isEmailVerified();

  Future<void> updateDisplayName(String displayName);
}
