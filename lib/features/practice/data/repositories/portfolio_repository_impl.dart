import 'package:techsisters/features/practice/data/datasources/portfolio_firestore_datasource.dart';
import 'package:techsisters/features/practice/domain/entities/portfolio_project.dart';
import 'package:techsisters/features/practice/domain/repositories/portfolio_repository.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  final PortfolioFirestoreDatasource datasource;

  PortfolioRepositoryImpl(this.datasource);

  @override
  Stream<List<PortfolioProject>> watchProjects(String userId) =>
      datasource.watchProjects(userId);

  @override
  Future<void> addProject({
    required String userId,
    required String title,
    required String description,
    required String link,
  }) => datasource.addProject(userId, title, description, link);

  @override
  Future<void> updateProject({
    required String userId,
    required String projectId,
    required String title,
    required String description,
    required String link,
  }) => datasource.updateProject(userId, projectId, title, description, link);

  @override
  Future<void> deleteProject({
    required String userId,
    required String projectId,
  }) => datasource.deleteProject(userId, projectId);
}
