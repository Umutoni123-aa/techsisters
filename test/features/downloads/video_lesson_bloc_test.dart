import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:techsisters/features/downloads/domain/entities/video_key.dart';
import 'package:techsisters/features/downloads/domain/repositories/video_download_repository.dart';
import 'package:techsisters/features/downloads/domain/usecases/download_usecases.dart';
import 'package:techsisters/features/downloads/presentation/bloc/video_lesson_bloc.dart';

class MockVideoRepository extends Mock implements VideoDownloadRepository {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  const key = 'course-1/lesson-1';
  const url = 'https://example.com/lesson.mp4';

  late MockVideoRepository repository;
  late MockNetworkInfo network;
  late VideoLessonBloc bloc;

  setUp(() {
    repository = MockVideoRepository();
    network = MockNetworkInfo();
    when(() => network.isOnWifi()).thenAnswer((_) async => true);
    when(() => repository.localPath(key)).thenAnswer((_) async => null);
    when(() => repository.delete(key)).thenAnswer((_) async {});

    bloc = VideoLessonBloc(
      videoKey: key,
      videoUrl: url,
      getLocalVideo: GetLocalVideoUseCase(repository),
      downloadVideo: DownloadVideoUseCase(repository),
      deleteVideo: DeleteVideoUseCase(repository),
      isOnWifi: IsOnWifiUseCase(network),
    );
  });

  tearDown(() => bloc.close());

  Future<void> send(VideoLessonEvent event) async {
    bloc.add(event);
    await pumpEventQueue();
  }

  group('VideoKey', () {
    test('joins and splits the course and lesson ids', () {
      expect(VideoKey.of('c1', 'l1'), 'c1/l1');
      expect(VideoKey.courseIdOf('c1/l1'), 'c1');
    });
  });

  group('VideoLessonBloc', () {
    test('starts as not downloaded when no file is saved', () async {
      await send(const VideoStartedEvent());
      expect(bloc.state.status, VideoDownloadStatus.notDownloaded);
    });

    test('starts as downloaded when a file is already saved', () async {
      when(() => repository.localPath(key)).thenAnswer((_) async => '/v.mp4');
      await send(const VideoStartedEvent());

      expect(bloc.state.status, VideoDownloadStatus.downloaded);
      expect(bloc.state.localPath, '/v.mp4');
    });

    test('Wi-Fi only blocks a download on mobile data', () async {
      when(() => network.isOnWifi()).thenAnswer((_) async => false);

      await send(const DownloadPressedEvent(wifiOnly: true));

      expect(bloc.state.status, isNot(VideoDownloadStatus.downloading));
      expect(bloc.state.notice, contains('Wi-Fi'));
      verifyNever(
        () => repository.download(
          key: any(named: 'key'),
          url: any(named: 'url'),
        ),
      );
    });

    test('a download reports progress, then becomes downloaded', () async {
      final progress = StreamController<double>();
      when(() => repository.download(key: key, url: url))
          .thenAnswer((_) => progress.stream);

      await send(const DownloadPressedEvent(wifiOnly: true));
      expect(bloc.state.status, VideoDownloadStatus.downloading);

      progress.add(0.5);
      await pumpEventQueue();
      expect(bloc.state.progress, 0.5);

      // The file now exists, and the stream finishes.
      when(() => repository.localPath(key)).thenAnswer((_) async => '/v.mp4');
      await progress.close();
      await pumpEventQueue();

      expect(bloc.state.status, VideoDownloadStatus.downloaded);
      expect(bloc.state.localPath, '/v.mp4');
    });

    test(
      'a failed download returns to not downloaded with a message',
      () async {
        final progress = StreamController<double>();
        when(() => repository.download(key: key, url: url))
            .thenAnswer((_) => progress.stream);

        await send(const DownloadPressedEvent(wifiOnly: false));
        progress.addError(Exception('lost connection'));
        await progress.close();
        await pumpEventQueue();

        expect(bloc.state.status, VideoDownloadStatus.notDownloaded);
        expect(bloc.state.notice, contains('failed'));
      },
    );

    test('removing a download deletes the file', () async {
      when(() => repository.localPath(key)).thenAnswer((_) async => '/v.mp4');
      await send(const VideoStartedEvent());

      await send(const DeleteDownloadEvent());

      expect(bloc.state.status, VideoDownloadStatus.notDownloaded);
      expect(bloc.state.localPath, isNull);
      verify(() => repository.delete(key)).called(1);
    });
  });
}
