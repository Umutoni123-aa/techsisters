import 'package:techsisters/features/practice/domain/entities/portfolio_project.dart';

/// Contract for a learner's portfolio (full create, read, update, delete).
abstract class PortfolioRepository {
  /// Read: live list of the learner's projects, newest first.
  Stream<List<PortfolioProject>> watchProjects(String userId);

  /// Create: adds a new project.
  Future<void> addProject({
    required String userId,
    required String title,
    required String description,
    required String link,
  });

  /// Update: changes an existing project.
  Future<void> updateProject({
    required String userId,
    required String projectId,
    required String title,
    required String description,
    required String link,
  });

  /// Delete: removes a project.
  Future<void> deleteProject({
    required String userId,
    required String projectId,
  });
}
