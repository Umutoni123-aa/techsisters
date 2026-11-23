import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techsisters/features/practice/domain/entities/portfolio_project.dart';
import 'package:techsisters/features/practice/domain/entities/project_validator.dart';
import 'package:techsisters/features/practice/domain/usecases/portfolio_usecases.dart';

part 'portfolio_event.dart';
part 'portfolio_state.dart';

/// Manages the learner's portfolio: shows the saved projects and handles
/// adding, editing and deleting them.
class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  final String userId;
  final WatchProjectsUseCase watchProjects;
  final SaveProjectUseCase saveProject;
  final DeleteProjectUseCase deleteProject;

  PortfolioBloc({
    required this.userId,
    required this.watchProjects,
    required this.saveProject,
    required this.deleteProject,
  }) : super(const PortfolioState()) {
    on<LoadPortfolioEvent>(_onLoad);
    on<SaveProjectEvent>(_onSave);
    on<DeleteProjectEvent>(_onDelete);
  }

  /// Follows the live list of projects.
  Future<void> _onLoad(LoadPortfolioEvent event, Emitter<PortfolioState> emit) {
    return emit.forEach<List<PortfolioProject>>(
      watchProjects(userId),
      onData: (projects) =>
          state.copyWith(status: PortfolioStatus.loaded, projects: projects),
      onError: (error, _) => state.copyWith(
        status: PortfolioStatus.error,
        errorMessage: 'Could not load your portfolio: $error',
      ),
    );
  }

  Future<void> _onSave(
    SaveProjectEvent event,
    Emitter<PortfolioState> emit,
  ) async {
    if (state.saving) return;

    // Validation: show the first problem found.
    final problem =
        ProjectValidator.validateTitle(event.title) ??
        ProjectValidator.validateLink(event.link);
    if (problem != null) {
      emit(state.copyWith(notice: problem, noticeId: state.noticeId + 1));
      return;
    }

    emit(state.copyWith(saving: true));
    try {
      await saveProject(
        userId: userId,
        projectId: event.projectId,
        title: event.title,
        description: event.description,
        link: event.link,
      );
      emit(
        state.copyWith(
          saving: false,
          savedCount: state.savedCount + 1,
          notice: 'Project saved',
          noticeId: state.noticeId + 1,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          saving: false,
          notice: 'Could not save the project: $error',
          noticeId: state.noticeId + 1,
        ),
      );
    }
  }

  Future<void> _onDelete(
    DeleteProjectEvent event,
    Emitter<PortfolioState> emit,
  ) async {
    try {
      await deleteProject(userId: userId, projectId: event.projectId);
      emit(
        state.copyWith(notice: 'Project deleted', noticeId: state.noticeId + 1),
      );
    } catch (error) {
      emit(
        state.copyWith(
          notice: 'Could not delete the project: $error',
          noticeId: state.noticeId + 1,
        ),
      );
    }
  }
}
