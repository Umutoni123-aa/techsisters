import 'package:techsisters/features/authentication/domain/entities/user_entity.dart';
import 'package:techsisters/features/authentication/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);
  Future<UserEntity> call({required String email, required String password}) async {
    return await repository.loginWithEmailPassword(email: email, password: password);
  }
}

class GoogleSignInUseCase {
  final AuthRepository repository;
  GoogleSignInUseCase(this.repository);
  Future<UserEntity> call() async => await repository.loginWithGoogle();
}

class LogoutUseCase {
  final AuthRepository repository;
  LogoutUseCase(this.repository);
  Future<void> call() async => await repository.logout();
}

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);
  Future<UserEntity> call({required String email, required String password, required String displayName}) async {
    return await repository.registerWithEmailPassword(email: email, password: password, displayName: displayName);
  }
}

class PasswordResetUseCase {
  final AuthRepository repository;
  PasswordResetUseCase(this.repository);
  Future<void> call(String email) async => await repository.sendPasswordResetEmail(email);
}

class EmailVerificationUseCase {
  final AuthRepository repository;
  EmailVerificationUseCase(this.repository);
  Future<void> call() async => await repository.sendEmailVerification();
}

class GetCurrentUserUseCase {
  final AuthRepository repository;
  GetCurrentUserUseCase(this.repository);
  Future<UserEntity?> call() async => await repository.getCurrentUser();
}
