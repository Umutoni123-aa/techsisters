part of 'auth_bloc.dart';

/// Authentication states
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class EmailVerificationRequired extends AuthState {
  final UserEntity user;
  const EmailVerificationRequired(this.user);
  @override
  List<Object?> get props => [user];
}

class EmailVerified extends AuthState {
  const EmailVerified();
}

class PasswordResetSent extends AuthState {
  final String message;
  const PasswordResetSent(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}
