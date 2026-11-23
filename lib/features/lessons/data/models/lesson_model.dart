import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techsisters/features/lessons/domain/entities/lesson.dart';

/// Firestore mapping for [Lesson] and its embedded [Question]s.
class LessonModel extends Lesson {
  const LessonModel({
    required super.id,
    required super.title,
    required super.order,
    required super.questions,
    super.videoUrl,
    super.videoCredit,
  });

  factory LessonModel.fromMap(String id, Map<String, dynamic> map) {
    final rawQuestions = map['questions'] as List? ?? const [];
    return LessonModel(
      id: id,
      title: map['title'] as String? ?? '',
      order: (map['order'] as num?)?.toInt() ?? 0,
      questions: [
        for (final raw in rawQuestions)
          _questionFromMap(Map<String, dynamic>.from(raw as Map)),
      ],
      videoUrl: map['videoUrl'] as String?,
      videoCredit: map['videoCredit'] as String?,
    );
  }

  static Question _questionFromMap(Map<String, dynamic> map) {
    return Question(
      scenario: map['scenario'] as String? ?? '',
      prompt: map['prompt'] as String?,
      question: map['question'] as String? ?? '',
      options: List<String>.from(map['options'] as List? ?? const []),
      correctIndex: (map['correctIndex'] as num?)?.toInt() ?? 0,
      explanation: map['explanation'] as String? ?? '',
      tags: List<String>.from(map['tags'] as List? ?? const []),
    );
  }

  factory LessonModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      LessonModel.fromMap(doc.id, doc.data() ?? {});
}
