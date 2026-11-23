import 'package:flutter_test/flutter_test.dart';
import 'package:techsisters/features/lessons/domain/entities/course.dart';
import 'package:techsisters/features/lessons/domain/entities/course_recommender.dart';
import 'package:techsisters/features/lessons/domain/entities/lesson_progress.dart';
import 'package:techsisters/features/onboarding/domain/entities/learner_profile.dart';

Course _course(String id, String category, int order, {int lessons = 2}) =>
    Course(
      id: id,
      title: id,
      description: '',
      category: category,
      lessonCount: lessons,
      minutesPerLesson: 5,
      sizeMb: 1,
      order: order,
    );

LessonProgress _progress(String courseId, int done) => LessonProgress(
  courseId: courseId,
  completedLessons: done,
  updatedAt: DateTime(2026, 11, 20),
);

void main() {
  final courses = [
    _course('ai-1', 'AI Literacy', 1),
    _course('code-1', 'Coding', 2),
    _course('code-2', 'Coding', 3),
    _course('ai-2', 'AI Literacy', 4),
  ];

  String? pick(LearnerProfile profile, [Map<String, LessonProgress>? done]) =>
      CourseRecommender.pick(
        courses: courses,
        progress: done ?? {},
        profile: profile,
      );

  test('a beginner who wants coding starts with the first coding course', () {
    const profile = LearnerProfile(
      goal: LearningGoal.coding,
      level: SkillLevel.beginner,
    );
    expect(pick(profile), 'code-1');
  });

  test('an AI goal picks from the AI Literacy courses', () {
    const profile = LearnerProfile(
      goal: LearningGoal.ai,
      level: SkillLevel.some,
    );
    expect(pick(profile), 'ai-1');
  });

  test('a confident learner is sent to the most advanced matching course', () {
    const profile = LearnerProfile(
      goal: LearningGoal.coding,
      level: SkillLevel.confident,
    );
    expect(pick(profile), 'code-2');
  });

  test('a course that is already started is suggested first', () {
    const profile = LearnerProfile(
      goal: LearningGoal.coding,
      level: SkillLevel.beginner,
    );
    expect(pick(profile, {'code-2': _progress('code-2', 1)}), 'code-2');
  });

  test('completed courses are skipped', () {
    const profile = LearnerProfile(
      goal: LearningGoal.coding,
      level: SkillLevel.beginner,
    );
    expect(pick(profile, {'code-1': _progress('code-1', 2)}), 'code-2');
  });

  test('an empty profile falls back to the first course', () {
    expect(pick(LearnerProfile.empty), 'ai-1');
  });

  test('returns null when every course is finished', () {
    final everything = {for (final c in courses) c.id: _progress(c.id, 2)};
    expect(pick(LearnerProfile.empty, everything), isNull);
  });
}
