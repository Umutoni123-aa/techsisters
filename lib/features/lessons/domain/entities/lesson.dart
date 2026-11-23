import 'package:equatable/equatable.dart';

/// One multiple-choice question inside a lesson.
class Question extends Equatable {
  /// The real-world scenario shown above the question.
  final String scenario;

  /// Optional prompt or code shown in the dark box under the scenario.
  final String? prompt;
  final String question;
  final List<String> options;
  final int correctIndex;

  /// Shown in "Why this answer is correct".
  final String explanation;
  final List<String> tags;

  const Question({
    required this.scenario,
    required this.prompt,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.tags,
  });

  @override
  List<Object?> get props => [
    scenario,
    prompt,
    question,
    options,
    correctIndex,
    explanation,
    tags,
  ];
}

/// A lesson stored at `courses/{courseId}/lessons/{lessonId}`. It is finished
/// only when every one of its [questions] has been answered correctly.
class Lesson extends Equatable {
  final String id;
  final String title;
  final int order;
  final List<Question> questions;

  const Lesson({
    required this.id,
    required this.title,
    required this.order,
    required this.questions,
  });

  @override
  List<Object?> get props => [id, title, order, questions];
}
