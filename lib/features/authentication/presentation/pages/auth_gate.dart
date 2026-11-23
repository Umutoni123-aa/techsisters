import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techsisters/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:techsisters/features/authentication/presentation/pages/login_page.dart';
import 'package:techsisters/features/authentication/presentation/pages/register_page.dart';

class AuthGate extends StatefulWidget {
  final Widget homeScreen;

  const AuthGate({
    Key? key,
    required this.homeScreen,
  }) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoginPage = true;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const GetCurrentUserEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AuthAuthenticated) {
          return widget.homeScreen;
        }

        if (state is EmailVerificationRequired) {
          return Scaffold(
            appBar: AppBar(title: const Text('Email Verification')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('A verification email has been sent.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                        const CheckEmailVerificationEvent(),
                      );
                    },
                    child: const Text('I verified my email'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                        const SendEmailVerificationEvent(),
                      );
                    },
                    child: const Text('Resend verification email'),
                  ),
                ],
              ),
            ),
          );
        }

        return _isLoginPage
            ? LoginPage(
          onRegisterTap: () {
            setState(() {
              _isLoginPage = false;
            });
          },
        )
            : RegisterPage(
          onLoginTap: () {
            setState(() {
              _isLoginPage = true;
            });
          },
        );
      },
    );
  }
}
