import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techsisters/features/authentication/domain/entities/user_entity.dart';
import 'package:techsisters/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:techsisters/features/authentication/presentation/pages/login_page.dart';
import 'package:techsisters/features/authentication/presentation/pages/register_page.dart';
import 'package:techsisters/app/signed_in_scope.dart';

/// Remembers whether the signed-out user is looking at Register or Login.
class AuthScreenCubit extends Cubit<bool> {
  AuthScreenCubit() : super(false);

  void showRegister() => emit(true);
  void showLogin() => emit(false);
}

/// Chooses the screen from the auth state: login/register when signed out,
/// the verify-email step after registering, and the app once signed in.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      // After email verification, reload the user so we move into the app.
      listener: (context, state) {
        if (state is EmailVerified) {
          context.read<AuthBloc>().add(const GetCurrentUserEvent());
        }
      },
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final user = state.user;
          return SignedInScope(
            // Keyed by uid so a different user gets fresh lessons data.
            key: ValueKey(user.uid),
            user: user,
            onLogout: () => context.read<AuthBloc>().add(const LogoutEvent()),
          );
        }
        if (state is EmailVerificationRequired) {
          return _VerifyEmailPage(user: state.user);
        }
        if (state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Signed out (also covers loading and error, so the form is kept).
        final showRegister = context.watch<AuthScreenCubit>().state;
        final screens = context.read<AuthScreenCubit>();
        return PopScope(
          // Back on Register returns to Login instead of leaving the app.
          canPop: !showRegister,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) screens.showLogin();
          },
          child: showRegister
              ? RegisterPage(onLoginTap: screens.showLogin)
              : LoginPage(onRegisterTap: screens.showRegister),
        );
      },
    );
  }
}

class _VerifyEmailPage extends StatelessWidget {
  final UserEntity user;
  const _VerifyEmailPage({required this.user});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AuthBloc>();
    return Scaffold(
      appBar: AppBar(title: const Text('Verify your email')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'We sent a verification link to ${user.email}. '
              'Open it, then tap the button below.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => bloc.add(const CheckEmailVerificationEvent()),
              child: const Text("I've verified my email"),
            ),
            TextButton(
              onPressed: () => bloc.add(const SendEmailVerificationEvent()),
              child: const Text('Resend email'),
            ),
            TextButton(
              onPressed: () => bloc.add(const LogoutEvent()),
              child: const Text('Back to login'),
            ),
          ],
        ),
      ),
    );
  }
}
