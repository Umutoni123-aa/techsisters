import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app/auth_gate.dart';
import 'core/theme/app_theme.dart';
import 'features/authentication/data/datasources/firebase_auth_datasource.dart';
import 'features/authentication/data/repositories/auth_repository_impl.dart';
import 'features/authentication/domain/usecases/login_usecase.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/notes/data/datasources/notes_remote_datasource.dart';
import 'features/notes/data/repositories/notes_repository_impl.dart';
import 'features/notes/domain/repositories/notes_repository.dart';
import 'presentation/navigation/main_shell.dart';
import 'presentation/navigation/navigation_cubit.dart';
import 'presentation/settings/settings_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final authRepository = AuthRepositoryImpl(
    FirebaseAuthDataSource(
      firebaseAuth: FirebaseAuth.instance,
      googleSignIn: GoogleSignIn(),
    ),
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            registerUseCase: RegisterUseCase(authRepository),
            loginUseCase: LoginUseCase(authRepository),
            googleSignInUseCase: GoogleSignInUseCase(authRepository),
            logoutUseCase: LogoutUseCase(authRepository),
            passwordResetUseCase: PasswordResetUseCase(authRepository),
            emailVerificationUseCase: EmailVerificationUseCase(authRepository),
            getCurrentUserUseCase: GetCurrentUserUseCase(authRepository),
            // Restore the saved session when the app starts.
          )..add(const GetCurrentUserEvent()),
        ),
        BlocProvider(create: (_) => AuthScreenCubit()),
      ],
      child: const TechSistersApp(home: AuthGate()),
    ),
  );
}

class TechSistersApp extends StatelessWidget {
  /// The first screen. Defaults to the main shell so the app (and its tests)
  /// can run without Firebase; `main()` passes the login gate instead.
  final Widget home;

  const TechSistersApp({super.key, this.home = const MainShell()});

  @override
  Widget build(BuildContext context) {
    // Notes repository for the Saved notes feature. Lazy, so Firestore is
    // only touched when the notes screen is first opened.
    return RepositoryProvider<NotesRepository>(
      create: (_) => NotesRepositoryImpl(dataSource: NotesRemoteDataSource()),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => NavigationCubit()),
          BlocProvider(create: (_) => SettingsCubit()..load()),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settings) {
            return MaterialApp(
              title: 'TechSisters',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
              home: home,
            );
          },
        ),
      ),
    );
  }
}
