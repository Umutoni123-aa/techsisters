import 'package:techsisters/features/authentication/data/datasources/firebase_auth_datasource.dart';
import 'package:techsisters/features/authentication/domain/entities/user_entity.dart';
import 'package:techsisters/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<UserEntity> registerWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return await dataSource.registerWithEmailPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  @override
  Future<UserEntity> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await dataSource.loginWithEmailPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserEntity> loginWithGoogle() async {
    return await dataSource.loginWithGoogle();
  }

  @override
  Future<void> logout() async {
    return await dataSource.logout();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    return await dataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<void> sendEmailVerification() async {
    return await dataSource.sendEmailVerification();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return await dataSource.getCurrentUser();
  }

  @override
  Future<bool> isEmailVerified() async {
    return await dataSource.isEmailVerified();
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    return await dataSource.updateDisplayName(displayName);
  }
}
