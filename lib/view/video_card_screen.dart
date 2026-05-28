import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../utils/app_colors.dart';

class VideoCard extends StatefulWidget {
  final String videoUrl;

  const VideoCard({
    super.key,
    required this.videoUrl,
  });

  @override
  State<VideoCard> createState() =>
      _VideoCardState();
}

class _VideoCardState
    extends State<VideoCard> {

  late VideoPlayerController _controller;

  bool isMuted = true;

  @override
  void initState() {
    super.initState();

    _controller =
        VideoPlayerController.networkUrl(
          Uri.parse(
            widget.videoUrl,
          ),
        );

    _initVideo();
  }

  Future<void> _initVideo() async {

    await _controller.initialize();

    await _controller.setLooping(true);

    await _controller.setVolume(0);

    // AUTO PLAY
    await _controller.play();

    if (mounted) {
      setState(() {});
    }
  }

  void _toggleVolume() {

    setState(() {

      isMuted = !isMuted;

      _controller.setVolume(
        isMuted ? 0 : 1,
      );
    });
  }

  void _openFullScreen() {

    Navigator.push(
      context,

      MaterialPageRoute(
        builder:
            (_) => FullScreenVideo(
          controller:
          _controller,
        ),
      ),
    );
  }

  @override
  void dispose() {

    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context) {

    return VisibilityDetector(

      key: Key(
        widget.videoUrl,
      ),

      onVisibilityChanged:
          (info) {

        if (!_controller.value.isInitialized) {
          return;
        }

        if (info.visibleFraction >
            .65) {

          if (!_controller
              .value
              .isPlaying) {

            _controller.play();
          }

        } else {

          if (_controller
              .value
              .isPlaying) {

            _controller.pause();
          }
        }
      },

      child: Stack(
        fit:
        StackFit.expand,

        children: [

          if (_controller
              .value
              .isInitialized)

            SizedBox.expand(
              child:
              FittedBox(
                fit:
                BoxFit.cover,

                child:
                SizedBox(
                  width:
                  _controller
                      .value
                      .size
                      .width,

                  height:
                  _controller
                      .value
                      .size
                      .height,

                  child:
                  VideoPlayer(
                    _controller,
                  ),
                ),
              ),
            )

          else

            const Center(
              child:
              CircularProgressIndicator(
                color:
                AppColors.primaryOrange,
              ),
            ),

          Positioned(
            top: 14,
            left: 14,

            child:
            CircleAvatar(

              backgroundColor:
              Colors.black54,

              child:
              IconButton(
                onPressed:
                _toggleVolume,

                icon:
                Icon(
                  isMuted
                      ? Icons.volume_off
                      : Icons.volume_up,

                  color:
                  Colors.white,

                  size:
                  18,
                ),
              ),
            ),
          ),

          Positioned(
            top: 14,
            right: 14,

            child:
            CircleAvatar(

              backgroundColor:
              Colors.black54,

              child:
              IconButton(
                onPressed:
                _openFullScreen,

                icon:
                const Icon(
                  Icons.open_in_full,

                  color:
                  Colors.white,

                  size:
                  18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// FULL SCREEN

class FullScreenVideo
    extends StatefulWidget {

  final VideoPlayerController controller;

  const FullScreenVideo({
    super.key,
    required this.controller,
  });

  @override
  State<FullScreenVideo>
  createState() =>
      _FullScreenVideoState();
}

class _FullScreenVideoState
    extends State<FullScreenVideo> {

  @override
  void initState() {
    super.initState();

    widget.controller.play();
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      backgroundColor:
      Colors.black,

      body: Center(

        child:
        AspectRatio(

          aspectRatio:
          widget.controller
              .value
              .aspectRatio,

          child:
          VideoPlayer(
            widget.controller,
          ),
        ),
      ),
    );
  }
}