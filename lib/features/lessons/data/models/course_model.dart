import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techsisters/features/lessons/domain/entities/course.dart';

/// Firestore mapping for [Course].
class CourseModel extends Course {
  const CourseModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.lessonCount,
    required super.minutesPerLesson,
    required super.sizeMb,
    required super.order,
  });

  factory CourseModel.fromMap(String id, Map<String, dynamic> map) {
    return CourseModel(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      lessonCount: (map['lessonCount'] as num?)?.toInt() ?? 0,
      minutesPerLesson: (map['minutesPerLesson'] as num?)?.toInt() ?? 5,
      sizeMb: (map['sizeMb'] as num?)?.toDouble() ?? 0,
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }

  factory CourseModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      CourseModel.fromMap(doc.id, doc.data() ?? {});
}
