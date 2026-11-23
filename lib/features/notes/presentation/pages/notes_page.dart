import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techsisters/core/theme/app_spacing.dart';
import 'package:techsisters/core/theme/app_theme.dart';

import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../bloc/notes_bloc.dart';
import '../widgets/delete_note_dialog.dart';
import '../widgets/empty_notes_view.dart';
import '../widgets/note_card.dart';
import 'note_editor_page.dart';

/// Entry point for the Saved notes feature.
///
/// Needs a `RepositoryProvider<NotesRepository>` above it in the widget tree
/// (see README_NOTES.md) and the signed-in learner's UID. Pass [lessonId]
/// when opening notes from a lesson, so new notes are linked to it.
class NotesPage extends StatelessWidget {
  const NotesPage({super.key, required this.userId, this.lessonId});

  final String userId;
  final String? lessonId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotesBloc.fromRepository(
        repository: context.read<NotesRepository>(),
        userId: userId,
      )..add(const NotesSubscriptionRequested()),
      child: NotesView(lessonId: lessonId),
    );
  }
}

/// The notes screen itself. Split from [NotesPage] so the widget test can
/// give it a mock BLoC.
class NotesView extends StatelessWidget {
  const NotesView({super.key, this.lessonId});

  final String? lessonId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.slate900,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'My notes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<NotesBloc, NotesState>(
          listenWhen: (previous, current) =>
              current.message != null && previous.message != current.message,
          listener: _showMessage,
          builder: (context, state) {
            // AnimatedSwitcher fades between loading, empty and list views.
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _buildBody(context, state),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('notes_add_button'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add),
        label: const Text(
          'New note',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, NotesState state) {
    if (state.status == NotesStatus.initial ||
        state.status == NotesStatus.loading) {
      return const Center(
        key: ValueKey('notes_loading'),
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.status == NotesStatus.failure && state.notes.isEmpty) {
      return _ErrorView(
        key: const ValueKey('notes_error'),
        onRetry: () =>
            context.read<NotesBloc>().add(const NotesSubscriptionRequested()),
      );
    }

    if (state.notes.isEmpty) {
      return const EmptyNotesView(key: ValueKey('notes_empty'));
    }

    return ListView.separated(
      key: const ValueKey('notes_list'),
      // Bottom padding keeps the last card clear of the floating button.
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.small,
        AppSpacing.page,
        96,
      ),
      itemCount: state.notes.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.medium),
      itemBuilder: (context, index) {
        final note = state.notes[index];
        return Dismissible(
          key: ValueKey(note.id),
          direction: DismissDirection.endToStart,
          background: const _DeleteBackground(),
          confirmDismiss: (_) => showDeleteNoteDialog(context, note.title),
          onDismissed: (_) => context.read<NotesBloc>().add(NoteDeleted(note)),
          child: NoteCard(
            note: note,
            onTap: () => _openEditor(context, note: note),
          ),
        );
      },
    );
  }

  void _showMessage(BuildContext context, NotesState state) {
    final isError = state.messageType == NotesMessageType.error;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(state.message!),
          backgroundColor: isError ? AppColors.coral : AppColors.night,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  /// Opens the editor. With [note] it edits that note, otherwise it creates
  /// a new one. The same BLoC is passed on so the editor can add events.
  void _openEditor(BuildContext context, {Note? note}) {
    final bloc = context.read<NotesBloc>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: NoteEditorPage(note: note, lessonId: lessonId),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: AppColors.slate400),
            const SizedBox(height: AppSpacing.medium),
            const Text(
              "Your notes couldn't be loaded.",
              style: TextStyle(color: AppColors.slate600),
            ),
            const SizedBox(height: AppSpacing.medium),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                minimumSize: const Size(120, 48),
              ),
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      decoration: BoxDecoration(
        color: AppColors.coralSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.delete_outline, color: AppColors.coral),
    );
  }
}
