import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

/// Saves, finds and deletes lesson video files in the app's private storage.
/// A key such as `course/lesson` is stored as the file `course__lesson.mp4`.
class VideoFileDatasource {
  final Dio dio;

  VideoFileDatasource({Dio? dio}) : dio = dio ?? Dio();

  static const String _separator = '__';
  static const String _extension = '.mp4';

  /// The folder that holds all downloaded videos (created when needed).
  Future<Directory> _videoDirectory() async {
    final base = await getApplicationDocumentsDirectory();
    final directory = Directory('${base.path}/videos');
    if (!await directory.exists()) await directory.create(recursive: true);
    return directory;
  }

  String _fileName(String key) =>
      '${key.replaceAll('/', _separator)}$_extension';

  Future<File> _fileFor(String key) async {
    final directory = await _videoDirectory();
    return File('${directory.path}/${_fileName(key)}');
  }

  Future<String?> localPath(String key) async {
    final file = await _fileFor(key);
    return await file.exists() ? file.path : null;
  }

  /// Downloads to a temporary `.part` file and renames it when complete, so a
  /// half-finished download is never mistaken for a playable video.
  Stream<double> download(String key, String url) {
    final controller = StreamController<double>();

    () async {
      File? partial;
      try {
        final target = await _fileFor(key);
        partial = File('${target.path}.part');
        await dio.download(
          url,
          partial.path,
          onReceiveProgress: (received, total) {
            if (total > 0) controller.add(received / total);
          },
        );
        await partial.rename(target.path);
        controller.add(1.0);
      } catch (error) {
        if (partial != null && await partial.exists()) await partial.delete();
        controller.addError(error);
      } finally {
        await controller.close();
      }
    }();

    return controller.stream;
  }

  Future<void> delete(String key) async {
    final file = await _fileFor(key);
    if (await file.exists()) await file.delete();
  }

  Future<Set<String>> downloadedKeys() async {
    final directory = await _videoDirectory();
    final keys = <String>{};
    await for (final entity in directory.list()) {
      final name = entity.uri.pathSegments.last;
      if (entity is File && name.endsWith(_extension)) {
        final base = name.substring(0, name.length - _extension.length);
        keys.add(base.replaceAll(_separator, '/'));
      }
    }
    return keys;
  }
}
