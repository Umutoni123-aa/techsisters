import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techsisters/features/lessons/domain/entities/lesson_progress.dart';
import 'package:techsisters/features/lessons/domain/entities/user_stats.dart';

/// Firestore mapping for [LessonProgress].
class LessonProgressModel extends LessonProgress {
  const LessonProgressModel({
    required super.courseId,
    required super.completedLessons,
    required super.updatedAt,
  });

  factory LessonProgressModel.fromMap(
    String courseId,
    Map<String, dynamic> map,
  ) {
    final timestamp = map['updatedAt'];
    return LessonProgressModel(
      courseId: courseId,
      completedLessons: (map['completedLessons'] as num?)?.toInt() ?? 0,
      // A pending server timestamp is null on the local snapshot.
      updatedAt: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
    );
  }

  static Map<String, dynamic> toMap(int completedLessons) => {
    'completedLessons': completedLessons,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  static UserStats statsFromMap(Map<String, dynamic>? map) {
    if (map == null) return UserStats.empty;
    final last = map['lastActive'];
    return UserStats(
      xp: (map['xp'] as num?)?.toInt() ?? 0,
      streak: (map['streak'] as num?)?.toInt() ?? 0,
      lastActive: last is Timestamp ? last.toDate() : null,
    );
  }

  static Map<String, dynamic> statsToMap(UserStats stats) => {
    'xp': stats.xp,
    'streak': stats.streak,
    if (stats.lastActive != null)
      'lastActive': Timestamp.fromDate(stats.lastActive!),
  };
}
