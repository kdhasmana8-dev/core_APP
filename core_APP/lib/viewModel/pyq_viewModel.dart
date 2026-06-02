// lib/viewModel/pyq_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PYQViewModel extends ChangeNotifier {
  List<PYQItem> _pyqs = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PYQItem> get pyqs => _pyqs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _pyqs.isNotEmpty;

  final String baseUrl = "https://core-backend-38rr.onrender.com";

  Future<void> fetchPYQs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("user_token");

      if (token == null || token.isEmpty) {
        _errorMessage = 'No authentication token found';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/pyqs'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("PYQ STATUS CODE: ${response.statusCode}");
      debugPrint("PYQ RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          _pyqs = data.map((item) => PYQItem.fromJson(item)).toList();
          debugPrint("PYQs LOADED: ${_pyqs.length}");
        } else {
          _errorMessage = responseData['message'] ?? 'Failed to load PYQs';
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Session expired. Please login again.';
      } else {
        _errorMessage = 'Failed to load PYQs: ${response.statusCode}';
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error: $e';
      debugPrint("FETCH PYQS ERROR: $e");
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearPYQs() {
    _pyqs = [];
    notifyListeners();
  }
}

class PYQItem {
  final String id;
  final SubjectInfo subject;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnail;
  final String chapter;
  final String topic;
  final int year;
  final String status;

  PYQItem({
    required this.id,
    required this.subject,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnail,
    required this.chapter,
    required this.topic,
    required this.year,
    required this.status,
  });

  factory PYQItem.fromJson(Map<String, dynamic> json) {
    return PYQItem(
      id: json['_id'] ?? '',
      subject: SubjectInfo.fromJson(json['subject'] ?? {}),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      chapter: json['chapter'] ?? '',
      topic: json['topic'] ?? '',
      year: json['year'] ?? 0,
      status: json['status'] ?? '',
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