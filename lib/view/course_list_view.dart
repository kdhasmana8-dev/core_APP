import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/course_model.dart';
import '../viewModel/course_viewmodel.dart';
import 'course_detail_view.dart';
import 'package:core_app/utils/app_colors.dart';

class CourseListView extends StatefulWidget {
  const CourseListView({super.key});

  @override
  State<CourseListView> createState() => _CourseListViewState();
}

class _CourseListViewState extends State<CourseListView> {
  String _selectedCategory = "All";
  final List<String> _chips = ["All", "Physics", "Chemistry", "Maths", "Biology"];

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CourseViewModel>(context);

    var filteredCourses = _selectedCategory == "All"
        ? viewModel.courses
        : viewModel.courses.where((c) => c.title.toLowerCase().contains(_selectedCategory.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("Your Courses", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _chips.map((chip) => _buildFilterChip(chip)).toList(),
                ),
              ),
            ),
            _buildPosterSection("Recommended", filteredCourses.take(3).toList()),
            _buildPosterSection("JEE Main", filteredCourses.where((c) => c.category.toLowerCase() == "main").toList()),
            _buildPosterSection("JEE Advanced", filteredCourses.where((c) => c.category.toLowerCase() == "advanced").toList()),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPosterSection(String title, List<CourseModel> courses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: courses.length,
            itemBuilder: (context, index) => _buildVerticalPosterCard(courses[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalPosterCard(CourseModel course) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailView(courseId: course.id))),
      child: Container(
        width: 175,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderStroke),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: Image.asset(
                  course.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    color: Colors.white10,
                    child: const Icon(Icons.broken_image, color: Colors.white24),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        course.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)
                    ),
                    const SizedBox(height: 4),
                    Text(
                        course.stats,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryOrange : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Poppins')),
      ),
    );
  }
}