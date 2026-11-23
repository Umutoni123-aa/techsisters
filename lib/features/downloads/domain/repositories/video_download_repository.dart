/// Contract for saving lesson videos on the phone so they work offline.
abstract class VideoDownloadRepository {
  /// The path of the saved file for [key], or null if it is not downloaded.
  Future<String?> localPath(String key);

  /// Downloads [url] and saves it under [key]. Emits the progress from 0.0 to
  /// 1.0 and finishes when the file is saved; emits an error if it fails.
  Stream<double> download({required String key, required String url});

  /// Deletes the saved file for [key].
  Future<void> delete(String key);

  /// The keys of every video saved on the phone.
  Future<Set<String>> downloadedKeys();
}

/// Contract for asking what kind of network the phone is using.
abstract class NetworkInfo {
  /// True when the phone is connected through Wi-Fi (or a cable).
  Future<bool> isOnWifi();
}
