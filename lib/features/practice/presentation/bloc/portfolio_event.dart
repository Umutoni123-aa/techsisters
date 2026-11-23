part of 'portfolio_bloc.dart';

abstract class PortfolioEvent extends Equatable {
  const PortfolioEvent();

  @override
  List<Object?> get props => [];
}

/// Start listening to the learner's portfolio.
class LoadPortfolioEvent extends PortfolioEvent {
  const LoadPortfolioEvent();
}

/// Add a new project, or update one when [projectId] is given.
class SaveProjectEvent extends PortfolioEvent {
  final String? projectId;
  final String title;
  final String description;
  final String link;

  const SaveProjectEvent({
    this.projectId,
    required this.title,
    required this.description,
    required this.link,
  });

  @override
  List<Object?> get props => [projectId, title, description, link];
}

class DeleteProjectEvent extends PortfolioEvent {
  final String projectId;
  const DeleteProjectEvent(this.projectId);

  @override
  List<Object?> get props => [projectId];
}
