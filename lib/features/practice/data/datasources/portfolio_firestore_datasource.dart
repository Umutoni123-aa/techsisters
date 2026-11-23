import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techsisters/features/practice/data/models/portfolio_project_model.dart';

/// Talks to Firestore for the portfolio; no business rules live here.
class PortfolioFirestoreDatasource {
  final FirebaseFirestore firestore;

  PortfolioFirestoreDatasource({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _projectsRef(String userId) =>
      firestore.collection('users').doc(userId).collection('projects');

  Stream<List<PortfolioProjectModel>> watchProjects(String userId) {
    return _projectsRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(PortfolioProjectModel.fromDoc).toList());
  }

  Future<void> addProject(
    String userId,
    String title,
    String description,
    String link,
  ) {
    return _projectsRef(userId)
        .add(PortfolioProjectModel.toNewMap(title, description, link));
  }

  Future<void> updateProject(
    String userId,
    String projectId,
    String title,
    String description,
    String link,
  ) {
    return _projectsRef(userId)
        .doc(projectId)
        .update(PortfolioProjectModel.toUpdateMap(title, description, link));
  }

  Future<void> deleteProject(String userId, String projectId) {
    return _projectsRef(userId).doc(projectId).delete();
  }
}
