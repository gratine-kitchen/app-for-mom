import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../models/video.dart';

/// Fullscreen YouTube video player.
///
/// Plays the video with autoplay enabled and the standard YouTube controls.
/// The video fills the available space below the app bar.
class VideoPlayerScreen extends StatefulWidget {
  final Video video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.video.youtubeId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        disableDragSeek: false,
        loop: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.video.title),
      ),
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: theme.colorScheme.primary,
          progressColors: ProgressBarColors(
            playedColor: theme.colorScheme.primary,
            handleColor: theme.colorScheme.primary,
          ),
        ),
        builder: (context, player) {
          return Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: player,
              ),
              Expanded(
                child: Container(color: Colors.black),
              ),
            ],
          );
        },
      ),
    );
  }
}
