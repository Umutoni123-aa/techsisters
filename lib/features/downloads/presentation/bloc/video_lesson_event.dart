part of 'video_lesson_bloc.dart';

abstract class VideoLessonEvent extends Equatable {
  const VideoLessonEvent();

  @override
  List<Object?> get props => [];
}

/// Look for a saved copy of the video when the screen opens.
class VideoStartedEvent extends VideoLessonEvent {
  const VideoStartedEvent();
}

/// The learner pressed "Download". [wifiOnly] comes from the Settings screen.
class DownloadPressedEvent extends VideoLessonEvent {
  final bool wifiOnly;
  const DownloadPressedEvent({required this.wifiOnly});

  @override
  List<Object?> get props => [wifiOnly];
}

/// The learner pressed "Remove download".
class DeleteDownloadEvent extends VideoLessonEvent {
  const DeleteDownloadEvent();
}
