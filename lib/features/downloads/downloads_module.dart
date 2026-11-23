import 'package:techsisters/features/downloads/data/datasources/video_file_datasource.dart';
import 'package:techsisters/features/downloads/data/repositories/video_download_repository_impl.dart';
import 'package:techsisters/features/downloads/domain/usecases/download_usecases.dart';

/// Builds the use cases of the downloads feature once, so screens can share
/// them.
class DownloadsModule {
  final GetLocalVideoUseCase getLocalVideo;
  final DownloadVideoUseCase downloadVideo;
  final DeleteVideoUseCase deleteVideo;
  final ListDownloadedKeysUseCase listDownloadedKeys;
  final IsOnWifiUseCase isOnWifi;

  DownloadsModule._({
    required this.getLocalVideo,
    required this.downloadVideo,
    required this.deleteVideo,
    required this.listDownloadedKeys,
    required this.isOnWifi,
  });

  factory DownloadsModule() {
    final repository = VideoDownloadRepositoryImpl(VideoFileDatasource());
    return DownloadsModule._(
      getLocalVideo: GetLocalVideoUseCase(repository),
      downloadVideo: DownloadVideoUseCase(repository),
      deleteVideo: DeleteVideoUseCase(repository),
      listDownloadedKeys: ListDownloadedKeysUseCase(repository),
      isOnWifi: IsOnWifiUseCase(NetworkInfoImpl()),
    );
  }
}
