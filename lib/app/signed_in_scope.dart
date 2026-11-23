import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techsisters/features/authentication/domain/entities/user_entity.dart';
import 'package:techsisters/features/downloads/downloads_module.dart';
import 'package:techsisters/features/lessons/lessons_module.dart';
import 'package:techsisters/features/lessons/presentation/bloc/lessons_bloc.dart';
import 'package:techsisters/features/onboarding/data/datasources/onboarding_firestore_datasource.dart';
import 'package:techsisters/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:techsisters/features/onboarding/domain/entities/learner_profile.dart';
import 'package:techsisters/features/onboarding/domain/usecases/onboarding_usecases.dart';
import 'package:techsisters/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:techsisters/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:techsisters/features/practice/data/datasources/portfolio_firestore_datasource.dart';
import 'package:techsisters/features/practice/data/repositories/portfolio_repository_impl.dart';
import 'package:techsisters/features/practice/domain/usecases/portfolio_usecases.dart';
import 'package:techsisters/features/practice/presentation/bloc/portfolio_bloc.dart';
import 'package:techsisters/presentation/navigation/main_shell.dart';

/// Everything that exists only while someone is signed in.
///
/// It creates the lessons data (shared by the Learn tab and the Profile
/// stats), runs onboarding for new learners, and then shows the main app.
class SignedInScope extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onLogout;

  const SignedInScope({super.key, required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => LessonsModule(),
      child: BlocProvider(
        create: (context) {
          final module = context.read<LessonsModule>();
          return LessonsBloc(
              watchCourses: module.watchCourses,
              watchProgress: module.watchProgress,
              watchStats: module.watchStats,
              resetProgress: module.resetProgress,
              listDownloadedKeys: DownloadsModule().listDownloadedKeys,
            )
            ..add(LoadLessonsEvent(user.uid))
            ..add(const RefreshDownloadsEvent());
        },
        // The portfolio is used by the Practice tab.
        child: BlocProvider(
          create: (_) {
            final repository = PortfolioRepositoryImpl(
              PortfolioFirestoreDatasource(),
            );
            return PortfolioBloc(
              userId: user.uid,
              watchProjects: WatchProjectsUseCase(repository),
              saveProject: SaveProjectUseCase(repository),
              deleteProject: DeleteProjectUseCase(repository),
            )..add(const LoadPortfolioEvent());
          },
          child: _withOnboarding(),
        ),
      ),
    );
  }

  /// Shows the onboarding questions first when the learner has not answered
  /// them yet, then the main app.
  Widget _withOnboarding() {
    return BlocProvider(
      create: (_) {
        final repository = OnboardingRepositoryImpl(
          OnboardingFirestoreDatasource(),
        );
        return OnboardingBloc(
          userId: user.uid,
          watchProfile: WatchLearnerProfileUseCase(repository),
          saveProfile: SaveLearnerProfileUseCase(repository),
        )..add(const LoadProfileEvent());
      },
      child: BlocBuilder<OnboardingBloc, OnboardingState>(
        builder: (context, onboarding) {
          switch (onboarding.status) {
            case OnboardingStatus.loading:
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            case OnboardingStatus.needsOnboarding:
              return const OnboardingPage();
            case OnboardingStatus.ready:
              return _shell(onboarding.profile);
          }
        },
      ),
    );
  }

  /// The main app. It rebuilds when the lessons data changes so the Profile
  /// stats and badges stay up to date.
  Widget _shell(LearnerProfile profile) {
    return BlocBuilder<LessonsBloc, LessonsState>(
      builder: (context, lessons) {
        return MainShell(
          userId: user.uid,
          userName: user.displayName,
          userEmail: user.email.isEmpty ? null : user.email,
          onLogout: onLogout,
          profile: profile,
          summary: lessons is LessonsLoaded ? lessons.summary : null,
        );
      },
    );
  }
}
