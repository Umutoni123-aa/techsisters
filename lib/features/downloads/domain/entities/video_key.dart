/// Builds and reads the key that identifies one lesson video on the phone.
/// The key looks like `courseId/lessonId`; lesson ids alone are not unique
/// because every course has its own lessons.
class VideoKey {
  VideoKey._();

  static String of(String courseId, String lessonId) => '$courseId/$lessonId';

  /// The course part of a key made by [of].
  static String courseIdOf(String key) => key.split('/').first;
}
