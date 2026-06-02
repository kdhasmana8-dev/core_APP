

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ContinueWatchingItem {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String videoUrl;
  final String progress;
  final String educator;
  final int durationSeconds;
  final int watchedSeconds;
  final DateTime lastWatchedAt;
  final Map<String, dynamic> subject;

  ContinueWatchingItem({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.progress,
    required this.educator,
    required this.durationSeconds,
    required this.watchedSeconds,
    required this.lastWatchedAt,
    required this.subject,
  });

  factory ContinueWatchingItem.fromJson(Map<String, dynamic> json) {
    print("ITEM JSON => $json");

    return ContinueWatchingItem(
      id: json['id'] ?? json['_id'] ?? '', // Handle both id formats
      title: json['title'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? json['thumbnail'] ?? '',
      videoUrl: json['videoUrl'] ?? json['video_url'] ?? '',
      progress: json['progress'] ?? '00:00',
      educator: json['educator'] ?? json['teacher'] ?? '',
      durationSeconds: json['durationSeconds'] ?? json['duration'] ?? 0,
      watchedSeconds: json['watchedSeconds'] ?? json['watched_seconds'] ?? 0,
      lastWatchedAt: json['lastWatchedAt'] != null
          ? DateTime.parse(json['lastWatchedAt'])
          : DateTime.now(),
      subject: json['subject'] ?? {},
    );
  }
}

// New model for Upcoming Tests
// Update the UpcomingTestItem class in continue_watching_viewmodel.dart

class UpcomingTestItem {
  final String id;
  final String title;
  final String examType;
  final int questions;
  final DateTime date;
  final DateTime endDate;
  final int duration;
  final String status;
  final String subject;
  final String teacher;
  final String teacherImage;
  final String category;
  final String image;

  UpcomingTestItem({
    required this.id,
    required this.title,
    required this.examType,
    required this.questions,
    required this.date,
    required this.endDate,
    required this.duration,
    required this.status,
    required this.subject,
    required this.teacher,
    required this.teacherImage,
    required this.category,
    required this.image,
  });

  factory UpcomingTestItem.fromJson(Map<String, dynamic> json) {
    print("PARSING UPCOMING TEST: $json");

    return UpcomingTestItem(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      examType: json['examType'] ?? '',
      questions: json['questions'] ?? 0,
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now(),
      duration: json['duration'] ?? 0,
      status: json['status'] ?? '',
      subject: json['subject'] ?? '',
      teacher: json['teacher'] ?? '',
      teacherImage: json['teacherImage'] ?? '',
      category: json['category'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class ContinueWatchingViewModel extends ChangeNotifier {
  List<ContinueWatchingItem> _continueWatching = [];
  List<UpcomingTestItem> _upcomingTests = []; // Separate list for upcoming tests
  bool _isLoading = false;
  bool _isLoadingUpcomingTests = false;
  String? _errorMessage;

  List<ContinueWatchingItem> get continueWatching => _continueWatching;
  List<UpcomingTestItem> get upcomingTests => _upcomingTests;
  bool get isLoading => _isLoading;
  bool get isLoadingUpcomingTests => _isLoadingUpcomingTests;
  String? get errorMessage => _errorMessage;

  // =========================
  // GET TOKEN
  // =========================

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? prefs.getString('user_token');
    print("TOKEN => $token");
    return token;
  }

  Future<void> fetchContinueWatching() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    print("FETCH CONTINUE WATCHING API CALLED");

    try {
      final token = await _getToken();
      print("FETCH TOKEN => $token");

      final response = await http.get(
        Uri.parse('https://core-backend-38rr.onrender.com/api/continue-watching'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("STATUS CODE => ${response.statusCode}");
      print("RAW RESPONSE => ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("DECODED RESPONSE => $data");

        if (data['success'] == true && data['data'] != null) {
          print("DATA LENGTH => ${(data['data'] as List).length}");

          _continueWatching = (data['data'] as List)
              .map((item) => ContinueWatchingItem.fromJson(item))
              .toList();

          print("CONTINUE WATCHING LIST => ${_continueWatching.length}");
        } else {
          print("NO DATA FOUND");
          _continueWatching = [];
        }
      } else {
        _errorMessage = 'Failed to load continue watching data';
        print("API ERROR => $_errorMessage");
        _continueWatching = [];
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      print("EXCEPTION => $e");
      debugPrint('Error fetching continue watching: $e');
      _continueWatching = [];
    } finally {
      _isLoading = false;
      print("LOADING COMPLETED");
      notifyListeners();
    }
  }

  // =========================
  // FETCH UPCOMING TESTS (Separate method)
  // =========================

  // Update the fetchUpcomingTests method in ContinueWatchingViewModel

  Future<void> fetchUpcomingTests() async {
    _isLoadingUpcomingTests = true;
    notifyListeners();

    print("FETCH UPCOMING TESTS API CALLED");

    try {
      final token = await _getToken();
      print("FETCH TOKEN FOR UPCOMING TESTS => $token");

      final response = await http.get(
        Uri.parse('https://core-backend-38rr.onrender.com/api/upcoming-tests'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("UPCOMING TESTS STATUS => ${response.statusCode}");
      print("UPCOMING TESTS RESPONSE => ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("DECODED DATA => $data");

        if (data['success'] == true && data['data'] != null) {
          // The API returns 'data' array, not 'tests'
          _upcomingTests = (data['data'] as List)
              .map((item) => UpcomingTestItem.fromJson(item))
              .toList();
          print("UPCOMING TESTS COUNT => ${_upcomingTests.length}");
        } else {
          print("NO DATA FOUND IN RESPONSE");
          _upcomingTests = [];
        }
      } else {
        print("Failed to fetch upcoming tests. Status: ${response.statusCode}");
        _upcomingTests = [];
      }
    } catch (e) {
      print("UPCOMING TESTS ERROR => $e");
      _upcomingTests = [];
    } finally {
      _isLoadingUpcomingTests = false;
      notifyListeners();
    }
  }

  // =========================
  // SAVE PROGRESS
  // =========================

  Future<void> saveProgress(
      String videoId,
      int watchedSeconds,
      int durationSeconds,
      ) async {
    print("SAVE PROGRESS API CALLED");
    print("VIDEO ID => $videoId");
    print("WATCHED SECONDS => $watchedSeconds");
    print("DURATION SECONDS => $durationSeconds");

    try {
      final token = await _getToken();
      print("SAVE TOKEN => $token");

      final body = {
        'videoId': videoId,
        'watchedSeconds': watchedSeconds,
        'durationSeconds': durationSeconds,
      };

      print("REQUEST BODY => $body");

      final response = await http.post(
        Uri.parse('https://core-backend-38rr.onrender.com/api/continue-watching/save'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      print("SAVE STATUS CODE => ${response.statusCode}");
      print("SAVE RESPONSE => ${response.body}");

      if (response.statusCode == 200) {
        debugPrint('Progress saved successfully');
        print("PROGRESS SAVED SUCCESSFULLY");
        await fetchContinueWatching();
      } else {
        print("FAILED TO SAVE PROGRESS");
      }
    } catch (e) {
      print("SAVE PROGRESS ERROR => $e");
      debugPrint('Error saving progress: $e');
    }
  }
}