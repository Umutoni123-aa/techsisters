import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techsisters/features/lessons/data/models/course_model.dart';
import 'package:techsisters/features/lessons/data/models/lesson_model.dart';
import 'package:techsisters/features/lessons/data/models/lesson_progress_model.dart';
import 'package:techsisters/features/lessons/domain/entities/user_stats.dart';

/// Talks to Firestore directly; no business rules live here.
class LessonsFirestoreDatasource {
  final FirebaseFirestore firestore;

  LessonsFirestoreDatasource({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userRef(String userId) =>
      firestore.collection('users').doc(userId);

  CollectionReference<Map<String, dynamic>> _progressRef(String userId) =>
      _userRef(userId).collection('progress');

  Stream<List<CourseModel>> watchCourses() {
    return firestore
        .collection('courses')
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs.map(CourseModel.fromDoc).toList());
  }

  Stream<Map<String, LessonProgressModel>> watchProgress(String userId) {
    return _progressRef(userId).snapshots().map(
      (snap) => {
        for (final doc in snap.docs)
          doc.id: LessonProgressModel.fromMap(doc.id, doc.data()),
      },
    );
  }

  Stream<UserStats> watchStats(String userId) {
    return _userRef(userId)
        .snapshots()
        .map((doc) => LessonProgressModel.statsFromMap(doc.data()));
  }

  Future<List<LessonModel>> getLessons(String courseId) async {
    final snap = await firestore
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .orderBy('order')
        .get();
    return snap.docs.map(LessonModel.fromDoc).toList();
  }

  Future<void> saveCompletion(
    String userId,
    String courseId,
    int completedLessons,
    UserStats stats,
  ) {
    // One batch so progress and XP never get out of sync.
    // set(merge) creates the documents the first time and updates them after.
    final batch = firestore.batch();
    batch.set(
      _progressRef(userId).doc(courseId),
      LessonProgressModel.toMap(completedLessons),
      SetOptions(merge: true),
    );
    batch.set(
      _userRef(userId),
      LessonProgressModel.statsToMap(stats),
      SetOptions(merge: true),
    );
    return batch.commit();
  }

  Future<void> resetProgress(String userId, String courseId) {
    return _progressRef(userId).doc(courseId).delete();
  }
}
