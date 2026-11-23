import 'dart:io';

import 'package:flutter/material.dart';
import 'package:techsisters/core/theme/app_theme.dart';
import 'package:video_player/video_player.dart';

/// Plays a video from a saved file when [filePath] is given, and streams it
/// from [url] otherwise. The controller is created once when the widget
/// first appears; changing the source later does not restart the video.
class VideoPlayerView extends StatefulWidget {
  final String url;
  final String? filePath;

  const VideoPlayerView({super.key, required this.url, this.filePath});

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

/// Holds the video controller and its setup. The play button and progress
/// bar listen to the controller, so no setState is needed.
class _VideoPlayerViewState extends State<VideoPlayerView> {
  late final VideoPlayerController _controller;
  late final Future<void> _initialized;

  @override
  void initState() {
    super.initState();
    final path = widget.filePath;
    _controller = path != null
        ? VideoPlayerController.file(File(path))
        : VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _initialized = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialized,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _PlayerMessage(
            icon: Icons.wifi_off,
            text:
                "The video can't load. Connect to the internet, or download "
                'it first to watch offline.',
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const AspectRatio(
            aspectRatio: 16 / 9,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
            const SizedBox(height: 8),
            VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: AppColors.primary,
                bufferedColor: AppColors.soft,
                backgroundColor: AppColors.slateBorder,
              ),
            ),
            // Rebuilds only this button when playback starts or stops.
            ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: _controller,
              builder: (context, value, _) {
                return IconButton(
                  iconSize: 40,
                  color: AppColors.primary,
                  tooltip: value.isPlaying ? 'Pause' : 'Play',
                  icon: Icon(
                    value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                  ),
                  onPressed: () => value.isPlaying
                      ? _controller.pause()
                      : _controller.play(),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

/// A short message shown in place of the player when it cannot start.
class _PlayerMessage extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PlayerMessage({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slateBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.slate500, size: 32),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.slate600),
            ),
          ],
        ),
      ),
    );
  }
}
