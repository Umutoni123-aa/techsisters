import 'package:equatable/equatable.dart';

/// A project the learner saved in their portfolio, stored at
/// `users/{uid}/projects/{projectId}`.
class PortfolioProject extends Equatable {
  final String id;
  final String title;
  final String description;

  /// Optional link to the finished work (a website, a repository, a video).
  final String link;
  final DateTime createdAt;

  const PortfolioProject({
    required this.id,
    required this.title,
    required this.description,
    required this.link,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, description, link, createdAt];
}
