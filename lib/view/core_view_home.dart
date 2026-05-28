import 'package:core_app/view/subject_details_view_screen.dart';
import 'package:core_app/view/teacher_view_screen.dart';
import 'package:core_app/view/video_card_screen.dart';
import 'package:core_app/view_all_screen.dart' hide Topic;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/teacher_model.dart';
import '../utils/app_colors.dart';
import '../viewModel/teacher_viewModel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int selectedCategory = 0;
  final PageController _pageController = PageController(viewportFraction: 0.92);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentPage = 0;
  final categories = [
    "All",
    "JEE (Main+Adv)",
  ];

  final List<Topic> continueWatchingTopics = List.generate(5, (index) => Topic(
    title: "Fisher Projection #${index + 1}",
    duration: "00:35", // Resume time
    educator: "Resume from 00:35",
    videoUrl: "",
    thumbnailUrl: "https://picsum.photos/300/400?random=$index",
  ));
  // Yeh list New Arrival ke liye hai
  final List<Topic> newArrivalTopics = List.generate(5, (index) => Topic(
    title: "Concept Reels #${index + 1}",
    duration: "Fresh Learning Content",
    educator: "Expert Teacher",
    videoUrl: "",
    thumbnailUrl: "https://picsum.photos/300/400?new=$index",
  ));
  // Yeh data aapke home screen ke sections ka source hoga
  final List<Topic> physicsTopics = List.generate(5, (i) => Topic(title: "Physics Ch ${i+1}", duration: "1h", educator: "Lokesh Sir", videoUrl: "", thumbnailUrl: "https://picsum.photos/300/400?phy=$i"));
  final List<Topic> chemistryTopics = List.generate(5, (i) => Topic(title: "Chem Ch ${i+1}", duration: "1h", educator: "Karishma Ma'am", videoUrl: "", thumbnailUrl: "https://picsum.photos/300/400?chem=$i"));
  final List<Topic> mathsTopics = List.generate(5, (i) => Topic(title: "Maths Ch ${i+1}", duration: "1h", educator: "Teacher", videoUrl: "", thumbnailUrl: "https://picsum.photos/300/400?math=$i"));
  final List<Topic> biologyTopics = List.generate(5, (i) => Topic(title: "Bio Ch ${i+1}", duration: "1h", educator: "Teacher", videoUrl: "", thumbnailUrl: "https://picsum.photos/300/400?bio=$i"));
  final List<Topic> pyqTopics = List.generate(4, (i) => Topic(title: "JEE PYQ ${2024-i}", duration: "2h", educator: "Experts", videoUrl: "", thumbnailUrl: "https://picsum.photos/300/400?pyq=$i"));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
        drawer: const Drawer(
          child: Center(
            child: Text("Drawer"),
          ),
        ),
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.background,

        body:
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child:
          SafeArea(
              child: SingleChildScrollView(
                padding:  EdgeInsets.symmetric(horizontal: 17),
              child: SizedBox(
                width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [

                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: AppColors.cardSurface,
                          border: Border.all(
                            color: AppColors.borderStroke,
                          ),
                        ),
                        child: Image.asset("assets/images/logo5.png"),
                      ),

                      const SizedBox(width: 12),

                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: const [

                          Text(
                            "CORE",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 5,
                            ),
                          ),

                          // Text(
                          //   "CONCEPTREELS",
                          //   style: TextStyle(
                          //     color: AppColors.primaryOrange,
                          //     fontSize: 10,
                          //     letterSpacing: 2,
                          //   ),
                          // ),
                        ],
                      ),

                      const Spacer(),

                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.notifications_none,
                          color: Colors.white,
                        ),
                      ),

                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryOrange,
                          ),
                          image: const DecorationImage(
                            image: NetworkImage(
                              "https://i.pravatar.cc/150",
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // GREETING
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Hello, ",
                              style: TextStyle(fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins'),
                            ),
                            TextSpan(
                              text: "Arjun 👋",
                              style: TextStyle(fontSize: 18,
                                  color: AppColors.primaryOrange,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Let's continue your learning journey",
                    style: TextStyle(color: AppColors.textSecondary,
                        fontSize: 15,
                        fontFamily: 'Poppins'),
                  ),

                  const SizedBox(height: 12),

                  /// SEARCH BAR
                  Row(
                    children: [

                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius:
                            BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.borderStroke,
                            ),
                          ),
                          child: const TextField(
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.white70,
                              ),
                              hintText:
                              "Search topic, series, PYQ...",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                    ],
                  ),

                  const SizedBox(height: 12),

                  /// FILTERS
                  SizedBox(
                    height: 35,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        bool selected =
                            selectedCategory == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = index;
                            });
                          },
                          child: Container(
                            margin:
                            const EdgeInsets.only(right: 12),

                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),

                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primaryOrange
                                  : AppColors.cardSurface,

                              borderRadius:
                              BorderRadius.circular(14),

                              border: Border.all(
                                color: selected
                                    ? AppColors.primaryOrange
                                    : AppColors.borderStroke,
                              ),
                            ),

                            child: Center(
                              child: Text(
                                categories[index],
                                style: TextStyle(
                                  color: selected
                                      ? Colors.black
                                      : Colors.white,
                                  fontSize: 12,
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),


                  /// VIDEO CAROUSEL SECTION
                  Column(
                    children: [
                      SizedBox(
                        height: 450,

                        child: PageView.builder(
                          controller: _pageController,


                          itemCount: 5,

                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },

                          itemBuilder: (context, index) {
                            return AnimatedBuilder(
                              animation: _pageController,

                              builder: (context, child) {
                                double scale = 1;

                                if (_pageController.hasClients &&
                                    _pageController.position.haveDimensions) {
                                  scale =
                                      (_pageController.page ?? 0) - index;

                                  scale =
                                      (1 - (scale.abs() * .12))
                                          .clamp(.92, 1.0);
                                }

                                return Transform.scale(
                                  scale: scale,
                                  child: child,
                                );
                              },

                              child: Container(
                                margin: const EdgeInsets.only(
                                  left: 2, // ← LEFT GAP FIX
                                  right: 8,
                                  top: 10,
                                  bottom: 10,
                                ),

                                decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(24),

                                  border: Border.all(
                                    color: AppColors.borderStroke,
                                  ),
                                ),

                                child: ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(24),

                                  child: Stack(
                                    fit: StackFit.expand,

                                    children: [

                                      /// VIDEO
                                      VideoCard(
                                        key: ValueKey(index),

                                        videoUrl:
                                        "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
                                      ),

                                      /// TEXT
                                      Positioned(
                                        left: 18,
                                        right: 18,
                                        bottom: 24,

                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                          children: const [

                                            Text(
                                              "Fisher Projection Trick",

                                              style: TextStyle(
                                                color:
                                                Colors.white,

                                                fontSize: 14,

                                                fontWeight:
                                                FontWeight.w700,
                                              ),
                                            ),

                                            SizedBox(height: 6),

                                            Text(
                                              "Chemistry",

                                              style: TextStyle(
                                                color:
                                                Colors.white70,

                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// DOTS
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,

                        children: List.generate(
                          5,
                              (index) => AnimatedContainer(
                            duration:
                            const Duration(milliseconds: 300),

                            margin:
                            const EdgeInsets.symmetric(
                                horizontal: 4),

                            width:
                            _currentPage == index
                                ? 18
                                : 8,

                            height: 8,

                            decoration: BoxDecoration(
                              color:
                              _currentPage == index
                                  ? AppColors
                                  .primaryOrange
                                  : Colors.white24,

                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  /// TOP SUBJECTS
                  Row(
                    children: [
                      const Text(
                        "Top Subjects",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {

                        },
                        child: const Text(
                          "View all",
                          style: TextStyle(
                            fontSize: 12,
                            color:Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    height: 90,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [

                        _subjectCard(
                          Icons.science_outlined,
                          "PHYSICS",
                          "124 Chapters",
                          physicsTopics
                        ),

                        _subjectCard(
                          Icons.biotech_outlined,
                          "CHEMISTRY",
                          "118 Chapters",
                          chemistryTopics
                        ),

                        _subjectCard(
                          Icons.grid_view_rounded,
                          "MATHEMATICS",
                          "96 Chapters",
                          mathsTopics
                        ),

                        _subjectCard(
                          Icons.delivery_dining,
                          "BIOLOGY",
                          "64 Chapters",
                          biologyTopics
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Heading aur View All Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Top Educators",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: const Text(
                                "View all",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    //  Top Educators Section
                      SizedBox(
                        height: 120,
                        child: Consumer<TeacherViewModel>(
                          builder: (context, viewModel, child) {
                            // API se data load ho raha hai
                            if (viewModel.isLoading) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            // Agar list khali hai
                            if (viewModel.teachers.isEmpty) {
                              return const Center(child: Text("No educators found", style: TextStyle(color: Colors.white54)));
                            }

                            // API wala data yahan dikhega
                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              scrollDirection: Axis.horizontal,
                              itemCount: viewModel.teachers.length, // allTeachers ki jagah ye use karein
                              itemBuilder: (context, index) {
                                final teacher = viewModel.teachers[index]; // API se data uthayein
                                return _teacherCard(teacher);
                              },
                            );
                          },
                        ),
                      ),
                  const SizedBox(height: 22),

                  //Practice & Improve
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "PRACTICE & IMPROVE",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            // const Text(
                            //   "See All",
                            //   style: TextStyle(color: Colors.white, fontSize: 14),
                            // ),
                          ],
                        ),
                      ),
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
                  ),
                  const SizedBox(height: 22),
                  /// BANNER
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: AppColors.accentGradient,
                      border: Border.all(
                        color: AppColors.borderStroke,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: const [

                                Text(
                                  "MASTER CONCEPTS.",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                Text(
                                  "ACHIEVE MORE.",
                                  style: TextStyle(
                                    color: AppColors.primaryOrange,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 10),

                                Text(
                                  "Learn. Practice. Rank Higher.",
                                  style: TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons.science,
                            color: AppColors.primaryOrange,
                            size: 90,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// CONTINUE WATCHING
                      Row(
                        children: [
                          const Text(
                            "Continue Watching",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              // Navigation: yahan continueWatchingTopics pass kar rahe hain
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewAllScreen(
                                    title: "Continue Watching",
                                    topics: continueWatchingTopics,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "View all",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: continueWatchingTopics.length, // List length use karein
                          itemBuilder: (_, index) {
                            final topic = continueWatchingTopics[index];
                            return Container(
                              width: 145,
                              margin: const EdgeInsets.only(right: 14),
                              decoration: BoxDecoration(
                                color: AppColors.cardSurface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderStroke),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                          child: Image.network(
                                            topic.thumbnailUrl,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const Center(
                                          child: CircleAvatar(
                                            radius: 22,
                                            backgroundColor: Colors.black54,
                                            child: Icon(Icons.play_arrow, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          topic.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          topic.educator, // Yahan "Resume from..." show hoga
                                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 18),

                  /// PYQ SERIES
                  Row(
                    children: [
                      const Text(
                        "PYQ Series",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewAllScreen(
                                title: "PYQ Series",
                                topics: pyqTopics,
                              ),
                            ),
                          );
                        },

                        child: const Text(
                          "View all",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),


                  SizedBox(
                    height: 230,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      itemBuilder: (_, index) {
                        return Container(
                          width: 155,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.borderStroke,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [

                              Expanded(
                                child: ClipRRect(
                                  borderRadius:
                                  const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: Image.network(
                                    "https://picsum.photos/300/400?pyq=$index",
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [

                                    Text(
                                      "JEE PYQ ${2024 - index}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight:
                                        FontWeight.w600,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    const Text(
                                      "Physics • Chemistry",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),
                  buildSubjectSection(
                    title: "Physics",
                    titleColor: Colors.lightBlueAccent,
                    topics: physicsTopics,
                  ),

                  const SizedBox(height: 35),

                  buildSubjectSection(
                    title: "Chemistry",
                    titleColor: Colors.greenAccent,
                    topics: chemistryTopics,
                  ),

                  const SizedBox(height: 35),

                  buildSubjectSection(
                    title: "Maths",
                    titleColor: Color(0xFFFFD180),
                    topics: mathsTopics,
                  ),

                  const SizedBox(height: 35),

                  buildSubjectSection(
                    title: "Biology",
                    titleColor: AppColors.primaryOrange,
                    topics: biologyTopics,
                  ),

                      /// NEW ARRIVAL
                      Row(
                        children: [
                          const Text(
                            "New Arrival",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              // Navigation: Yahan hum newArrivalTopics pass kar rahe hain
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewAllScreen(
                                    title: "New Arrival",
                                    topics: newArrivalTopics,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "View all",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: newArrivalTopics.length, // Yahan list length use karein
                          itemBuilder: (_, index) {
                            final topic = newArrivalTopics[index]; // List se item uthayein
                            return Container(
                              width: 180,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                color: AppColors.cardSurface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.borderStroke),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                      child: Image.network(
                                        topic.thumbnailUrl, // Dynamic image
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      children: [
                                        Text(
                                          topic.title, // Dynamic title
                                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          topic.duration, // Dynamic subtitle
                                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                  const SizedBox(height: 24),

                      /// =======================
                      /// UPCOMING TEST
                      /// =======================

                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.borderStroke,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "UPCOMING TESTS",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    "View all",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: AppColors.borderStroke,
                                ),
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
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "MAY",
                                          style: TextStyle(
                                            color: AppColors.primaryOrange,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "18",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 14,
                                  ),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Full Syllabus Test",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          "JEE (Main+Adv) • 180 Questions",
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "🕒 3:00 PM     ⏱ 3 Hours",
                                          style: TextStyle(
                                            color: Colors.white54,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.primaryOrange,
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: const Text(
                                      "Join",
                                      style: TextStyle(
                                        color: AppColors.primaryOrange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),

                      /// =======================
                      /// PERFORMANCE OVERVIEW
                      /// =======================

                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.borderStroke,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "PERFORMANCE OVERVIEW",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    "View all",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: _scoreCard(
                                    "Tests Attempted",
                                    "24",
                                  ),
                                ),
                                Expanded(
                                  child: _scoreCard(
                                    "Average Score",
                                    "42.6",
                                  ),
                                ),
                                Expanded(
                                  child: _scoreCard(
                                    "Accuracy",
                                    "68%",
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            Container(
                              height: 90,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.primaryOrange.withOpacity(0.20),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.show_chart,
                                  size: 80,
                                  color: AppColors.primaryOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
            ]
                  )
       ] ),

            ),)
          )
        )
            );

  }
  Widget _practiceCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
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
          Icon(icon, color: AppColors.primaryOrange, size: 28), // Orange color highlight ke liye
          const SizedBox(height: 10),
          Text(
            value, // Value upar (e.g., 120+)
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title, // Title neeche
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  Widget _scoreCard(
      String subject,
      String score,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [

          Text(
            score,
            style: const TextStyle(
              color: AppColors.primaryOrange,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            subject,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _subjectCard(IconData icon, String title, String subtitle, List<Topic> topics) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => ViewAllScreen(title: title, topics: topics)
        ));
      },
      child: Container(
        width: 85,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.borderStroke)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w600)),
            Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _teacherCard(Teacher teacher) {
    return GestureDetector(
        onTap: () {
           final teacherViewModel = Provider.of<TeacherViewModel>(context, listen: false);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider.value(
                  value: teacherViewModel, // Yahan wahi instance pass ho raha hai
                  child: TeacherProfileScreen(teacher: teacher),
                ),
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
            Text(teacher.name, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
  Widget buildSubjectSection({
    required String title,
    required Color titleColor,
    required List<Topic> topics, // Ye parameter add kiya
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.w700)),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAllScreen(title: title, topics: topics)));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
               // decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(30))),
                child: const Row(children: [Text("View all", style: TextStyle(color: Colors.white, fontSize: 12)), SizedBox(width: 6),]),
              ),
            ),
          ],
        ),

        SizedBox(
          height: 245,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (_, index) {
              final physicsTitles = [
                "Atoms",
                "Motion",
                "Waves",
                "Optics",
                "Current",
              ];

              final chemistryTitles = [
                "Mole Concept",
                "Atomic Structure",
                "Thermodynamics",
                "Redox",
                "Organic",
              ];

              final mathsTitles = [
                "Algebra",
                "Calculus",
                "Matrices",
                "Probability",
                "Vectors",
              ];

              final biologyTitles = [
                "Cell",
                "Genetics",
                "Evolution",
                "Ecology",
                "Biotech",
              ];

              final images = [
                "https://images.unsplash.com/photo-1532187643603-ba119ca4109e",
                "https://images.unsplash.com/photo-1532094349884-543bc11b234d",
                "https://images.unsplash.com/photo-1509228468518-180dd4864904",
                "https://images.unsplash.com/photo-1532634993-15f421e42ec0",
                "https://images.unsplash.com/photo-1507413245164-6160d8298b31",
              ];

              String cardTitle = "";

              if (title == "Physics") {
                cardTitle = physicsTitles[index];
              } else if (title == "Chemistry") {
                cardTitle = chemistryTitles[index];
              } else if (title == "Maths") {
                cardTitle = mathsTitles[index];
              } else {
                cardTitle = biologyTitles[index];
              }

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SubjectDetailsScreen(
                            subjectName: cardTitle,
                          ),
                    ),
                  );
                },
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.only(
                    right: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius:
                    BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primaryOrange
                          .withOpacity(.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      Expanded(
                        child: ClipRRect(
                          borderRadius:
                          const BorderRadius.vertical(
                            top: Radius.circular(10),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [

                              Image.network(
                                images[index],
                                fit: BoxFit.cover,
                              ),

                              Container(
                                decoration: BoxDecoration(
                                  gradient:
                                  LinearGradient(
                                    begin:
                                    Alignment.topCenter,
                                    end: Alignment
                                        .bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black
                                          .withOpacity(
                                          .85),
                                    ],
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding:
                        const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [

                            Text(
                              cardTitle,
                              maxLines: 2,

                              overflow:
                              TextOverflow
                                  .ellipsis,
                              style:
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              "${index + 1} videos",
                              style:
                              const TextStyle(
                                color:
                                Colors.white70,
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
            },
          ),
        ),
      ],
    );
  }
}