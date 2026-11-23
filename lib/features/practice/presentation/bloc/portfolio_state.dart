part of 'portfolio_bloc.dart';

enum PortfolioStatus { loading, loaded, error }

class PortfolioState extends Equatable {
  final PortfolioStatus status;
  final List<PortfolioProject> projects;

  /// True while a project is being saved.
  final bool saving;

  /// Goes up by one every time a save succeeds, so the editor knows to close.
  final int savedCount;

  /// One-shot message for a snackbar; [noticeId] makes repeats distinct.
  final String? notice;
  final int noticeId;
  final String? errorMessage;

  const PortfolioState({
    this.status = PortfolioStatus.loading,
    this.projects = const [],
    this.saving = false,
    this.savedCount = 0,
    this.notice,
    this.noticeId = 0,
    this.errorMessage,
  });

  PortfolioState copyWith({
    PortfolioStatus? status,
    List<PortfolioProject>? projects,
    bool? saving,
    int? savedCount,
    String? notice,
    int? noticeId,
    String? errorMessage,
  }) {
    return PortfolioState(
      status: status ?? this.status,
      projects: projects ?? this.projects,
      saving: saving ?? this.saving,
      savedCount: savedCount ?? this.savedCount,
      // The notice is not carried over, so it shows only once.
      notice: notice,
      noticeId: noticeId ?? this.noticeId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    projects,
    saving,
    savedCount,
    notice,
    noticeId,
    errorMessage,
  ];
}
