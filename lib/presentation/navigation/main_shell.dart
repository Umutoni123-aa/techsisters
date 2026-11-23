import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import 'navigation_cubit.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  // Temporary pages.
  static const List<Widget> _pages = [
    HomeScreen(),
    Center(child: Text('Learn')),
    Center(child: Text('Community')),
    Center(child: Text('Profile')),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, int>(
      builder: (context, currentIndex) {
        return Scaffold(
          body: SafeArea(child: _pages[currentIndex]),
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
        );
      },
    );
  }
}
