import 'package:techsisters/features/downloads/domain/repositories/video_download_repository.dart';

/// Finds the saved file of a lesson video, if there is one.
class GetLocalVideoUseCase {
  final VideoDownloadRepository repository;
  GetLocalVideoUseCase(this.repository);

  Future<String?> call(String key) => repository.localPath(key);
}

/// Downloads a lesson video, reporting progress as it goes.
class DownloadVideoUseCase {
  final VideoDownloadRepository repository;
  DownloadVideoUseCase(this.repository);

  Stream<double> call({required String key, required String url}) =>
      repository.download(key: key, url: url);
}

/// Removes a downloaded lesson video from the phone.
class DeleteVideoUseCase {
  final VideoDownloadRepository repository;
  DeleteVideoUseCase(this.repository);

  Future<void> call(String key) => repository.delete(key);
}

/// Lists the keys of all downloaded videos.
class ListDownloadedKeysUseCase {
  final VideoDownloadRepository repository;
  ListDownloadedKeysUseCase(this.repository);

  Future<Set<String>> call() => repository.downloadedKeys();
}

/// Tells whether the phone is on Wi-Fi, for the "Download on Wi-Fi only"
/// setting.
class IsOnWifiUseCase {
  final NetworkInfo networkInfo;
  IsOnWifiUseCase(this.networkInfo);

  Future<bool> call() => networkInfo.isOnWifi();
}
