import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techsisters/features/downloads/presentation/pages/lesson_video_page.dart';
import 'package:techsisters/features/lessons/presentation/bloc/lesson_session_bloc.dart';
import 'package:techsisters/features/lessons/presentation/widgets/answer_option_tile.dart';
import 'package:techsisters/features/lessons/presentation/widgets/lesson_complete_sheet.dart';
import 'package:techsisters/features/lessons/presentation/widgets/lessons_colors.dart';
import 'package:techsisters/features/lessons/presentation/widgets/why_correct_card.dart';
import 'package:techsisters/presentation/settings/settings_cubit.dart';

/// Micro Lesson (Figma "07 Micro Lesson"): scenario, question and answers.
/// Finishing the last question opens the "Lesson Complete!" sheet (Figma "08").
class LessonDetailPage extends StatelessWidget {
  const LessonDetailPage({super.key});

  void _showSuccessSheet(BuildContext context, LessonSessionState state) {
    final bloc = context.read<LessonSessionBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => LessonCompleteSheet(
        lastQuestion: state.question!,
        stats: state.stats,
        pointsEarned: state.pointsEarned,
        totalQuestions: state.lesson!.questions.length,
        firstTryCorrect: state.firstTryCorrect,
        isLastLesson: state.isLastLesson,
        onNext: () {
          Navigator.of(sheetContext).pop();
          if (state.isLastLesson) {
            Navigator.of(context).pop();
          } else {
            bloc.add(const NextLessonEvent());
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LessonSessionBloc, LessonSessionState>(
          listenWhen: (p, c) => c.notice != null && c.noticeId != p.noticeId,
          listener: (context, state) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.notice!)));
          },
        ),
        BlocListener<LessonSessionBloc, LessonSessionState>(
          listenWhen: (p, c) => !p.justCompleted && c.justCompleted,
          listener: _showSuccessSheet,
        ),
      ],
      child: Scaffold(
        backgroundColor: LessonsColors.background,
        body: SafeArea(
          child: BlocBuilder<LessonSessionBloc, LessonSessionState>(
            builder: (context, state) {
              if (state.status == SessionStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == SessionStatus.error) {
                return _ErrorView(message: state.errorMessage ?? 'Error');
              }
              return _LessonBody(state: state);
            },
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonBody extends StatelessWidget {
  final LessonSessionState state;
  const _LessonBody({required this.state});

  String get _buttonLabel {
    if (state.checkedWrong) return 'Try Again';
    if (state.answeredCorrect) return 'Next Question';
    return 'Check Answer';
  }

  VoidCallback? _onButton(LessonSessionBloc bloc) {
    if (state.saving) return null;
    return () => bloc.add(
      state.checkedWrong
          ? const TryAgainEvent()
          : state.answeredCorrect
          ? const NextQuestionEvent()
          : const CheckAnswerEvent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LessonSessionBloc>();
    final lesson = state.lesson!;
    final question = state.question!;
    final total = lesson.questions.length;
    final number = state.questionIndex + 1;

    return Column(
      children: [
        // Header: back button, course + lesson number, title, "2 / 4".
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: LessonsColors.border),
                ),
                child: InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () => Navigator.of(context).pop(),
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Tooltip(
                      message: 'Back',
                      child: Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${bloc.course.title.toUpperCase()} · '
                      'LESSON ${state.lessonIndex + 1}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: LessonsColors.slate,
                      ),
                    ),
                    Text(
                      lesson.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: LessonsColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: LessonsColors.purpleSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$number / $total',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: LessonsColors.purple,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              // Questions already answered correctly fill the bar.
              value:
                  (state.questionIndex + (state.answeredCorrect ? 1 : 0)) /
                  total,
              minHeight: 6,
              color: LessonsColors.purple,
              backgroundColor: LessonsColors.border,
            ),
          ),
        ),
        // Scrolls so small phones and landscape never overflow.
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The lesson video is offered before the first question.
                if (lesson.videoUrl != null && state.questionIndex == 0) ...[
                  _VideoCard(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LessonVideoPage(
                          courseId: bloc.course.id,
                          lessonId: lesson.id,
                          title: lesson.title,
                          videoUrl: lesson.videoUrl!,
                          credit: lesson.videoCredit,
                          // Uses the "Download on Wi-Fi only" setting.
                          wifiOnly: context
                              .read<SettingsCubit>()
                              .state
                              .wifiOnlyDownloads,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                _ScenarioCard(
                  scenario: question.scenario,
                  prompt: question.prompt,
                  question: question.question,
                ),
                const SizedBox(height: 14),
                for (var i = 0; i < question.options.length; i++)
                  AnswerOptionTile(
                    letter: String.fromCharCode(65 + i),
                    text: question.options[i],
                    selected: state.selected == i,
                    wrong: state.selected == i && state.checkedWrong,
                    correct: state.selected == i && state.answeredCorrect,
                    onTap: state.saving || state.answeredCorrect
                        ? null
                        : () => bloc.add(OptionSelectedEvent(i)),
                  ),
                if (state.answeredCorrect) ...[
                  const SizedBox(height: 4),
                  WhyCorrectCard(question: question),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: LessonsColors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _onButton(bloc),
              child: state.saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _buttonLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  final String scenario;
  final String? prompt;
  final String question;

  const _ScenarioCard({
    required this.scenario,
    required this.prompt,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LessonsColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.circle, size: 7, color: LessonsColors.coral),
              SizedBox(width: 6),
              Text(
                'REAL-WORLD SCENARIO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: LessonsColors.coral,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            scenario,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: LessonsColors.slate,
            ),
          ),
          if (prompt != null && prompt!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: LessonsColors.codeBackground,
                borderRadius: BorderRadius.circular(10),
                border: const Border(
                  left: BorderSide(color: LessonsColors.purpleLight, width: 3),
                ),
              ),
              child: Text(
                prompt!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  height: 1.5,
                  color: Color(0xFFD8D4F2),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            question,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w700,
              color: LessonsColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// A card that opens the lesson video.
class _VideoCard extends StatelessWidget {
  final VoidCallback onTap;

  const _VideoCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LessonsColors.purpleSurface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(
                Icons.play_circle_fill,
                color: LessonsColors.purple,
                size: 36,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Watch the video',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: LessonsColors.ink,
                      ),
                    ),
                    Text(
                      'A short introduction. You can download it for offline.',
                      style: TextStyle(
                        fontSize: 12,
                        color: LessonsColors.slate,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: LessonsColors.purple),
            ],
          ),
        ),
      ),
    );
  }
}
