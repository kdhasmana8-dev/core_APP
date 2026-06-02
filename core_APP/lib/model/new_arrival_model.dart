// lib/model/new_arrival_model.dart
import 'package:core_app/model/teacher_model.dart';

class NewArrival {
  final String id;
  final String exam;
  final String title;
  final String subtitle;
  final String thumbnailUrl;
  final String educator;
  final int likes;
  final int duration;
  final bool isActive;
  final DateTime uploadDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  NewArrival({
    required this.id,
    required this.exam,
    required this.title,
    required this.subtitle,
    required this.thumbnailUrl,
    required this.educator,
    required this.likes,
    required this.duration,
    required this.isActive,
    required this.uploadDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NewArrival.fromJson(Map<String, dynamic> json) {
    return NewArrival(
      id: json['_id'],
      exam: json['exam'],
      title: json['title'],
      subtitle: json['subtitle'],
      thumbnailUrl: json['thumbnailUrl'],
      educator: json['educator'],
      likes: json['likes'],
      duration: json['duration'],
      isActive: json['isActive'],
      uploadDate: DateTime.parse(json['uploadDate']),
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