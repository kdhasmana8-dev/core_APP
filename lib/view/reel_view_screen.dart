import 'package:core_app/view/bottom_view_nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import '../utils/app_colors.dart';
import '../viewModel/reel_viewModel.dart';


class ReelsEarnScreen extends StatefulWidget {
  const ReelsEarnScreen({super.key});

  @override
  State<ReelsEarnScreen> createState() => _ReelsEarnScreenState();
}

class _ReelsEarnScreenState extends State<ReelsEarnScreen> {
  int _activeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReelsEarnViewModel>().loadReels();
    });
  }

  // Horizontal chips sheet constructor utility
  Widget _buildFilterSection(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
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
                    color: isFirst ? AppColors.primaryOrange : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: isFirst ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isFirst ? AppColors.primaryOrange : AppColors.borderStroke,
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
                      width: 40, height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.borderStroke,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Switch context",
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 25),
                  _buildFilterSection("Exam", ["JEE (Main+Adv)", "NEET", "Boards"]),
                  _buildFilterSection("Subject", ["All", "Physics", "Chemistry", "Maths"]),
                  _buildFilterSection("Chapter", ["All", "Harmonic Motion", "Kinematics"]),
                  _buildFilterSection("Topic", ["All", "Simple harmonic motion", "Projectile Motion"]),
                  _buildFilterSection("Teacher", ["All", "Lokesh Muwel", "Alakh Sir"]),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        foregroundColor: AppColors.pureWhite,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Apply filters", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            builder: (_, vm, __) {
              if (vm.loading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryOrange),
                );
              }

              return PageView.builder(
                key: PageStorageKey(_activeTabIndex),
                scrollDirection: Axis.vertical,
                onPageChanged: vm.changePage,
                itemCount: vm.reels.length,
                itemBuilder: (_, index) => ReelVideoCard(
                  key: ValueKey(vm.reels[index].videoUrl),

                  video: vm.reels[index].videoUrl,

                  liked: vm.reels[index].isLiked,

                  likes: vm.reels[index].likes,

                  isActive: index == vm.currentIndex,

                  onLike: () => vm.like(index),

                  onShare: () =>
                      Share.share(vm.reels[index].videoUrl),

                  openFilterCallback: () =>
                      _showFilterBottomSheet(context),
                ),

              );
            },
          ),

          // 2. TOP HORIZONTAL NAVIGATION COMPONENT OVERLAY
          Positioned(
            top: 44,
            left: 4,
            right: 4,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 26),
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainShellDashboard()),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _tabButton("For You", 0),
                      _tabButton("Study", 1),
                      _tabButton("PYQ", 2),
                    ],
                  ),
                ),
                // CHANGE 1: Search icon replaced with Filter icon to trigger BottomSheet
                IconButton(
                  icon: const Icon(Icons.filter_list_rounded, color: AppColors.textPrimary, size: 26),
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
          border: isSelected ? Border.all(color: AppColors.primaryOrange, width: 1.5) : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _onTabChanged(int index) {
    setState(() => _activeTabIndex = index);
    final vm = context.read<ReelsEarnViewModel>();
    switch (index) {
      case 0: vm.loadReels(); break;
      case 1: vm.loadStudyReels(); break;
      case 2: vm.loadPYQReels(); break;
    }
  }
}

// PREMIUM REEL VIEW CARD CORE ENGINE WITH INLINE ACTIONS AT BOTTOM DESCRIPTION
class ReelVideoCard extends StatefulWidget {
  final String video;
  final bool liked;
  final int likes;
  final bool isActive;
  final VoidCallback onLike;
  final VoidCallback onShare;
  final VoidCallback openFilterCallback;

  const ReelVideoCard({
    super.key,
    required this.video,
    required this.liked,
    required this.likes,
    required this.isActive,
    required this.onLike,
    required this.onShare,
    required this.openFilterCallback,
  });

  @override
  State<ReelVideoCard> createState() => _ReelsVideoCardState();
}

class _ReelsVideoCardState extends State<ReelVideoCard> with WidgetsBindingObserver {
  late VideoPlayerController c;
  bool _isPlaying = true;
  bool _isExpanded = false;
  double _currentSpeed = 1.0;
  bool _showOverlay = false; // Overlay state

