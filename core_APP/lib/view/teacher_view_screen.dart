import 'package:core_app/view/reel_view_screen.dart';
import 'package:flutter/material.dart';
import '../model/teacher_model.dart';
import '../utils/app_colors.dart'; // Ensure correct import

class TeacherProfileScreen extends StatelessWidget {
  final Teacher teacher;
  const TeacherProfileScreen({super.key, required this.teacher});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Aapke AppColors ka use
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(teacher.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              background: teacher.imageUrl.isNotEmpty
                  ? Image.network(teacher.imageUrl, fit: BoxFit.cover, color: Colors.black.withOpacity(0.4), colorBlendMode: BlendMode.darken)
                  : Container(color: Colors.grey[800], child: const Icon(Icons.person, size: 80, color: Colors.white24)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(Icons.school, teacher.qualification),
                  const SizedBox(height: 10),
                  _infoRow(Icons.work, "${teacher.experience} Years of Experience"),
                  const SizedBox(height: 20),
                  const Text("Description", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(teacher.description, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 20),
                  const Text("Subjects Taught", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: teacher.subjects.map((s) => Chip(label: Text(s))).toList(),
                  ),
                  const SizedBox(height: 25),

                  // SECTION: Study Reels in Grid
                  const Text("Study Reels", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),


                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: teacher.reels.where((reel) => reel.type.toLowerCase() == 'study').length,
                    itemBuilder: (context, index) {
                      final reel = teacher.reels.where((reel) => reel.type.toLowerCase() == 'study').toList()[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReelsEarnScreen(
                                    isVisible: true,
                                    initialType: reel.type)),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.play_circle_fill, color: Colors.orange, size: 50),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reel.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      reel.chapter,
                                      maxLines: 1,
                                      style: const TextStyle(color: Colors.white54, fontSize: 12),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange, size: 20),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 15)),
      ],
    );
  }
}