import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:techsisters/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:techsisters/features/authentication/presentation/pages/login_page.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  group('LoginPage Widget Tests', () {
    late MockAuthBloc mockAuthBloc;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
    });

    testWidgets('should display login form with email and password fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: LoginPage(onRegisterTap: () {}),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsWidgets);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('should show email validation error', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: LoginPage(onRegisterTap: () {}),
          ),
        ),
      );

      // Find password field and enter a password
      final passwordFields = find.byType(TextFormField);
      await tester.enterText(passwordFields.last, 'Password123');

      // Click login button without entering email
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: LoginPage(onRegisterTap: () {}),
          ),
        ),
      );

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: LoginPage(onRegisterTap: () {}),
          ),
        ),
      );

      // Find visibility toggle icon and tap it
      final visibilityIcon = find.byIcon(Icons.visibility_off);
      expect(visibilityIcon, findsOneWidget);

      await tester.tap(visibilityIcon);
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: LoginPage(onRegisterTap: () {}),
          ),
        ),
      );
    });

    testWidgets('should call onRegisterTap when register link is tapped', (
      WidgetTester tester,
    ) async {
      bool registerTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: LoginPage(
              onRegisterTap: () {
                registerTapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Register'));
      expect(registerTapped, true);
    });

    testWidgets('should show loading state during login', (
      WidgetTester tester,
    ) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthLoading());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: LoginPage(onRegisterTap: () {}),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should validate email format', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: LoginPage(onRegisterTap: () {}),
          ),
        ),
      );

      final emailFields = find.byType(TextFormField);
      await tester.enterText(emailFields.first, 'invalidemail');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: LoginPage(onRegisterTap: () {}),
          ),
        ),
      );

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });
  });
}
