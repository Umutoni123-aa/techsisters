part of 'auth_bloc.dart';

/// Base state for authentication
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated state
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Email verification required state
class EmailVerificationRequired extends AuthState {
  final UserEntity user;

  const EmailVerificationRequired(this.user);

  @override
  List<Object?> get props => [user];
}

/// Email verified state
class EmailVerified extends AuthState {
  const EmailVerified();
}

/// Password reset sent state
class PasswordResetSent extends AuthState {
  final String message;

  const PasswordResetSent(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error state
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
