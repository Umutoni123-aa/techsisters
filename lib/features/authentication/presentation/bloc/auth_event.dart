part of 'auth_bloc.dart';

/// Base event for authentication
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to register a new user
class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String displayName;

  const RegisterEvent({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

/// Event to login with email and password
class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Event to login with Google
class GoogleSignInEvent extends AuthEvent {
  const GoogleSignInEvent();
}

/// Event to logout
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

/// Event to send password reset email
class ForgotPasswordEvent extends AuthEvent {
  final String email;

  const ForgotPasswordEvent(this.email);

  @override
  List<Object?> get props => [email];
}

/// Event to send email verification
class SendEmailVerificationEvent extends AuthEvent {
  const SendEmailVerificationEvent();
}

/// Event to check email verification status
class CheckEmailVerificationEvent extends AuthEvent {
  const CheckEmailVerificationEvent();
}

/// Event to get current user
class GetCurrentUserEvent extends AuthEvent {
  const GetCurrentUserEvent();
}
