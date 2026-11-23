import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techsisters/features/practice/domain/entities/portfolio_project.dart';

/// Firestore mapping for [PortfolioProject].
class PortfolioProjectModel extends PortfolioProject {
  const PortfolioProjectModel({
    required super.id,
    required super.title,
    required super.description,
    required super.link,
    required super.createdAt,
  });

  factory PortfolioProjectModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final map = doc.data() ?? {};
    final created = map['createdAt'];
    return PortfolioProjectModel(
      id: doc.id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      link: map['link'] as String? ?? '',
      // A pending server timestamp is null on the local snapshot.
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
    );
  }

  /// The fields for a new project.
  static Map<String, dynamic> toNewMap(
    String title,
    String description,
    String link,
  ) => {
    'title': title,
    'description': description,
    'link': link,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  /// The fields changed when a project is edited (createdAt stays as it was).
  static Map<String, dynamic> toUpdateMap(
    String title,
    String description,
    String link,
  ) => {
    'title': title,
    'description': description,
    'link': link,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
