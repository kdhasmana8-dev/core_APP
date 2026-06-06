import 'package:core_app/view/performance_view_screen.dart';
import 'package:core_app/view/reel_view_screen.dart';
import 'package:core_app/view/subject_details_view_screen.dart';
import 'package:core_app/view/teacher_view_screen.dart';
import 'package:core_app/view/test_details_screen.dart';
import 'package:core_app/view/video_card_screen.dart';
import 'package:core_app/viewModel/continue_watching_viewmodel.dart';
import 'package:core_app/view_all_screen.dart' hide Topic;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_screen.dart';
import '../model/drawer_model.dart';
import '../model/new_arrival_model.dart';
import '../model/subject_model.dart' hide Topic;
import '../model/teacher_model.dart';
import '../utils/app_colors.dart';
import '../viewModel/newarrival_viewModel.dart';
import '../viewModel/pyq_viewModel.dart';
import '../viewModel/subject_viewModel.dart';
import '../viewModel/teacher_viewModel.dart';
import 'course_list_view.dart';
import 'drawer_screen.dart';

class HomeScreen extends StatefulWidget {
  final String examId;
  final String TestId;

  const HomeScreen({
    super.key,
    required this.examId,
    required this.TestId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  int selectedCategory = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final categories = [
    "All",
    "JEE (Main+Adv)",
  ];

  Future<void> _onRefresh() async {
    try {
      await Provider.of<ContinueWatchingViewModel>(
        context,
        listen: false,
      ).fetchContinueWatching();

      await Provider.of<ContinueWatchingViewModel>(
        context,
        listen: false,
      ).fetchUpcomingTests();
    } catch (_) {}

    await Provider.of<SubjectViewModel>(
      context,
      listen: false,
    ).fetchSubjects();

    await Provider.of<NewArrivalViewModel>(
      context,
      listen: false,
    ).fetchNewArrivals();

    await Provider.of<TeacherViewModel>(
      context,
      listen: false,
    ).fetchTeachers();

    await Provider.of<PYQViewModel>(
      context,
      listen: false,
    ).fetchPYQs();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final continueWatchingViewModel = Provider.of<ContinueWatchingViewModel>(context, listen: false);
        continueWatchingViewModel.fetchContinueWatching();
        continueWatchingViewModel.fetchUpcomingTests();
      } catch (e) {
        debugPrint('ContinueWatchingViewModel not found: $e');
      }
      final subjectViewModel = Provider.of<SubjectViewModel>(context, listen: false);
      subjectViewModel.fetchSubjects();

      final newArrivalViewModel = Provider.of<NewArrivalViewModel>(context, listen: false);
      newArrivalViewModel.fetchNewArrivals();

      final teacherViewModel = Provider.of<TeacherViewModel>(context, listen: false);
      teacherViewModel.fetchTeachers();

      final pyqViewModel = Provider.of<PYQViewModel>(context, listen: false);
      pyqViewModel.fetchPYQs();

      // Add try-catch for continue watching
      try {
        final continueWatchingViewModel = Provider.of<ContinueWatchingViewModel>(context, listen: false);
        continueWatchingViewModel.fetchContinueWatching();
      } catch (e) {
        debugPrint('ContinueWatchingViewModel not found: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,

      drawer: _buildDrawer(context),

        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: RefreshIndicator(
              color: AppColors.primaryOrange,
              backgroundColor: AppColors.cardSurface,
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                _buildGreeting(),
                const SizedBox(height: 12),
                _buildSearchBar(),
                const SizedBox(height: 12),
                _buildFilters(),
                const SizedBox(height: 12),
                TopVideosSection(),
                const SizedBox(height: 12),

                // CONTINUE WATCHING SECTION - With error handling
                _buildContinueWatchingSection(),

                // TOP SUBJECTS SECTION
                Consumer<SubjectViewModel>(
                  builder: (context, vm, child) {

                    if (vm.isLoading) {
                      return const CircularProgressIndicator();
                    }

                    if (vm.subjects.isEmpty) {
                      return const SizedBox();
                    }

                    return Column(
                      children: [
                        _buildSectionHeader(
                          "Top Subjects",
                        ),

                        const SizedBox(height: 18),

                        _buildTopSubjects(
                          vm.subjects,
                        ),

                        const SizedBox(height: 22),
                      ],
                    );
                  },
                ),
                Consumer<TeacherViewModel>(
                  builder: (context, teacherViewModel, child) {
                    if (teacherViewModel.isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (teacherViewModel.teachers.isNotEmpty) {
                      return Column(
                        children: [
                          _buildSectionHeader("Top Educators", onViewAll: () {
                          }),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              scrollDirection: Axis.horizontal,
                              itemCount: teacherViewModel.teachers.length,
                              itemBuilder: (context, index) {
                                final teacher = teacherViewModel.teachers[index];
                                return _teacherCard(teacher);
                              },
                            ),
                          ),
                          const SizedBox(height: 22),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                _buildPracticeSection(),
                const SizedBox(height: 22),

                _buildPromotionalBanner(),
                const SizedBox(height: 15),

                Consumer<PYQViewModel>(
                  builder: (context, pyqViewModel, child) {
                    if (pyqViewModel.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (pyqViewModel.pyqs.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      children: [
                        _buildSectionHeader(
                          "PYQ Series",
                          onViewAll: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewAllScreen(
                                  title: "PYQ Series",
                                  topics: pyqViewModel.pyqs.map((pyq) {
                                    return Topic(
                                      title: pyq.title,
                                      duration: "${(pyq.duration / 60).ceil()} min",
                                      educator: pyq.teacherName,
                                      videoUrl: pyq.videoUrl,
                                      thumbnailUrl: pyq.thumbnailUrl.isNotEmpty
                                          ? pyq.thumbnailUrl
                                          : "https://picsum.photos/300/400",
                                    );
                                  }).toList(),
                                  onTopicTap: (topic) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ReelsEarnScreen(
                                          isVisible: true,
                                          initialType: "PYQ",
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          height: 230,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: pyqViewModel.pyqs.length,
                            itemBuilder: (context, index) {
                              final pyq = pyqViewModel.pyqs[index];

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ReelsEarnScreen(
                                        isVisible: true,
                                        initialType: "PYQ",
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 170,
                                  margin: const EdgeInsets.only(right: 15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(
                                          pyq.thumbnailUrl.isNotEmpty
                                              ? pyq.thumbnailUrl
                                              : "https://picsum.photos/300/400",
                                          height: 150,
                                          width: 170,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) {
                                            return Container(
                                              height: 150,
                                              width: 170,
                                              color: Colors.grey.shade200,
                                              child: const Icon(Icons.image),
                                            );
                                          },
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      Text(
                                        pyq.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        pyq.topicName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),

                                      const SizedBox(height: 2),

                                      Text(
                                        "${pyq.pyqYear} • ${pyq.teacherName}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 18),
                      ],
                    );
                  },
                ),
                // SUBJECT SECTIONS FROM API
                Consumer<SubjectViewModel>(
                  builder: (context, subjectViewModel, child) {

                    if (subjectViewModel.isLoading &&
                        subjectViewModel.subjects.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (subjectViewModel.errorMessage != null) {
                      return Center(
                        child: Column(
                          children: [
                            Text(
                              'Error: ${subjectViewModel.errorMessage}',
                              style: const TextStyle(
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                subjectViewModel.fetchSubjects(

                                );
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (subjectViewModel.subjects.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                        _buildSectionHeader(
                          "All Subjects",
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          height: 245,
                          child: ListView.builder(
                            scrollDirection:
                            Axis.horizontal,
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            itemCount:
                            subjectViewModel.subjects.length,
                            itemBuilder:
                                (context, index) {

                              final subject =
                              subjectViewModel.subjects[index];

                              return _buildSubjectItemCard(
                                subject,
                                "All Subjects",
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 44),

                Consumer<NewArrivalViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.isLoading) {
                      return const SizedBox(
                        height: 220,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (viewModel.errorMessage != null &&
                        viewModel.newArrivals.isEmpty) {
                      return SizedBox(
                        height: 220,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                viewModel.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: viewModel.fetchNewArrivals,
                                child: const Text("Retry"),
                              )
                            ],
                          ),
                        ),
                      );
                    }

                    if (viewModel.newArrivals.isEmpty) {
                      return const SizedBox(
                        height: 100,
                        child: Center(child: Text("No new arrivals")),
                      );
                    }

                    /// 👇 ONLY CALLING WIDGET FUNCTION HERE
                    return _buildNewArrivals(viewModel.newArrivals);
                  },
                ),
                const SizedBox(height: 10),
                _buildUpcomingTests(),
                const SizedBox(height: 24),

                PerformanceOverviewCard(testId: widget.TestId),
              ],
            ),
          ),
        ),
      ),
        ),
    );
  }

  Widget _buildContinueWatchingSection() {
    // Try to get the provider safely
    try {
      return Consumer<ContinueWatchingViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.continueWatching.isEmpty) {
            return const SizedBox.shrink();
          }

          if (viewModel.continueWatching.isNotEmpty) {
            return Column(
              children: [
                _buildSectionHeader("Continue Watching", onViewAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewAllScreen(
                        title: "Continue Watching",
                        topics: viewModel.continueWatching.map((item) => Topic(
                          title: item.title,
                          duration: item.progress,
                          educator: item.educator,
                          videoUrl: item.videoUrl,
                          thumbnailUrl: item.thumbnailUrl.isNotEmpty ? item.thumbnailUrl : "https://picsum.photos/300/400",
                        )).toList(),
                        onTopicTap: (topic) {
                          _navigateToVideoPlayerWithProgress(
                            topic.videoUrl,
                            topic.title,
                            viewModel.continueWatching.firstWhere(
                                  (item) => item.title == topic.title,
                              orElse: () => viewModel.continueWatching.first,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: viewModel.continueWatching.length,
                    itemBuilder: (context, index) {
                      final item = viewModel.continueWatching[index];
                      return _buildContinueWatchingCard(item);
                    },
                  ),
                ),
                const SizedBox(height: 22),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      );
    } catch (e) {
      // Provider not registered yet
      debugPrint('ContinueWatchingSection error: $e');
      return const SizedBox.shrink();
    }
  }

  Widget _buildContinueWatchingCard(ContinueWatchingItem item) {
    double progress = item.durationSeconds > 0
        ? item.watchedSeconds / item.durationSeconds
        : 0.0;

    return GestureDetector(
      onTap: () {
        _navigateToVideoPlayerWithProgress(item.videoUrl, item.title, item);
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderStroke),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      item.thumbnailUrl.isNotEmpty ? item.thumbnailUrl : "https://picsum.photos/300/400",
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: Icon(Icons.play_circle_filled, color: Colors.white54, size: 40),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.black54,
                      color: AppColors.primaryOrange,
                      minHeight: 3,
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.educator,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Resume from ${item.progress}",
                    style: const TextStyle(
                      color: AppColors.primaryOrange,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: Column(
        children: [

          // USER INFO
          Consumer<AuthViewModel>(
            builder: (context, authVm, _) {

              return UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                ),

                accountName: Text(
                  authVm.userName ?? "Student",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                accountEmail: Text(
                  authVm.userEmail ?? "",
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),

                currentAccountPicture: CircleAvatar(
                  backgroundColor: AppColors.primaryOrange.withOpacity(.2),

                  backgroundImage: NetworkImage(
                    authVm.profileUrl != null &&
                        authVm.profileUrl!.isNotEmpty
                        ? authVm.profileUrl!
                        : "https://i.pravatar.cc/150",
                  ),
                ),
              );
            },
          ),

          // DRAWER ITEMS
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [

                _buildDrawerItem(
                  Icons.home_rounded,
                  "Bookmarks",
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BookmarksScreen(),
                      ),
                    );
                  },
                ),

                _buildDrawerItem(
                  Icons.library_books_rounded,
                  "My Courses",
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CourseListView(),
                      ),
                    );
                  },
                ),

                _buildDrawerItem(
                  Icons.book,
                  "Mock Test",
                      () {
                    Navigator.pop(context);
                  },
                ),

                _buildDrawerItem(
                  Icons.bookmark_rounded,
                  "Saved Reels",
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SavedReelsScreen(),
                      ),
                    );
                  },
                ),

                _buildDrawerItem(
                  Icons.download_rounded,
                  "Downloads",
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DownloadsScreen(),
                      ),
                    );
                  },
                ),

                _buildDrawerItem(
                  Icons.analytics_rounded,
                  "Privacy Policy",
                      () {
                    Navigator.push(context,MaterialPageRoute(builder: (context)=>PrivacyPolicyScreen()));
                  },
                ),

                const Divider(
                  color: AppColors.borderStroke,
                ),

                _buildDrawerItem(
                  Icons.analytics_rounded,
                  "Terms and Conditions",
                      () {
                    Navigator.push(context,MaterialPageRoute(builder: (context)=>TermsConditionsScreen( )));
                  },
                ),

                const Divider(
                  color: AppColors.borderStroke,
                ),

                _buildDrawerItem(
                  Icons.card_giftcard,
                  "Refer & Earn",
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReferEarnScreen(),
                      ),
                    );
                  },
                ),

                _buildDrawerItem(
                  Icons.logout_rounded,
                  "Logout",
                      () {
                    Navigator.pop(context);
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.cardSurface,
              border: Border.all(color: AppColors.borderStroke),
            ),
            child: Image.asset("assets/images/logo5.png"),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          "CORE",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 5,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    return Consumer<AuthViewModel>(
      builder: (context, authVm, child) {

        String displayName = "Student";

        if (authVm.userName != null &&
            authVm.userName!.trim().isNotEmpty) {

          displayName = authVm.userName!.split(' ').first;
        }

        return RichText(
          text: TextSpan(
            children: [

              const TextSpan(
                text: "Hello, ",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),

              TextSpan(
                text: "$displayName 👋",
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: const TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.white70),
          hintText: "Search topic, series, PYQ...",
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool selected = selectedCategory == index;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryOrange : AppColors.cardSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: selected ? AppColors.primaryOrange : AppColors.borderStroke),
              ),
              child: Text(
                categories[index],
                style: TextStyle(
                  color: selected ? Colors.black : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: const Text(
                "View all",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
  Widget _buildTopSubjects(
      List<SubjectItem> subjects,
      ) {
    final displaySubjects =
    subjects.take(6).toList();

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        itemCount: displaySubjects.length,
        itemBuilder: (context, index) {

          final subject =
          displaySubjects[index];

          return _buildSubjectCard(
            subject,
          );
        },
      ),
    );
  }

  Widget _buildSubjectCard(SubjectItem subject) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubjectDetailsScreen(
              subjectName: subject.name,
              subjectItem: subject,
            ),
          ),
        );
      },
      child: Container(
        width: 85,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderStroke),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            subject.icon.isNotEmpty
                ? Image.network(
              subject.icon,
              width: 32,
              height: 32,
              errorBuilder: (_, _, _) => Icon(_getIconForSubject(subject.name), color: Colors.white, size: 32),
            )
                : Icon(_getIconForSubject(subject.name), color: Colors.white, size: 32),
            const SizedBox(height: 14),
            Text(
              subject.name.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w600),
            ),
            Text(
              subject.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 8),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForSubject(String title) {
    switch (title.toLowerCase()) {
      case 'physics': return Icons.science_outlined;
      case 'chemistry': return Icons.biotech_outlined;
      case 'mathematics': return Icons.grid_view_rounded;
      case 'biology': return Icons.delivery_dining;
      default: return Icons.book_outlined;
    }
  }

  Widget _teacherCard(Teacher teacher) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeacherProfileScreen(teacher: teacher),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: NetworkImage(teacher.imageUrl),
            ),
            const SizedBox(height: 8),
            Text(
              teacher.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("PRACTICE & IMPROVE"),
        const SizedBox(height: 18),
        SizedBox(
          height: 100,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            children: [
              _practiceCard(icon: Icons.quiz, title: "MCQ Quiz", value: "120+"),
              _practiceCard(icon: Icons.assignment, title: "Mock Test", value: "45"),
              _practiceCard(icon: Icons.trending_up, title: "Rank Boost", value: "85%"),
              _practiceCard(icon: Icons.emoji_events, title: "Challenges", value: "24"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _practiceCard({required IconData icon, required String title, required String value}) {
    return Container(
      width: 105,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryOrange, size: 28),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildPromotionalBanner() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: AppColors.accentGradient,
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("MASTER CONCEPTS.", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("ACHIEVE MORE.", style: TextStyle(color: AppColors.primaryOrange, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("Learn. Practice. Rank Higher.", style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const Icon(Icons.science, color: AppColors.primaryOrange, size: 90),
          ],
        ),
      ),
    );
  }

  Widget _buildApiSubjectSection(SubjectSection section) {
    if (section.subjects.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.bannerImage.isNotEmpty)
          Container(
            height: 120,
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(section.bannerImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
        _buildSectionHeader(
          section.title,
          onViewAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ViewAllScreen(
                  title: section.title,
                  topics: section.subjects.map((subject) => Topic(
                    title: subject.name,
                    duration: "30 min",
                    educator: "Expert Teacher",
                    videoUrl: "",
                    thumbnailUrl: subject.image.isNotEmpty
                        ? subject.image
                        : "https://picsum.photos/300/400",
                  )).toList(),

                  onTopicTap: (Topic topic) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SubjectDetailsScreen(
                          subjectName: section.title,
                          subjectSection: section,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 245,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: section.subjects.length,
            itemBuilder: (_, index) {
              final subject = section.subjects[index];
              return _buildSubjectItemCard(subject, section.title);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectItemCard(SubjectItem subject, String sectionTitle) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubjectDetailsScreen(
              subjectName: subject.name,
              subjectItem: subject,
            ),
          ),
        );
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primaryOrange.withOpacity(.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: subject.image.isNotEmpty
                    ? Image.network(
                  subject.image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(Icons.book, color: Colors.white54, size: 40),
                      ),
                    );
                  },
                )
                    : Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(Icons.book, color: Colors.white54, size: 40),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subject.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewArrivals(List<NewArrival> newArrivals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("New Arrival"),

        const SizedBox(height: 16),

        SizedBox(
          height: 230,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: newArrivals.length,
            itemBuilder: (context, index) {
              final arrival = newArrivals[index];

              return GestureDetector(
                onTap: () {
                  _navigateToVideoPlayer(arrival.title);
                },
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderStroke),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // 📸 IMAGE SECTION
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [

                              Image.network(
                                arrival.thumbnailUrl.isNotEmpty
                                    ? arrival.thumbnailUrl
                                    : "https://picsum.photos/300/400",
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  return Container(
                                    color: Colors.grey.shade900,
                                    child: const Icon(
                                      Icons.play_circle_fill,
                                      color: Colors.white54,
                                      size: 40,
                                    ),
                                  );
                                },
                              ),

                              // 🔥 gradient overlay
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                              ),

                              // ❤️ likes badge
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "❤️ ${arrival.likes}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 📝 INFO SECTION
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              arrival.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              arrival.educator,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Row(
                              children: [
                                const Icon(
                                  Icons.play_circle_outline,
                                  size: 14,
                                  color: AppColors.primaryOrange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDuration(arrival.duration),
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
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
      ],
    );
  }
  Widget _buildUpcomingTests() {
    return Consumer<ContinueWatchingViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoadingUpcomingTests) {
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderStroke),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (viewModel.upcomingTests.isEmpty) {
          return const SizedBox.shrink(); // Or show a message
        }

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderStroke),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "UPCOMING TESTS",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to all upcoming tests screen
                    },
                    child: const Text("View all", style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...viewModel.upcomingTests.map((test) => _buildUpcomingTestCard(test)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpcomingTestCard(UpcomingTestItem test) {
    // Format date
    String month = _getMonthAbbreviation(test.date.month);  // Use 'date' instead of 'startDateTime'
    String day = test.date.day.toString();  // Use 'date' instead of 'startDateTime'

    // Format time
    String time = _formatTime(test.date);  // Use 'date' instead of 'startDateTime'

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 78,
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(month, style: const TextStyle(color: AppColors.primaryOrange)),
                const SizedBox(height: 5),
                Text(day, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(test.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("${test.category} • ${test.questions} Questions", style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 4),
                Text("By: ${test.teacher}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 10),
                Text("🕒 $time     ⏱ ${test.duration} Minutes", style: const TextStyle(color: Colors.white54)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // Navigate to test details/instructions screen
              _navigateToTest(test);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryOrange),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text("Join", style: TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

// Add navigation method for tests
  void _navigateToTest(UpcomingTestItem test) {
    // Navigate to your test instructions screen
    // You'll need to import the test screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestInstructionsScreen(
          testId: test.id,
          testTitle: test.title,
          duration: test.duration,
          questionsCount: test.questions,
          instructions: [], // Add instructions if available
        ),
      ),
    );
  }

  String _getMonthAbbreviation(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }

  String _formatTime(DateTime dateTime) {
    int hour = dateTime.hour;
    String period = hour >= 12 ? 'PM' : 'AM';
    int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }
  void _navigateToVideoPlayer(String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ReelsEarnScreen(
          isVisible: true,
          initialType: "PYQ",
        ),
      ),
    );
  }

  void _navigateToVideoPlayerWithProgress(String videoUrl, String title, ContinueWatchingItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ReelsEarnScreen(
          isVisible: true,
          initialType: "PYQ",
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '$hours hr ${remainingMinutes > 0 ? '$remainingMinutes min' : ''}';
    }
    return '$minutes min';
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16)),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.white))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE57373)),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const OttAuthScreen()),
                    (route) => false,
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
