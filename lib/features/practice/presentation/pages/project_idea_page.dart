import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techsisters/core/theme/app_spacing.dart';
import 'package:techsisters/core/theme/app_theme.dart';
import 'package:techsisters/core/widgets/primary_button.dart';
import 'package:techsisters/features/practice/domain/entities/project_idea.dart';
import 'package:techsisters/features/practice/presentation/bloc/portfolio_bloc.dart';
import 'package:techsisters/features/practice/presentation/pages/project_editor_page.dart';

/// The steps of one guided project, with a button to save it to the portfolio.
class ProjectIdeaPage extends StatelessWidget {
  final ProjectIdea idea;

  const ProjectIdeaPage({super.key, required this.idea});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Project')),
      body: SafeArea(
        // Scrolls so small phones and landscape never overflow.
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.page),
          children: [
            Text(
              '${idea.category}  •  ${idea.minutes} min',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              idea.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.slate900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              idea.summary,
              style: const TextStyle(color: AppColors.slate600),
            ),
            const SizedBox(height: AppSpacing.gap),
            const Text(
              'Steps',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.slate900,
              ),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < idea.steps.length; i++)
              _StepRow(number: i + 1, text: idea.steps[i]),
            const SizedBox(height: AppSpacing.gap),
            PrimaryButton(
              label: 'Save to my portfolio',
              icon: Icons.bookmark_add_outlined,
              onPressed: () {
                final bloc = context.read<PortfolioBloc>();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: bloc,
                      child: ProjectEditorPage(
                        initialTitle: idea.title,
                        initialDescription: idea.summary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// One numbered step.
class _StepRow extends StatelessWidget {
  final int number;
  final String text;

  const _StepRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.violetSurface,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: const TextStyle(height: 1.4, color: AppColors.slate900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
