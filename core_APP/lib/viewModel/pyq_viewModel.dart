// lib/viewModel/pyq_viewmodel.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PYQViewModel extends ChangeNotifier {
  List<PYQItem> _pyqs = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PYQItem> get pyqs => _pyqs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _pyqs.isNotEmpty;

  final String apiUrl = "https://core-backend-38rr.onrender.com/api/reels/pyq";

  Future<void> fetchPYQs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
      );

      debugPrint("PYQ STATUS => ${response.statusCode}");
      debugPrint("PYQ RESPONSE => ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData =
        jsonDecode(response.body);

        if (jsonData["success"] == true) {
          final List<dynamic> reels =
              jsonData["reels"] ?? [];

          _pyqs = reels
              .map((e) => PYQItem.fromJson(e))
              .toList();

          debugPrint("TOTAL PYQS => ${_pyqs.length}");
        } else {
          _errorMessage = "No PYQs found";
        }
      } else {
        _errorMessage =
        "Server Error (${response.statusCode})";
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("PYQ ERROR => $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearPYQs() {
    _pyqs.clear();
    notifyListeners();
  }
}

class PYQItem {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  final int duration;
  final int pyqYear;
  final bool isPyq;
  final bool isPro;
  final bool isActive;
  final String status;

  final String topicId;
  final String topicName;

  final String teacherId;
  final String teacherName;
  final String teacherEmail;
  final String teacherPhone;
  final String teacherDescription;
  final int teacherExperience;
  final String teacherQualification;

  PYQItem({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.duration,
    required this.pyqYear,
    required this.isPyq,
    required this.isPro,
    required this.isActive,
    required this.status,
    required this.topicId,
    required this.topicName,
    required this.teacherId,
    required this.teacherName,
    required this.teacherEmail,
    required this.teacherPhone,
    required this.teacherDescription,
    required this.teacherExperience,
    required this.teacherQualification,
  });

  factory PYQItem.fromJson(Map<String, dynamic> json) {
    final topic = json["topic_id"] ?? {};
    final teacher = json["teacher_id"] ?? {};

    return PYQItem(
      id: json["_id"] ?? "",
      title: json["title"] ?? "",
      description: json["description"] ?? "",
      videoUrl: json["video_url"] ?? "",
      thumbnailUrl: json["thumbnail_url"] ?? "",
      duration: json["duration"] ?? 0,
      pyqYear: json["pyq_year"] ?? 0,
      isPyq: json["is_pyq"] ?? false,
      isPro: json["is_pro"] ?? false,
      isActive: json["is_active"] ?? false,
      status: json["status"] ?? "",

      topicId: topic["_id"] ?? "",
      topicName: topic["name"] ?? "",

      teacherId: teacher["_id"] ?? "",
      teacherName: teacher["teacherName"] ?? "",
      teacherEmail: teacher["email"] ?? "",
      teacherPhone: teacher["phone"] ?? "",
      teacherDescription: teacher["description"] ?? "",
      teacherExperience: teacher["experience"] ?? 0,
      teacherQualification:
      teacher["qualification"] ?? "",
    );
  }
}

class SubjectInfo {
  final String id;
  final String name;
  final String description;
  final String image;
  final String icon;

  SubjectInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.icon,
  });

  factory SubjectInfo.fromJson(Map<String, dynamic> json) {
    return SubjectInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      icon: json['icon'] ?? '',
    );
  }
}