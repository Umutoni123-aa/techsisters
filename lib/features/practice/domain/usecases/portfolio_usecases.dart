import 'package:techsisters/features/practice/domain/entities/portfolio_project.dart';
import 'package:techsisters/features/practice/domain/repositories/portfolio_repository.dart';

/// Streams the learner's portfolio projects.
class WatchProjectsUseCase {
  final PortfolioRepository repository;
  WatchProjectsUseCase(this.repository);

  Stream<List<PortfolioProject>> call(String userId) =>
      repository.watchProjects(userId);
}

/// Adds a project, or updates it when [projectId] is given.
class SaveProjectUseCase {
  final PortfolioRepository repository;
  SaveProjectUseCase(this.repository);

  Future<void> call({
    required String userId,
    String? projectId,
    required String title,
    required String description,
    required String link,
  }) {
    // Trim here so every caller stores clean text.
    final cleanTitle = title.trim();
    final cleanDescription = description.trim();
    final cleanLink = link.trim();

    if (projectId == null) {
      return repository.addProject(
        userId: userId,
        title: cleanTitle,
        description: cleanDescription,
        link: cleanLink,
      );
    }
    return repository.updateProject(
      userId: userId,
      projectId: projectId,
      title: cleanTitle,
      description: cleanDescription,
      link: cleanLink,
    );
  }
}

/// Deletes a project from the portfolio.
class DeleteProjectUseCase {
  final PortfolioRepository repository;
  DeleteProjectUseCase(this.repository);

  Future<void> call({required String userId, required String projectId}) {
    return repository.deleteProject(userId: userId, projectId: projectId);
  }
}
