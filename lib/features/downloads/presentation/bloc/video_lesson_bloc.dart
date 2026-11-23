import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techsisters/features/downloads/domain/usecases/download_usecases.dart';

part 'video_lesson_event.dart';
part 'video_lesson_state.dart';

/// Tracks whether one lesson video is saved on the phone, and handles
/// downloading it and removing it.
class VideoLessonBloc extends Bloc<VideoLessonEvent, VideoLessonState> {
  /// Identifies the video on the phone, see `VideoKey`.
  final String videoKey;
  final String videoUrl;
  final GetLocalVideoUseCase getLocalVideo;
  final DownloadVideoUseCase downloadVideo;
  final DeleteVideoUseCase deleteVideo;
  final IsOnWifiUseCase isOnWifi;

  VideoLessonBloc({
    required this.videoKey,
    required this.videoUrl,
    required this.getLocalVideo,
    required this.downloadVideo,
    required this.deleteVideo,
    required this.isOnWifi,
  }) : super(const VideoLessonState()) {
    on<VideoStartedEvent>(_onStarted);
    on<DownloadPressedEvent>(_onDownload);
    on<DeleteDownloadEvent>(_onDelete);
  }

  Future<void> _onStarted(
    VideoStartedEvent event,
    Emitter<VideoLessonState> emit,
  ) async {
    final path = await getLocalVideo(videoKey);
    emit(
      path == null
          ? state.copyWith(
              status: VideoDownloadStatus.notDownloaded,
              clearLocalPath: true,
            )
          : state.copyWith(
              status: VideoDownloadStatus.downloaded,
              localPath: path,
            ),
    );
  }

  Future<void> _onDownload(
    DownloadPressedEvent event,
    Emitter<VideoLessonState> emit,
  ) async {
    if (state.status == VideoDownloadStatus.downloading) return;

    // Respect the "Download on Wi-Fi only" setting.
    if (event.wifiOnly && !await isOnWifi()) {
      emit(
        state.copyWith(
          notice:
              'Connect to Wi-Fi to download, or turn off "Download on Wi-Fi '
              'only" in Settings.',
          noticeId: state.noticeId + 1,
        ),
      );
      return;
    }

    emit(state.copyWith(status: VideoDownloadStatus.downloading, progress: 0));

    await emit.forEach<double>(
      downloadVideo(key: videoKey, url: videoUrl),
      onData: (progress) => state.copyWith(
        status: VideoDownloadStatus.downloading,
        progress: progress,
      ),
      onError: (error, _) => state.copyWith(
        status: VideoDownloadStatus.notDownloaded,
        progress: 0,
        notice: 'Download failed. Check your connection and try again.',
        noticeId: state.noticeId + 1,
      ),
    );

    // If the download failed, the error handler above already updated the
    // state, so there is nothing more to do.
    if (state.status != VideoDownloadStatus.downloading) return;

    final path = await getLocalVideo(videoKey);
    emit(
      path == null
          ? state.copyWith(status: VideoDownloadStatus.notDownloaded)
          : state.copyWith(
              status: VideoDownloadStatus.downloaded,
              localPath: path,
              notice: 'Saved. You can watch this video offline.',
              noticeId: state.noticeId + 1,
            ),
    );
  }

  Future<void> _onDelete(
    DeleteDownloadEvent event,
    Emitter<VideoLessonState> emit,
  ) async {
    await deleteVideo(videoKey);
    emit(
      state.copyWith(
        status: VideoDownloadStatus.notDownloaded,
        progress: 0,
        clearLocalPath: true,
        notice: 'Download removed',
        noticeId: state.noticeId + 1,
      ),
    );
  }
}
