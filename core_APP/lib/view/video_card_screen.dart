import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../utils/app_colors.dart';

class TopVideoModel {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  final int duration;
  final String teacherName;
  final String topicName;
  final int likes;
  final int views;

  TopVideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.duration,
    required this.teacherName,
    required this.topicName,
    required this.likes,
    required this.views,
  });

  factory TopVideoModel.fromJson(Map<String, dynamic> json) {
    return TopVideoModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      duration: json['duration'] ?? 0,

      teacherName: json['teacher_id']?['teacherName'] ?? '',
      topicName: json['topic_id']?['name'] ?? '',

      likes: json['stats']?['likes'] ?? 0,
      views: json['stats']?['views'] ?? 0,
    );
  }
}
//Top Videos Section-----------------

class TopVideosSection extends StatefulWidget {
  const TopVideosSection({super.key});

  @override
  State<TopVideosSection> createState() => _TopVideosSectionState();
}

class _TopVideosSectionState extends State<TopVideosSection> {
  final PageController _pageController =
  PageController(viewportFraction: 0.9);

  List<TopVideoModel> _videos = [];
  bool _isLoading = true;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    fetchTopVideos();
  }

  Future<void> fetchTopVideos() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://core-backend-38rr.onrender.com/api/reels/top/videos'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final List list = data['reels'] ?? [];

        setState(() {
          _videos =
              list.map((e) => TopVideoModel.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 450,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_videos.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("No videos found")),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 450,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _videos.length,
            onPageChanged: (index) =>
                setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final video = _videos[index];

              return Container(
                margin:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.borderStroke),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      VideoCard(videoUrl: video.videoUrl),

                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              video.topicName,
                              style: const TextStyle(
                                  color: Colors.white70),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "👨‍🏫 ${video.teacherName}",
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "❤️ ${video.likes}   👁 ${video.views}",
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _videos.length,
                (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 18 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppColors.primaryOrange
                    : Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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
        builder: (context) => FullScreenVideo(
          videoUrl: widget.videoUrl,
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
class FullScreenVideo extends StatefulWidget {
  final String videoUrl;

  const FullScreenVideo({
    super.key,
    required this.videoUrl,
  });

  @override
  State<FullScreenVideo> createState() => _FullScreenVideoState();
}

class _FullScreenVideoState extends State<FullScreenVideo> {
  late VideoPlayerController _controller;

  bool _isInitialized = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.setVolume(1);
      await _controller.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("FULLSCREEN VIDEO ERROR: $e");
    }
  }

  void _toggleVolume() {
    if (!_isInitialized) return;

    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0 : 1);
    });
  }

  void _togglePlayPause() {
    if (!_isInitialized) return;

    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: !_isInitialized
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : Stack(
          children: [
            Center(
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),

            Positioned(
              top: 15,
              left: 15,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 15,
              right: 15,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _toggleVolume,
                  icon: Icon(
                    _isMuted
                        ? Icons.volume_off
                        : Icons.volume_up,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            if (!_controller.value.isPlaying)
              const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 80,
                ),
              ),
          ],
        ),
      ),
    );
  }
}