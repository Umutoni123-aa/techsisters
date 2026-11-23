import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:techsisters/features/downloads/data/datasources/video_file_datasource.dart';
import 'package:techsisters/features/downloads/domain/repositories/video_download_repository.dart';

class VideoDownloadRepositoryImpl implements VideoDownloadRepository {
  final VideoFileDatasource datasource;

  VideoDownloadRepositoryImpl(this.datasource);

  @override
  Future<String?> localPath(String key) => datasource.localPath(key);

  @override
  Stream<double> download({required String key, required String url}) =>
      datasource.download(key, url);

  @override
  Future<void> delete(String key) => datasource.delete(key);

  @override
  Future<Set<String>> downloadedKeys() => datasource.downloadedKeys();
}

/// Asks the phone which networks are connected.
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl({Connectivity? connectivity})
    : connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> isOnWifi() async {
    final results = await connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);
  }
}
