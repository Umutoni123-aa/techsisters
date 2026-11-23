import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../features/lessons/presentation/pages/lessons_page.dart';
import 'navigation_cubit.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatelessWidget {
  /// The signed-in user. When null (e.g. in tests) the Learn tab shows a
  /// placeholder because lessons need a user to save progress for.
  final String? userId;
  final String? userName;
  final String? userEmail;
  final VoidCallback? onLogout;

  const MainShell({
    super.key,
    this.userId,
    this.userName,
    this.userEmail,
    this.onLogout,
  });

  // Temporary pages.
  Widget _pageFor(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        final uid = userId;
        return uid == null
            ? const Center(child: Text('Learn'))
            : LessonsPage.withBloc(userId: uid);
      case 2:
        return const Center(child: Text('Community'));
      case 3:
        return const Center(child: Text('Profile'));
      default:
        return ProfileScreen(
          name: userName,
          email: userEmail,
          onLogout: onLogout,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, int>(
      builder: (context, currentIndex) {
        return PopScope(
          // Back from any other tab returns to Home before leaving the app.
          canPop: currentIndex == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) context.read<NavigationCubit>().selectTab(0);
          },
          child: Scaffold(
            body: SafeArea(child: _pageFor(currentIndex)),
            bottomNavigationBar: NavigationBar(
              selectedIndex: currentIndex,
              indicatorColor: AppColors.violetSurface,
              onDestinationSelected: (index) =>
                  context.read<NavigationCubit>().selectTab(index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  label: 'Learn',
                ),
                NavigationDestination(
                  icon: Icon(Icons.groups_outlined),
                  label: 'Community',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
