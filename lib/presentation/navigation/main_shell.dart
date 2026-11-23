import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../features/lessons/domain/entities/achievement.dart';
import '../../features/lessons/presentation/pages/achievements_page.dart';
import '../../features/lessons/presentation/pages/lessons_page.dart';
import '../../features/practice/presentation/pages/practice_page.dart';
import '../../features/onboarding/domain/entities/learner_profile.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import 'navigation_cubit.dart';

class MainShell extends StatelessWidget {
  /// The signed-in user. When null (e.g. in tests) the Learn tab shows a
  /// placeholder because lessons need a user to save progress for.
  final String? userId;
  final String? userName;
  final String? userEmail;
  final VoidCallback? onLogout;

  /// The learner's onboarding answers, used to pick the "Start here" course.
  final LearnerProfile profile;

  /// Badges, milestones and certificates; null until the data has loaded.
  final AchievementSummary? summary;

  const MainShell({
    super.key,
    this.userId,
    this.userName,
    this.userEmail,
    this.onLogout,
    this.profile = LearnerProfile.empty,
    this.summary,
  });

  /// The four numbers on the Profile screen, or null to keep the placeholders.
  List<(String, String)>? get _profileStats {
    final data = summary;
    if (data == null) return null;
    return [
      ('Lessons done', '${data.lessonsDone}'),
      ('Day streak', '${data.streak}'),
      ('Badges', '${data.badgesEarned}'),
      ('Points', '${data.points}'),
    ];
  }

  // Settings opens from the gear icon on the Profile screen.
  Widget _pageFor(BuildContext context, int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        final uid = userId;
        return uid == null
            ? const Center(child: Text('Learn'))
            : LessonsPage(userId: uid, profile: profile);
      case 2:
        // Practice needs a signed-in user to save the portfolio for.
        return userId == null
            ? const Center(child: Text('Practice'))
            : const PracticePage();
      case 3:
        return const Center(child: Text('Community'));
      default:
        final data = summary;
        return ProfileScreen(
          name: userName,
          email: userEmail,
          onLogout: onLogout,
          stats: _profileStats,
          onOpenAchievements: data == null
              ? null
              : () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AchievementsPage(
                      summary: data,
                      holderName: userName ?? 'Learner',
                    ),
                  ),
                ),
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
            body: SafeArea(child: _pageFor(context, currentIndex)),
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
                  icon: Icon(Icons.build_outlined),
                  label: 'Practice',
                ),
                NavigationDestination(
                  icon: Icon(Icons.groups_outlined),
                  label: 'Community',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
