import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techsisters/core/theme/app_spacing.dart';
import 'package:techsisters/core/theme/app_theme.dart';
import 'package:techsisters/core/widgets/app_text_field.dart';
import 'package:techsisters/core/widgets/primary_button.dart';

import '../../domain/entities/note.dart';
import '../../domain/validators/note_validator.dart';
import '../bloc/notes_bloc.dart';
import '../widgets/delete_note_dialog.dart';
import '../widgets/note_body_field.dart';

/// Create a note (when [note] is null) or edit an existing one.
///
/// This is a StatefulWidget only so the text controllers and form key live
/// as long as the screen and are disposed properly. It never calls
/// setState: all app state is in [NotesBloc].
class NoteEditorPage extends StatefulWidget {
  const NoteEditorPage({super.key, this.note, this.lessonId});

  final Note? note;

  /// Lesson to link a new note to. Ignored when editing.
  final String? lessonId;

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    // Shows the validator messages under the fields if anything is wrong.
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final bloc = context.read<NotesBloc>();
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final note = widget.note;

    if (note == null) {
      bloc.add(
        NoteAdded(title: title, content: content, lessonId: widget.lessonId),
      );
    } else {
      bloc.add(NoteUpdated(note: note, title: title, content: content));
    }
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final note = widget.note;
    if (note == null) return;

    final confirmed = await showDeleteNoteDialog(context, note.title);
    if (!confirmed || !mounted) return;

    context.read<NotesBloc>().add(NoteDeleted(note));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.slate900,
        surfaceTintColor: Colors.transparent,
        title: Text(
          _isEditing ? 'Edit note' : 'New note',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              key: const Key('note_editor_delete_button'),
              tooltip: 'Delete note',
              icon: const Icon(Icons.delete_outline, color: AppColors.coral),
              onPressed: _delete,
            ),
        ],
      ),
      body: SafeArea(
        // Scrolls so the form never overflows in landscape or with the
        // keyboard open.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  key: const Key('note_editor_title_field'),
                  label: 'Title',
                  hint: 'Dart variables',
                  controller: _titleController,
                  validator: NoteValidator.validateTitle,
                ),
                const SizedBox(height: AppSpacing.medium),
                NoteBodyField(
                  key: const Key('note_editor_content_field'),
                  controller: _contentController,
                  validator: NoteValidator.validateContent,
                ),
                const SizedBox(height: AppSpacing.gap),
                PrimaryButton(
                  key: const Key('note_editor_save_button'),
                  label: _isEditing ? 'Save changes' : 'Save note',
                  icon: Icons.check,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
