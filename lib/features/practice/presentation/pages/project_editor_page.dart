import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techsisters/core/theme/app_spacing.dart';
import 'package:techsisters/core/theme/app_theme.dart';
import 'package:techsisters/core/widgets/app_text_field.dart';
import 'package:techsisters/core/widgets/primary_button.dart';
import 'package:techsisters/features/practice/domain/entities/portfolio_project.dart';
import 'package:techsisters/features/practice/domain/entities/project_validator.dart';
import 'package:techsisters/features/practice/presentation/bloc/portfolio_bloc.dart';

/// The form for adding a project to the portfolio, or editing an existing one.
///
/// Pass [project] to edit it. Otherwise a new project is created, optionally
/// starting from [initialTitle] and [initialDescription] (used when saving a
/// project idea).
class ProjectEditorPage extends StatefulWidget {
  final PortfolioProject? project;
  final String initialTitle;
  final String initialDescription;

  const ProjectEditorPage({
    super.key,
    this.project,
    this.initialTitle = '',
    this.initialDescription = '',
  });

  @override
  State<ProjectEditorPage> createState() => _ProjectEditorPageState();
}

/// Only holds the text controllers and the form key; all saving logic is in
/// [PortfolioBloc].
class _ProjectEditorPageState extends State<ProjectEditorPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _linkController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool get _isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    final project = widget.project;
    _titleController = TextEditingController(
      text: project?.title ?? widget.initialTitle,
    );
    _descriptionController = TextEditingController(
      text: project?.description ?? widget.initialDescription,
    );
    _linkController = TextEditingController(text: project?.link ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<PortfolioBloc>().add(
      SaveProjectEvent(
        projectId: widget.project?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        link: _linkController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_isEditing ? 'Edit project' : 'Add project')),
      body: SafeArea(
        child: BlocConsumer<PortfolioBloc, PortfolioState>(
          // Close the form once a save succeeds.
          listenWhen: (p, c) => c.savedCount != p.savedCount,
          listener: (context, state) => Navigator.of(context).pop(),
          builder: (context, state) {
            // Scrolls so the keyboard and landscape never cause overflow.
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.page),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      label: 'Title',
                      hint: 'e.g. My profile page',
                      controller: _titleController,
                      validator: ProjectValidator.validateTitle,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    _DescriptionField(controller: _descriptionController),
                    const SizedBox(height: AppSpacing.medium),
                    AppTextField(
                      label: 'Link (optional)',
                      hint: 'https://',
                      controller: _linkController,
                      keyboardType: TextInputType.url,
                      validator: ProjectValidator.validateLink,
                    ),
                    const SizedBox(height: AppSpacing.gap),
                    PrimaryButton(
                      label: state.saving ? 'Saving...' : 'Save project',
                      onPressed: state.saving ? null : _save,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A multi-line text box that matches the shared AppTextField style.
class _DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  const _DescriptionField({required this.controller});

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.slate600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          minLines: 4,
          maxLines: 6,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            hintText: 'What did you build and what did you learn?',
            hintStyle: const TextStyle(color: AppColors.slate400),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.all(16),
            border: border(AppColors.slateBorder),
            enabledBorder: border(AppColors.slateBorder),
            focusedBorder: border(AppColors.primary, 2),
          ),
        ),
      ],
    );
  }
}
