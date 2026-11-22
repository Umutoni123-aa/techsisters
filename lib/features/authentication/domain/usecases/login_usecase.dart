import 'package:techsisters/features/authentication/domain/entities/user_entity.dart';
import 'package:techsisters/features/authentication/domain/repositories/auth_repository.dart';

/// Use case for email/password login
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity> call({
    required String email,
    required String password,
  }) async {
    return await repository.loginWithEmailPassword(
      email: email,
      password: password,
    );
  }
}

/// Use case for Google Sign-In
class GoogleSignInUseCase {
  final AuthRepository repository;

  GoogleSignInUseCase(this.repository);

  Future<UserEntity> call() async {
    return await repository.loginWithGoogle();
  }
}

/// Use case for logout
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call() async {
    return await repository.logout();
  }
}

/// Use case for registration
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserEntity> call({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return await repository.registerWithEmailPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}

/// Use case for password reset
class PasswordResetUseCase {
  final AuthRepository repository;

  PasswordResetUseCase(this.repository);

  Future<void> call(String email) async {
    return await repository.sendPasswordResetEmail(email);
  }
}

/// Use case for email verification
class EmailVerificationUseCase {
  final AuthRepository repository;

  EmailVerificationUseCase(this.repository);

  Future<void> call() async {
    return await repository.sendEmailVerification();
  }
}

/// Use case for getting current user
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<UserEntity?> call() async {
    return await repository.getCurrentUser();
  }
}
