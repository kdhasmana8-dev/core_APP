import 'package:core_app/model/subject_model.dart';

class NewArrival {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
  final String educator;
  final int likes;
  final int duration;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  NewArrival({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.educator,
    required this.likes,
    required this.duration,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NewArrival.fromJson(Map<String, dynamic> json) {
    return NewArrival(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      videoUrl: json['video_url'] ?? '',
      educator: json['teacher_id'] != null
          ? json['teacher_id']['teacherName'] ?? ''
          : '',
      likes: json['total_likes'] ?? 0,
      duration: json['duration'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }


  // Convert to Topic (if needed for existing components)
  Topic toTopic() {
    return Topic(
      title: title,
      duration: "${duration ~/ 60} min", // Convert seconds to minutes
      educator: educator,
      videoUrl: "", // You might need to add videoUrl to your API response
      thumbnailUrl: thumbnailUrl,
    );
  }
}