  // Overlay trigger logic
  void _triggerOverlay() {
    setState(() => _showOverlay = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _showOverlay = false);
    });
  }

  void _videoListener() {
    if (mounted) setState(() {});
  }

  void _toggleSpeed() {
    setState(() {
      if (_currentSpeed == 1.0) _currentSpeed = 1.5;
      else if (_currentSpeed == 1.5) _currentSpeed = 2.0;
      else _currentSpeed = 1.0;
      c.setPlaybackSpeed(_currentSpeed);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    c = VideoPlayerController.networkUrl(Uri.parse(widget.video));
    c.initialize().then((_) {
      if (!mounted) return;
      c.setLooping(true);
      c.setVolume(1);
      c.addListener(_videoListener);
      if (widget.isActive) {
        c.play();
        _isPlaying = true;
      }
      setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isPlaying) {
      c.play();
    } else {
      c.pause();
    }
  }

  @override
  void didUpdateWidget(covariant ReelVideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!c.value.isInitialized) return;
    if (widget.isActive) {
      c.play();
      _isPlaying = true;
    } else {
      c.pause();
      _isPlaying = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    c.removeListener(_videoListener);
    c.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  void _showEpisodeSheet(BuildContext context) {
    c.pause();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
      if (mounted && _isPlaying) c.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!c.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange));
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // VIDEO PLAYER LAYER
        GestureDetector(
          onTap: () {
            setState(() {
              if (c.value.isPlaying) {
                c.pause();
                _isPlaying = false;
              } else {
                c.play();
                _isPlaying = true;
              }
            });
            _triggerOverlay(); // Icon trigger
          },
          child: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: c.value.size.width,
                height: c.value.size.height,
                child: VideoPlayer(c),
              ),
            ),
          ),
        ),

        // CENTER OVERLAY ICON
        if (_showOverlay)
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.play_arrow_rounded : Icons.pause_rounded,
                color: Colors.white,
                size: 60,
              ),
            ),
          ),

        // GRADIENT LAYER
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.background.withOpacity(0.5), Colors.transparent, AppColors.background.withOpacity(0.85)],
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
              IconButton(padding: EdgeInsets.zero, icon: Icon(Icons.favorite_rounded, color: widget.liked ? Colors.red : AppColors.textPrimary, size: 34), onPressed: widget.onLike),
              Text(widget.likes >= 1000 ? "${(widget.likes / 1000).toStringAsFixed(1)}K" : "${widget.likes}", style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 18),
              IconButton(padding: EdgeInsets.zero, icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.textPrimary, size: 32), onPressed: () {}),
              const Text("128", style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => _showEpisodeSheet(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primaryOrange, width: 1.5)),
                  child: const Icon(Icons.play_circle_outline_outlined, color: AppColors.textPrimary, size: 28),
                ),
              ),
              const SizedBox(height: 4),
              const Text("Flow", style: TextStyle(color: AppColors.primaryOrange, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 18),
              IconButton(padding: EdgeInsets.zero, icon: const Icon(Icons.bookmark_border_rounded, color: AppColors.textPrimary, size: 34), onPressed: () {}),
              const Text("Save", style: TextStyle(color: AppColors.textPrimary, fontSize: 12)),
              const SizedBox(height: 18),
              IconButton(padding: EdgeInsets.zero, icon: const Icon(Icons.reply_rounded, color: AppColors.textPrimary, size: 34), onPressed: widget.onShare),
              const Text("Share", style: TextStyle(color: AppColors.textPrimary, fontSize: 12)),
            ],
          ),
        ),

        // DESCRIPTION
        Positioned(
          bottom: 40,
          left: 16,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primaryOrange, width: 1.5), image: const DecorationImage(image: NetworkImage("https://images.unsplash.com/photo-1534528741775-53994a69daeb"), fit: BoxFit.cover))),
                  const SizedBox(width: 10),
                  const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Text("Lokesh Muwel", style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)), SizedBox(width: 4), Icon(Icons.verified, color: AppColors.primaryOrange, size: 15)]), Text("@lokesh.muwel", style: TextStyle(color: AppColors.textSecondary, fontSize: 13))]),
                ],
              ),
              const SizedBox(height: 14),
              const Text("IIT-JEE Physics: Kinematics Basics", style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              GestureDetector(onTap: () { setState(() { _isExpanded = !_isExpanded; }); }, child: Text("Understand the foundational concepts of Kinematics with real-life examples and practice.", style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4), maxLines: _isExpanded ? null : 2, overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis)),
              Text(_isExpanded ? " less" : " ...more", style: const TextStyle(color: AppColors.primaryOrange, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              Row(children: [_buildContentTag("#JEE"), _buildContentTag("#Physics"), _buildContentTag("#Kinematics")]),
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
                    if (c.value.isPlaying) {
                      c.pause();
                      _isPlaying = false;
                    } else {
                      c.play();
                      _isPlaying = true;
                    }
                  });
                },
                child: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: AppColors.textPrimary, size: 26),
              ),
              const SizedBox(width: 10),
              Text(_formatDuration(c.value.position), style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(thumbColor: AppColors.primaryOrange, activeTrackColor: AppColors.primaryOrange, inactiveTrackColor: AppColors.borderStroke, trackHeight: 3.0, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0)),
                  child: Slider(value: c.value.position.inMilliseconds.toDouble(), max: c.value.duration.inMilliseconds.toDouble(), onChanged: (val) { c.seekTo(Duration(milliseconds: val.toInt())); }),
                ),
              ),
              Text(_formatDuration(c.value.duration), style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _toggleSpeed,
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.borderStroke)),
                    child: Text("${_currentSpeed}x", style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold))
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
      decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderStroke)),
      child: Text(tagText, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w400)),
    );
  }
}