part of 'video_lesson_bloc.dart';

enum VideoDownloadStatus {
  /// Looking for a saved copy.
  checking,

  /// Not on the phone; it would be streamed.
  notDownloaded,

  /// Being saved right now.
  downloading,

  /// Saved on the phone and playable offline.
  downloaded,
}

class VideoLessonState extends Equatable {
  final VideoDownloadStatus status;

  /// Download progress from 0.0 to 1.0, while [status] is downloading.
  final double progress;

  /// The saved file, when [status] is downloaded.
  final String? localPath;

  /// One-shot message for a snackbar; [noticeId] makes repeats distinct.
  final String? notice;
  final int noticeId;

  const VideoLessonState({
    this.status = VideoDownloadStatus.checking,
    this.progress = 0,
    this.localPath,
    this.notice,
    this.noticeId = 0,
  });

  VideoLessonState copyWith({
    VideoDownloadStatus? status,
    double? progress,
    String? localPath,
    bool clearLocalPath = false,
    String? notice,
    int? noticeId,
  }) {
    return VideoLessonState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      localPath: clearLocalPath ? null : (localPath ?? this.localPath),
      // The notice is not carried over, so it shows only once.
      notice: notice,
      noticeId: noticeId ?? this.noticeId,
    );
  }

  @override
  List<Object?> get props => [status, progress, localPath, notice, noticeId];
}
