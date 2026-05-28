import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewModel/course_viewmodel.dart';
import 'package:core_app/utils/app_colors.dart';

class CourseDetailView extends StatelessWidget {
  final String courseId;

  const CourseDetailView({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CourseViewModel>(context, listen: false);
    final course = viewModel.getCourseById(courseId);

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // 1. Cinematic Header with Image
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Image as Background
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Image.asset(
                      course.imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Dark Overlay for text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.3), Colors.black],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Bottom gradient fade
                  Positioned(
                    bottom: 0,
                    left: 0, right: 0,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.0), Colors.black],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Info Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.title, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildMetaChip("JEE ${course.category}"),
                      const SizedBox(width: 10),
                      Text(course.stats, style: const TextStyle(color: Colors.white54)),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Resume Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.play_arrow_rounded, size: 28),
                      label: const Text("RESUME LEARNING", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Chapters List Header
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
            sliver: SliverToBoxAdapter(
              child: Text("Curriculum", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),

          // 4. Chapters List
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildChapterTile(context, index, course),
              childCount: course.chapters.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }

  Widget _buildMetaChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    );
  }

  Widget _buildChapterTile(BuildContext context, int index, var course) {
    bool isLocked = index > 2;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Text("${index + 1}".padLeft(2, '0'), style: TextStyle(color: course.themeColor, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(width: 20),
          Expanded(
            child: Text(course.chapters[index], style: const TextStyle(color: Colors.white, fontSize: 15)),
          ),
          Icon(isLocked ? Icons.lock_rounded : Icons.play_circle_fill_rounded,
              color: isLocked ? Colors.white24 : Colors.purpleAccent),
        ],
      ),
    );
  }
}