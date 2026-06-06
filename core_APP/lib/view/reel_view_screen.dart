import 'package:core_app/model/reel_model.dart';
import 'package:core_app/view/bottom_view_nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import '../utils/app_colors.dart';
import '../viewModel/reel_viewModel.dart';

class ReelsEarnScreen extends StatefulWidget {
  final bool isVisible;
  final String? initialType;


  const ReelsEarnScreen({super.key, this.isVisible = true, this.initialType});

  @override
  State<ReelsEarnScreen> createState() => _ReelsEarnScreenState();
}

class _ReelsEarnScreenState extends State<ReelsEarnScreen> {
  int _activeTabIndex = 0;
  bool _showOverlay = false;


  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onTabChanged(_activeTabIndex);

      // context.read<ReelsEarnViewModel>().loadFilters();
    });
    super.initState();

    void _triggerOverlay() {
      setState(() => _showOverlay = true);

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _showOverlay = false);
        }
      });
    }

    // 1. Initial Type ke basis par Tab set karein
    if (widget.initialType != null) {
      if (widget.initialType!.toLowerCase() == "study") {
        _activeTabIndex = 1;
      } else if (widget.initialType!.toLowerCase() == "pyq") {
        _activeTabIndex = 2;
      }
    }

    // 2. Data load karein
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onTabChanged(_activeTabIndex);
    });
  }

  void _onTabChanged(int index) {
    setState(() => _activeTabIndex = index);
    final vm = context.read<ReelsEarnViewModel>();
    switch (index) {
      case 0:
        vm.loadReels();
        break;
      case 1:
        vm.loadStudyReels();
        break;
      case 2:
        vm.loadPYQReels();
        break;
    }
  }

  // Horizontal chips sheet constructor utility
  Widget _buildFilterSection(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            itemBuilder: (context, index) {
              bool isFirst = index == 0;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(options[index]),
                  selected: isFirst,
                  onSelected: (val) {},
                  selectedColor: AppColors.primaryOrange.withOpacity(0.2),
                  backgroundColor: AppColors.borderStroke,
                  labelStyle: TextStyle(
                    color: isFirst
                        ? AppColors.primaryOrange
                        : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: isFirst ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isFirst
                          ? AppColors.primaryOrange
                          : AppColors.borderStroke,
                    ),
                  ),
                  showCheckmark: false,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.borderStroke,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Switch context",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Consumer<ReelsEarnViewModel>(
                    builder: (_, vm, __) {
                      return Column(

                        children: [
                          _buildFilterSection(
                            "Exam",
                            vm.filters["Exam"] ?? [],
                          ),

                          _buildFilterSection(
                            "Subject",
                            vm.filters["Subject"] ?? [],
                          ),

                          _buildFilterSection(
                            "Chapter",
                            vm.filters["Chapter"] ?? [],
                          ),

                          _buildFilterSection(
                            "Topic",
                            vm.filters["Topic"] ?? [],
                          ),

                          _buildFilterSection(
                            "Teacher",
                            vm.filters["Teacher"] ?? [],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        foregroundColor: AppColors.pureWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Apply filters",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. VIDEO REELS VIEWPORT CONTAINER ENGINE
          Consumer<ReelsEarnViewModel>(
            builder: (_, vm, _) {
              if (vm.loading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryOrange,
                  ),
                );
              }

              if (vm.reels.isEmpty) {
                return const Center(
                  child: Text(
                    "No videos available",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return PageView.builder(
                key: PageStorageKey(_activeTabIndex),
                scrollDirection: Axis.vertical,
                onPageChanged: (index) {
                  vm.changePage(index);
                },
                itemCount: vm.reels.length,
                itemBuilder: (_, index) => ReelVideoCard(
                  key: ValueKey(vm.reels[index].reelId),
                  reel: vm.reels[index],
                  index: index,
                  isActive: widget.isVisible && index == vm.currentIndex,
                  onLike: () => vm.like(index),
                  onSave: () => vm.saveReel(index),
                  onShare: () => Share.share(vm.reels[index].videoUrl),
                  onDownload: () async {
                    final url = await vm.downloadReel(
                      vm.reels[index].reelId,
                    );

                    if (url != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Download tracked successfully"),
                        ),
                      );

                      debugPrint("DOWNLOAD URL => $url");
                    }
                  },
                ),
              );
            },
          ),

          // 2. TOP HORIZONTAL NAVIGATION COMPONENT OVERLAY (WITH FILTER BUTTON)
          Positioned(
            top: 44,
            left: 4,
            right: 4,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textPrimary,
                    size: 26,
                  ),
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainShellDashboard(),
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      _tabButton("For You", 0),
                      _tabButton("Study", 1),
                      _tabButton("PYQ", 2),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.filter_list_rounded,
                    color: AppColors.textPrimary,
                    size: 26,
                  ),
                  onPressed: () => _showFilterBottomSheet(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String title, int index) {
    bool isSelected = _activeTabIndex == index;
    return GestureDetector(
      onTap: () => _onTabChanged(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: AppColors.primaryOrange, width: 1.5)
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// REEL VIDEO CARD WITH DYNAMIC DATA (Save button connected)

class ReelVideoCard extends StatefulWidget {
  final ReelEarnModel reel;
  final int index;
  final bool isActive;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onDownload;

  const ReelVideoCard({
    super.key,
    required this.reel,
    required this.index,
    required this.isActive,
    required this.onLike,
    required this.onSave,
    required this.onShare,
    required this.onDownload,
  });

  @override
  State<ReelVideoCard> createState() => _ReelsVideoCardState();
}

class _ReelsVideoCardState extends State<ReelVideoCard>
    with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool _isPlaying = true;
  bool _isExpanded = false;
  double _currentSpeed = 1.0;
  bool _showOverlay = false;
  bool _isMuted = false;
  int _lastSavedSecond = 0;

  void _triggerOverlay() {
    setState(() => _showOverlay = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _showOverlay = false);
    });
  }

  void _toggleSpeed() {
    setState(() {
      if (_currentSpeed == 1.0)
        _currentSpeed = 1.5;
      else if (_currentSpeed == 1.5)
        _currentSpeed = 2.0;
      else
        _currentSpeed = 1.0;
      _controller.setPlaybackSpeed(_currentSpeed);
    });
  }

  void _videoListener() {
    if (mounted) setState(() {});
  }
  void _saveProgress() {

    if (!_controller.value.isInitialized) return;

    final watchedSeconds =
        _controller.value.position.inSeconds;

    final durationSeconds =
        _controller.value.duration.inSeconds;

    if (watchedSeconds > 0 &&
        watchedSeconds - _lastSavedSecond >= 15) {

      _lastSavedSecond = watchedSeconds;

      context.read<ReelsEarnViewModel>()
          .saveContinueWatching(
        videoId: widget.reel.reelId,
        watchedSeconds: watchedSeconds,
        durationSeconds: durationSeconds,
      );
    }
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.reel.videoUrl));
    _controller.initialize().then((_) {
      if (!mounted) return;
      _controller.setLooping(true);
      _controller.setVolume(_isMuted ? 0 : 1);
      _controller.addListener(() {
        _videoListener();
        _saveProgress();
      });
      if (widget.isActive) {
        _controller.play();
        _isPlaying = true;

      }
      setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isPlaying && widget.isActive) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  @override
  void didUpdateWidget(covariant ReelVideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_controller.value.isInitialized) return;
    if (widget.isActive) {
      _controller.play();
      _isPlaying = true;
    } else {
      _controller.pause();
      _isPlaying = false;
    }
  }

  @override
  void dispose() {

    if (_controller.value.isInitialized) {

      context.read<ReelsEarnViewModel>()
          .saveContinueWatching(
        videoId: widget.reel.reelId,
        watchedSeconds:
        _controller.value.position.inSeconds,
        durationSeconds:
        _controller.value.duration.inSeconds,
      );
    }

    WidgetsBinding.instance.removeObserver(this);

    _controller.dispose();

    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return "${twoDigits(minutes)}:${twoDigits(seconds)}";
  }

  void _showEpisodeSheet(BuildContext context) {
    _controller.pause();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: 280,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text("All Episodes", style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 90, width: 160,
                            decoration: BoxDecoration(color: AppColors.borderStroke, borderRadius: BorderRadius.circular(12)),
                            child: const Center(child: Icon(Icons.play_circle_fill, color: AppColors.primaryOrange, size: 40)),
                          ),
                          const SizedBox(height: 10),
                          Text("Ep ${index + 1}", style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      if (mounted && _isPlaying && widget.isActive) _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange));
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              if (_controller.value.isPlaying) {
                _controller.pause();
                _isPlaying = false;
              } else {
                _controller.play();
                _isPlaying = true;
              }
            });
            _triggerOverlay();
          },
          child: FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        ),

        // Mute Toggle Icon (Top Right)
        if (_showOverlay)
          Center(
            child: AnimatedOpacity(
              opacity: _showOverlay ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Play/Pause Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Volume Icon
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isMuted = !_isMuted;
                        _controller.setVolume(_isMuted ? 0 : 1);
                      });

                      _triggerOverlay();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isMuted
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        // SIDE BUTTONS
        Positioned(
          right: 12,
          bottom: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // LIKE BUTTON
              Consumer<ReelsEarnViewModel>(
                builder: (context, vm, _) {
                  final reel = vm.reels[widget.index];

                  return Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.favorite_rounded,
                          color: reel.isLiked ? Colors.red : Colors.white,
                          size: 34,
                        ),
                        onPressed: () {
                          final reel = vm.reels[widget.index];

                          if (reel.isLiked) {
                            vm.like(widget.index);
                          } else {
                            vm.unlike(widget.index);
                          }
                        },
                      ),

                      Text(
                        reel.likes >= 1000
                            ? "${(reel.likes / 1000).toStringAsFixed(1)}K"
                            : "${reel.likes}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 18),

              // COMMENT BUTTON
              IconButton(
                icon: const Icon(Icons.comment, color: Colors.white),
                onPressed: () {
                  showCommentSheet(
                    context,
                    widget.reel.reelId,
                    context.read<ReelsEarnViewModel>(),
                  );
                },
              ),
              const Text(
                " ",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),

              // FLOW/EPISODE BUTTON
              GestureDetector(
                onTap: () => _showEpisodeSheet(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryOrange,
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.play_circle_outline_outlined,
                    color: AppColors.textPrimary,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Flow",
                style: TextStyle(
                  color: AppColors.primaryOrange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),


              // DOWNLOAD BUTTON
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.download_rounded,
                  color: AppColors.textPrimary,
                  size: 34,
                ),
                onPressed: widget.onDownload, // Yahan download function call hoga
              ),
              const Text(
                "Download",
                style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
              ),
              const SizedBox(height: 18),


              // SAVE BUTTON (Connected to ViewModel)
              Consumer<ReelsEarnViewModel>(
                builder: (context, vm, _) {
                  final reel = vm.reels[widget.index];

                  return Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          reel.isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: reel.isSaved
                              ? AppColors.primaryOrange
                              : Colors.white,
                          size: 34,
                        ),
                        onPressed: () => vm.saveReel(widget.index),
                      ),

                      const Text(
                        "Save",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),

              // SHARE BUTTON
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.reply_rounded,
                  color: AppColors.textPrimary,
                  size: 34,
                ),
                onPressed: widget.onShare,
              ),
              const Text(
                "Share",
                style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
              ),
            ],
          ),
        ),

        // DESCRIPTION SECTION (DYNAMIC)
        Positioned(
          bottom: 40,
          left: 16,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // TEACHER INFO
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryOrange,
                        width: 1.5,
                      ),
                      image: widget.reel.teacherProfile.isNotEmpty
                          ? DecorationImage(
                        image: NetworkImage(widget.reel.teacherProfile),
                        fit: BoxFit.cover,
                      )
                          : const DecorationImage(
                        image: NetworkImage(
                          "https://images.unsplash.com/photo-1534528741775-53994a69daeb",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.reel.teacherName.isNotEmpty
                                ? widget.reel.teacherName
                                : "Anonymous Teacher",
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            color: AppColors.primaryOrange,
                            size: 15,
                          ),
                        ],
                      ),
                      Text(
                        widget.reel.teacherUsername.isNotEmpty
                            ? "@${widget.reel.teacherUsername}"
                            : "@teacher",
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // TITLE (Dynamic)
              Text(
                widget.reel.title.isNotEmpty
                    ? widget.reel.title
                    : "Educational Content",
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              // DESCRIPTION (Dynamic with expand/collapse)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Text(
                  widget.reel.description.isNotEmpty
                      ? widget.reel.description
                      : "Watch this reel to learn more about the topic.",
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: _isExpanded ? null : 2,
                  overflow: _isExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),
              ),
              if (widget.reel.description.length > 100)
                Text(
                  _isExpanded ? " less" : " ...more",
                  style: const TextStyle(
                    color: AppColors.primaryOrange,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 14),

              // TAGS (Dynamic)
              if (widget.reel.tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.reel.tags.map((tag) {
                    return _buildContentTag("#$tag");
                  }).toList(),
                ),
            ],
          ),
        ),

        // BOTTOM PLAYER CONTROLS
        Positioned(
          bottom: 12,
          left: 16,
          right: 16,
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                      _isPlaying = false;
                    } else {
                      _controller.play();
                      _isPlaying = true;
                    }
                  });
                },
                child: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: AppColors.textPrimary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _formatDuration(_controller.value.position),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbColor: AppColors.primaryOrange,
                    activeTrackColor: AppColors.primaryOrange,
                    inactiveTrackColor: AppColors.borderStroke,
                    trackHeight: 3.0,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6.0,
                    ),
                  ),
                  child: Slider(
                    value: _controller.value.position.inMilliseconds.toDouble(),
                    max: _controller.value.duration.inMilliseconds.toDouble(),
                    onChanged: (val) {
                      _controller.seekTo(Duration(milliseconds: val.toInt()));
                    },
                  ),
                ),
              ),
              Text(
                _formatDuration(_controller.value.duration),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _toggleSpeed,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.borderStroke),
                  ),
                  child: Text(
                    "${_currentSpeed}x",
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentTag(String tagText) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Text(
        tagText,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  void showCommentSheet(BuildContext context, String videoId, ReelsEarnViewModel vm) {
    final TextEditingController controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [

                // ===== HEADER =====
                const Text(
                  "Comments",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),

                const SizedBox(height: 10),

                // ===== COMMENTS LIST =====
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: vm.fetchComments(videoId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final comments = snapshot.data!;

                      if (comments.isEmpty) {
                        return const Center(
                          child: Text(
                            "No comments yet",
                            style: TextStyle(color: Colors.white54),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final c = comments[index];

                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(
                              c["userName"] ?? "User",
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              c["comment"] ?? "",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // ===== INPUT BOX =====
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Write a comment...",
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
              onPressed: () async {
                print("SEND CLICKED");

                if (controller.text.trim().isEmpty) {
                  print("EMPTY COMMENT");
                  return;
                }

                final ok = await vm.commentReel(
                  videoId,
                  controller.text.trim(),
                );

                print("RESULT => $ok");

                if (ok) {
                  controller.clear();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Comment Added"),
                    ),
                  );
                }
              }
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


