import 'package:equatable/equatable.dart';

/// A guided project a learner can try. The ideas are part of the app, so they
/// work offline and need no database.
class ProjectIdea extends Equatable {
  final String id;
  final String title;
  final String summary;
  final String category;
  final int minutes;

  /// The steps to follow, in order.
  final List<String> steps;

  const ProjectIdea({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.minutes,
    required this.steps,
  });

  @override
  List<Object?> get props => [id, title, summary, category, minutes, steps];
}

/// The project ideas shown on the Practice tab.
class ProjectIdeas {
  ProjectIdeas._();

  static const List<ProjectIdea> all = [
    ProjectIdea(
      id: 'personal-page',
      title: 'Build a personal profile page',
      summary: 'Make a one-page website about yourself with HTML.',
      category: 'Coding',
      minutes: 30,
      steps: [
        'Write your name as the main heading with an h1 tag.',
        'Add a short paragraph about you with a p tag.',
        'List three things you enjoy using ul and li tags.',
        'Add a link to a website you like with an a tag.',
        'Open the file in a browser and take a screenshot.',
      ],
    ),
    ProjectIdea(
      id: 'tip-calculator',
      title: 'Make a tip calculator',
      summary: 'Write a small Dart program that works out a tip for a bill.',
      category: 'Coding',
      minutes: 45,
      steps: [
        'Create two variables: the bill amount and the tip percentage.',
        'Write a function that returns the tip for a bill.',
        'Print the bill, the tip and the total.',
        'Try it with three different bills and check the answers by hand.',
        'Add a check that stops negative bill amounts.',
      ],
    ),
    ProjectIdea(
      id: 'bias-audit',
      title: 'Spot the bias in an AI tool',
      summary: 'Test an AI tool you use and find where it does not work well.',
      category: 'AI Literacy',
      minutes: 30,
      steps: [
        'Choose a tool you use, such as a translator or a photo app.',
        'Test it with five examples from your own language or community.',
        'Write down where the results were wrong or unfair.',
        'Explain in three sentences why this may happen (think of training data).',
        'Suggest one change that would make the tool fairer.',
      ],
    ),
    ProjectIdea(
      id: 'ai-rules',
      title: 'Write your own rules for using AI',
      summary: 'Decide how you will use AI tools to learn, not just to copy.',
      category: 'AI Literacy',
      minutes: 20,
      steps: [
        'List three ways AI has helped you learn something.',
        'List two situations where using AI would be cheating yourself.',
        'Write five personal rules for using AI responsibly.',
        'Share your rules with a friend and ask what they would add.',
      ],
    ),
  ];
}
