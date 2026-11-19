import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'presentation/navigation/main_shell.dart';
import 'presentation/navigation/navigation_cubit.dart';

void main() {
  runApp(const TechSistersApp());
}

class TechSistersApp extends StatelessWidget {
  const TechSistersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavigationCubit(),
      child: MaterialApp(
        title: 'TechSisters',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const MainShell(),
      ),
    );
  }
}