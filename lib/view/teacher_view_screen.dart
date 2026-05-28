import 'package:flutter/material.dart';
import '../model/teacher_model.dart';

class TeacherProfileScreen extends StatelessWidget {
  final Teacher teacher;
  const TeacherProfileScreen({super.key, required this.teacher});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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