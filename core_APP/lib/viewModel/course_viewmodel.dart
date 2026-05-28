import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/course_model.dart';

class CourseViewModel extends ChangeNotifier {
  List<CourseModel> _courses = [];
  bool _isLoading = false;

  List<CourseModel> get courses => _courses;
  bool get isLoading => _isLoading;

  CourseViewModel() {
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.22:5000/api/courses/all'),
      );

      if (response.statusCode == 200) {
        // Your JSON is { "success": true, "courses": [...] }
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> courseList = data['courses'] ?? [];

        _courses = courseList.map((json) => CourseModel.fromJson(json)).toList();
      } else {
        debugPrint("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  CourseModel getCourseById(String id) {
    return _courses.firstWhere((element) => element.id == id);
  }
}