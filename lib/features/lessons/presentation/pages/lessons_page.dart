import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techsisters/features/lessons/domain/entities/course.dart';
import 'package:techsisters/features/lessons/lessons_module.dart';
import 'package:techsisters/features/lessons/presentation/bloc/lesson_session_bloc.dart';
import 'package:techsisters/features/lessons/presentation/bloc/lessons_bloc.dart';
import 'package:techsisters/features/lessons/presentation/pages/lesson_detail_page.dart';
import 'package:techsisters/features/lessons/presentation/widgets/lesson_card.dart';
import 'package:techsisters/features/lessons/presentation/widgets/lessons_colors.dart';

/// Course Catalog (Figma "06 Catalog"): search, category chips and courses.
class LessonsPage extends StatelessWidget {
  final String userId;

  const LessonsPage({super.key, required this.userId});

  /// Builds the page with its own [LessonsBloc] for [userId].
  /// Use this from navigation so the page needs no other setup.
  static Widget withBloc({required String userId}) {
    final module = LessonsModule();
    return RepositoryProvider.value(
      value: module,
      child: BlocProvider(
        create: (_) => LessonsBloc(
          watchCourses: module.watchCourses,
          watchProgress: module.watchProgress,
          watchStats: module.watchStats,
          resetProgress: module.resetProgress,
        )..add(LoadLessonsEvent(userId)),
        child: LessonsPage(userId: userId),
      ),
    );
  }

  void _openCourse(BuildContext context, Course course, LessonsLoaded state) {
    final module = context.read<LessonsModule>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => LessonSessionBloc(
            course: course,
            userId: userId,
            getLessons: module.getLessons,
            completeLesson: module.completeLesson,
            completedLessons: state.completedLessonsFor(course.id),
            stats: state.stats,
          )..add(const SessionStartedEvent()),
          child: const LessonDetailPage(),
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, Course course) async {
    final bloc = context.read<LessonsBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset progress?'),
        content: Text('Your progress in "${course.title}" will be cleared.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true) bloc.add(ResetProgressEvent(course.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LessonsColors.background,
      body: SafeArea(
        child: BlocConsumer<LessonsBloc, LessonsState>(
          // Show write errors (e.g. a failed reset) as a snackbar.
          listenWhen: (previous, current) =>
              current is LessonsLoaded &&
              current.message != null &&
              (previous is! LessonsLoaded ||
                  previous.messageId != current.messageId),
          listener: (context, state) {
            final message = (state as LessonsLoaded).message!;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
          },
          builder: (context, state) {
            if (state is LessonsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(state.message, textAlign: TextAlign.center),
                ),
              );
            }
            if (state is! LessonsLoaded) {
              return const Center(child: CircularProgressIndicator());
            }
            final courses = state.visibleCourses;
            return Column(
              children: [
                _Header(count: state.courses.length),
                _SearchField(
                  onChanged: (q) =>
                      context.read<LessonsBloc>().add(SearchChangedEvent(q)),
                ),
                _CategoryChips(
                  categories: state.categories,
                  selected: state.category,
                  onSelected: (c) =>
                      context.read<LessonsBloc>().add(CategorySelectedEvent(c)),
                ),
                Expanded(
                  child: courses.isEmpty
                      ? const Center(child: Text('No courses found.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: courses.length,
                          itemBuilder: (context, index) {
                            final course = courses[index];
                            return CourseCard(
                              course: course,
                              percent: state.percentFor(course),
                              onTap: () => _openCourse(context, course, state),
                              onLongPress: () => _confirmReset(context, course),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int count;
  const _Header({required this.count});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          if (canPop) ...[
            _IconBox(
              icon: Icons.arrow_back,
              tooltip: 'Back',
              onTap: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Course Catalog',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: LessonsColors.ink,
                  ),
                ),
                Text(
                  '$count courses available',
                  style: const TextStyle(
                    fontSize: 12,
                    color: LessonsColors.slate,
                  ),
                ),
              ],
            ),
          ),
          const _IconBox(icon: Icons.tune, tooltip: 'Filters', filled: true),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool filled;

  const _IconBox({
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? LessonsColors.purpleSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: filled ? LessonsColors.purpleSurface : LessonsColors.border,
        ),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
        // 48dp keeps the Material minimum tap target.
        child: SizedBox(
          width: 48,
          height: 48,
          child: Tooltip(
            message: tooltip,
            child: Icon(
              icon,
              size: 20,
              color: filled ? LessonsColors.purple : LessonsColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search courses...',
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: LessonsColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: LessonsColors.purple),
          ),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selected;
          return Center(
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              showCheckmark: false,
              selectedColor: LessonsColors.purple,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : LessonsColors.ink,
              ),
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSelected
                      ? LessonsColors.purple
                      : LessonsColors.border,
                ),
              ),
              onSelected: (_) => onSelected(category),
            ),
          );
        },
      ),
    );
  }
}
