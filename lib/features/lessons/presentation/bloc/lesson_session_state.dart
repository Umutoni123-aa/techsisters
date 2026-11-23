part of 'lesson_session_bloc.dart';

enum SessionStatus { loading, ready, error }

class LessonSessionState extends Equatable {
  final SessionStatus status;
  final List<Lesson> lessons;
  final int lessonIndex;
  final int questionIndex;
  final int? selected;

  /// True after "Check Answer" was pressed on a wrong answer.
  final bool checkedWrong;

  /// True once the current question was answered correctly (and the lesson
  /// is not finished yet), so the explanation and "Next Question" show.
  final bool answeredCorrect;

  /// Wrong attempts on the current question.
  final int wrongAttempts;

  /// Questions of this lesson answered correctly on the first try.
  final int firstTryCorrect;
  final bool saving;

  /// True while the "Lesson Complete" sheet should be showing.
  final bool justCompleted;
  final int completedLessons;
  final UserStats stats;
  final int pointsEarned;

  /// One-shot message for a snackbar; [noticeId] makes repeats distinct.
  final String? notice;
  final int noticeId;
  final String? errorMessage;

  const LessonSessionState({
    this.status = SessionStatus.loading,
    this.lessons = const [],
    this.lessonIndex = 0,
    this.questionIndex = 0,
    this.selected,
    this.checkedWrong = false,
    this.answeredCorrect = false,
    this.wrongAttempts = 0,
    this.firstTryCorrect = 0,
    this.saving = false,
    this.justCompleted = false,
    this.completedLessons = 0,
    this.stats = UserStats.empty,
    this.pointsEarned = 0,
    this.notice,
    this.noticeId = 0,
    this.errorMessage,
  });

  Lesson? get lesson => status == SessionStatus.ready && lessons.isNotEmpty
      ? lessons[lessonIndex]
      : null;

  Question? get question => lesson?.questions[questionIndex];

  bool get isLastQuestion =>
      lesson != null && questionIndex >= lesson!.questions.length - 1;

  bool get isLastLesson => lessonIndex >= lessons.length - 1;

  LessonSessionState copyWith({
    SessionStatus? status,
    List<Lesson>? lessons,
    int? lessonIndex,
    int? questionIndex,
    int? selected,
    bool clearSelected = false,
    bool? checkedWrong,
    bool? answeredCorrect,
    int? wrongAttempts,
    int? firstTryCorrect,
    bool? saving,
    bool? justCompleted,
    int? completedLessons,
    UserStats? stats,
    int? pointsEarned,
    String? notice,
    int? noticeId,
    String? errorMessage,
  }) {
    return LessonSessionState(
      status: status ?? this.status,
      lessons: lessons ?? this.lessons,
      lessonIndex: lessonIndex ?? this.lessonIndex,
      questionIndex: questionIndex ?? this.questionIndex,
      selected: clearSelected ? null : (selected ?? this.selected),
      checkedWrong: checkedWrong ?? this.checkedWrong,
      answeredCorrect: answeredCorrect ?? this.answeredCorrect,
      wrongAttempts: wrongAttempts ?? this.wrongAttempts,
      firstTryCorrect: firstTryCorrect ?? this.firstTryCorrect,
      saving: saving ?? this.saving,
      justCompleted: justCompleted ?? this.justCompleted,
      completedLessons: completedLessons ?? this.completedLessons,
      stats: stats ?? this.stats,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      // The notice is not carried over, so it shows only once.
      notice: notice,
      noticeId: noticeId ?? this.noticeId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    lessons,
    lessonIndex,
    questionIndex,
    selected,
    checkedWrong,
    answeredCorrect,
    wrongAttempts,
    firstTryCorrect,
    saving,
    justCompleted,
    completedLessons,
    stats,
    pointsEarned,
    notice,
    noticeId,
    errorMessage,
  ];
}
