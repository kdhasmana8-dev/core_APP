import 'package:flutter/material.dart';

class CourseModel {
  final String id;
  final String title;
  final String category;
  final String stats;
  final double progress;
  final IconData icon;
  final Color themeColor;
  final String imagePath;
  final List<String> chapters;

  CourseModel({
    required this.id,
    required this.title,
    required this.category,
    required this.stats,
    required this.progress,
    required this.icon,
    required this.themeColor,
    required this.imagePath,
    required this.chapters,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['_id'] ?? "",
      title: json['title'] ?? "",
      category: json['category'] ?? "",
      stats: json['stats'] ?? "",
      progress: 0.0,
      icon: Icons.book,
      themeColor: Colors.blue,
      imagePath: json['image'] ?? "", // Maps to your "image" key
      chapters: (json['chapters'] as List<dynamic>?)
          ?.map((c) => c['title'].toString())
          .toList() ?? [],
    );
  }
}