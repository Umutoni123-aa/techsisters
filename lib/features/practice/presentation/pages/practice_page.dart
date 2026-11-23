import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techsisters/core/theme/app_spacing.dart';
import 'package:techsisters/core/theme/app_theme.dart';
import 'package:techsisters/core/widgets/app_card.dart';
import 'package:techsisters/features/practice/domain/entities/portfolio_project.dart';
import 'package:techsisters/features/practice/domain/entities/project_idea.dart';
import 'package:techsisters/features/practice/presentation/bloc/portfolio_bloc.dart';
import 'package:techsisters/features/practice/presentation/pages/project_editor_page.dart';
import 'package:techsisters/features/practice/presentation/pages/project_idea_page.dart';

/// The Practice tab. "Project ideas" are guided projects to try, and
/// "My portfolio" holds the projects the learner has saved.
class PracticePage extends StatelessWidget {
  const PracticePage({super.key});

  /// Opens the add/edit form. Pushed screens do not see the providers above
  /// this tab, so the portfolio bloc is passed along explicitly.
  void _openEditor(BuildContext context, {PortfolioProject? project}) {
    final bloc = context.read<PortfolioBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: ProjectEditorPage(project: project),
        ),
      ),
    );
  }

  /// Asks before deleting, because it cannot be undone.
  Future<void> _confirmDelete(
    BuildContext context,
    PortfolioProject project,
  ) async {
    final bloc = context.read<PortfolioBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete project?'),
        content: Text(
          '"${project.title}" will be removed from your portfolio.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) bloc.add(DeleteProjectEvent(project.id));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openEditor(context),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          icon: const Icon(Icons.add),
          label: const Text('Add project'),
        ),
        body: BlocListener<PortfolioBloc, PortfolioState>(
          // Show saved, deleted and error messages as a snackbar.
          listenWhen: (p, c) => c.notice != null && c.noticeId != p.noticeId,
          listener: (context, state) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.notice!)));
          },
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.medium,
                  AppSpacing.page,
                  AppSpacing.small,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Practice',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate900,
                        ),
                      ),
                      Text(
                        'Build real projects and keep them in your portfolio',
                        style: TextStyle(color: AppColors.slate600),
                      ),
                    ],
                  ),
                ),
              ),
              const TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.slate600,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: 'Project ideas'),
                  Tab(text: 'My portfolio'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    const _IdeasTab(),
                    _PortfolioTab(
                      onEdit: (project) =>
                          _openEditor(context, project: project),
                      onDelete: (project) => _confirmDelete(context, project),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The list of guided project ideas.
class _IdeasTab extends StatelessWidget {
  const _IdeasTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Extra space at the bottom so the "Add project" button never hides a card.
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.medium,
        AppSpacing.page,
        96,
      ),
      children: [
        for (final idea in ProjectIdeas.all)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              onTap: () {
                final bloc = context.read<PortfolioBloc>();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: bloc,
                      child: ProjectIdeaPage(idea: idea),
                    ),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    idea.category,
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
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    idea.summary,
                    style: const TextStyle(color: AppColors.slate600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${idea.minutes} min  •  ${idea.steps.length} steps',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.slate500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// The learner's saved projects.
class _PortfolioTab extends StatelessWidget {
  final ValueChanged<PortfolioProject> onEdit;
  final ValueChanged<PortfolioProject> onDelete;

  const _PortfolioTab({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioBloc, PortfolioState>(
      builder: (context, state) {
        if (state.status == PortfolioStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == PortfolioStatus.error) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.page),
              child: Text(
                state.errorMessage ?? 'Something went wrong.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (state.projects.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.page),
              child: Text(
                'No projects yet.\nPick an idea or add your own.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.slate600),
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.medium,
            AppSpacing.page,
            96,
          ),
          children: [
            for (final project in state.projects)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProjectCard(
                  project: project,
                  onEdit: () => onEdit(project),
                  onDelete: () => onDelete(project),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// A saved project with an Edit / Delete menu.
class _ProjectCard extends StatelessWidget {
  final PortfolioProject project;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProjectCard({
    required this.project,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onEdit,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate900,
                  ),
                ),
                if (project.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    project.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.slate600),
                  ),
                ],
                if (project.link.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.link,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          project.link,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Project options',
            onSelected: (choice) => choice == 'edit' ? onEdit() : onDelete(),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}
