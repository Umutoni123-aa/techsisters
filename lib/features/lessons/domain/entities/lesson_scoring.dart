/// Rules for how many points a finished lesson is worth.
class LessonScoring {
  LessonScoring._();

  /// Points for a question answered correctly on the first try.
  static const int firstTryPoints = 5;

  /// Points for a question that needed more than one try.
  static const int retryPoints = 2;

  /// Total points for a lesson with [totalQuestions] questions, of which
  /// [firstTryCorrect] were right on the first try.
  static int pointsFor({
    required int totalQuestions,
    required int firstTryCorrect,
  }) {
    final firstTry = firstTryCorrect.clamp(0, totalQuestions);
    return firstTry * firstTryPoints +
        (totalQuestions - firstTry) * retryPoints;
  }
}
