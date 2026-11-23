part of 'auth_bloc.dart';

/// Authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class RegisterEvent extends AuthEvent {
  final String email, password, displayName;
  const RegisterEvent({required this.email, required this.password, required this.displayName});
  @override
  List<Object?> get props => [email, password, displayName];
}

class LoginEvent extends AuthEvent {
  final String email, password;
  const LoginEvent({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class GoogleSignInEvent extends AuthEvent {
  const GoogleSignInEvent();
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class ForgotPasswordEvent extends AuthEvent {
  final String email;
  const ForgotPasswordEvent(this.email);
  @override
  List<Object?> get props => [email];
}

class SendEmailVerificationEvent extends AuthEvent {
  const SendEmailVerificationEvent();
}

class CheckEmailVerificationEvent extends AuthEvent {
  const CheckEmailVerificationEvent();
}

class GetCurrentUserEvent extends AuthEvent {
  const GetCurrentUserEvent();
}
