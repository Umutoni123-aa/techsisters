import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techsisters/core/theme/app_spacing.dart';
import 'package:techsisters/core/theme/app_theme.dart';
import 'package:techsisters/core/widgets/app_card.dart';
import 'package:techsisters/core/widgets/primary_button.dart';
import 'package:techsisters/features/downloads/downloads_module.dart';
import 'package:techsisters/features/downloads/domain/entities/video_key.dart';
import 'package:techsisters/features/downloads/presentation/bloc/video_lesson_bloc.dart';
import 'package:techsisters/features/downloads/presentation/widgets/video_player_view.dart';

/// Plays one lesson video and lets the learner save it for offline use.
class LessonVideoPage extends StatelessWidget {
  final String courseId;
  final String lessonId;
  final String title;
  final String videoUrl;

  /// Author and licence of the video, shown under the player (optional).
  final String? credit;

  /// The "Download on Wi-Fi only" setting from the Settings screen.
  final bool wifiOnly;

  const LessonVideoPage({
    super.key,
    required this.courseId,
    required this.lessonId,
    required this.title,
    required this.videoUrl,
    this.credit,
    required this.wifiOnly,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final module = DownloadsModule();
        return VideoLessonBloc(
          videoKey: VideoKey.of(courseId, lessonId),
          videoUrl: videoUrl,
          getLocalVideo: module.getLocalVideo,
          downloadVideo: module.downloadVideo,
          deleteVideo: module.deleteVideo,
          isOnWifi: module.isOnWifi,
        )..add(const VideoStartedEvent());
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(title)),
        body: SafeArea(
          child: BlocConsumer<VideoLessonBloc, VideoLessonState>(
            // Show "saved", "removed" and error messages as a snackbar.
            listenWhen: (p, c) => c.notice != null && c.noticeId != p.noticeId,
            listener: (context, state) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.notice!)));
            },
            builder: (context, state) {
              // Wait until we know if a saved copy exists, so the player
              // starts from the right source.
              if (state.status == VideoDownloadStatus.checking) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView(
                padding: const EdgeInsets.all(AppSpacing.page),
                children: [
                  VideoPlayerView(url: videoUrl, filePath: state.localPath),
                  if (credit != null && credit!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      credit!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.slate500,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.gap),
                  _DownloadCard(state: state, wifiOnly: wifiOnly),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Shows whether the video is saved, and the matching button.
class _DownloadCard extends StatelessWidget {
  final VideoLessonState state;
  final bool wifiOnly;

  const _DownloadCard({required this.state, required this.wifiOnly});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<VideoLessonBloc>();

    switch (state.status) {
      case VideoDownloadStatus.downloading:
        final percent = (state.progress * 100).round();
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Downloading... $percent%',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate900,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: state.progress,
                  minHeight: 8,
                  color: AppColors.primary,
                  backgroundColor: AppColors.slateBorder,
                ),
              ),
            ],
          ),
        );
      case VideoDownloadStatus.downloaded:
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.emeraldDark),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Saved on this phone. It plays without internet.',
                      style: TextStyle(color: AppColors.slate900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => bloc.add(const DeleteDownloadEvent()),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove download'),
              ),
            ],
          ),
        );
      case VideoDownloadStatus.checking:
      case VideoDownloadStatus.notDownloaded:
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Watch without internet',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                wifiOnly
                    ? 'Downloads only on Wi-Fi (change this in Settings).'
                    : 'Save this video on your phone to use no data later.',
                style: const TextStyle(color: AppColors.slate600),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Download for offline',
                icon: Icons.download,
                onPressed: () =>
                    bloc.add(DownloadPressedEvent(wifiOnly: wifiOnly)),
              ),
            ],
          ),
        );
    }
  }
}
