
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/subject_model.dart';

class SubjectViewModel extends ChangeNotifier {
  List<SubjectSection> _subjects = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SubjectSection> get subjects => _subjects;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<SubjectSection> get subjectsWithContent {
    return _subjects.where((section) => section.hasContent).toList();
  }

  bool get hasSubjectsWithContent => subjectsWithContent.isNotEmpty;

  final String baseUrl = "https://core-backend-38rr.onrender.com";
  final String baseUrl2 = "https://core-backend-38rr.onrender.com";

  Future<void> fetchSubjects() async {
    debugPrint("========== FETCH SECTIONS STARTED ==========");
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("user_token");

      if (token == null || token.isEmpty) {
        _errorMessage = 'No authentication token found. Please login again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Step 1: Fetch sections
      final sectionsUrl = Uri.parse('$baseUrl/api/sections');
      debugPrint("FETCHING SECTIONS FROM: $sectionsUrl");

      final sectionsResponse = await http.get(
        sectionsUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("SECTIONS STATUS CODE: ${sectionsResponse.statusCode}");

      if (sectionsResponse.statusCode != 200) {
        _errorMessage = 'Failed to load sections: ${sectionsResponse.statusCode}';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Step 2: Fetch all subjects
      final subjectsUrl = Uri.parse('$baseUrl2/api/subjects/all');
      debugPrint("FETCHING SUBJECTS FROM: $subjectsUrl");

      final subjectsResponse = await http.get(
        subjectsUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("SUBJECTS STATUS CODE: ${subjectsResponse.statusCode}");

      if (subjectsResponse.statusCode != 200) {
        _errorMessage = 'Failed to load subjects: ${subjectsResponse.statusCode}';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Step 3: Parse both responses
      final sectionsData = json.decode(sectionsResponse.body);
      final subjectsData = json.decode(subjectsResponse.body);

      if (sectionsData['success'] != true || subjectsData['success'] != true) {
        _errorMessage = 'API response error';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Create subject map from subjects API
      final Map<String, SubjectItem> subjectMap = {};
      final List<dynamic> allSubjects = subjectsData['data'] ?? [];

      for (var subjectJson in allSubjects) {
        final subject = SubjectItem(
          id: subjectJson['_id'] ?? '',
          name: subjectJson['name'] ?? '',
          description: subjectJson['description'] ?? '',
          image: subjectJson['image'] ?? '',
          icon: subjectJson['icon'] ?? '',
          status: subjectJson['status'] ?? 'Active',
          totalVideos: subjectJson['totalVideos'] ?? 0,
          totalChapters: subjectJson['totalChapters'] ?? 0,
          chapters: _parseChapters(subjectJson['chapters'] ?? []),
        );
        subjectMap[subject.id] = subject;
        debugPrint("MAPPED SUBJECT: ${subject.name} (${subject.id})");
      }

      // ✅ FIXED: Use 'data' instead of 'sections'
      final List<dynamic> sectionsList =
          sectionsData['sections'] ?? [];
      debugPrint("📊 Total sections from API: ${sectionsList.length}");

      _subjects = [];

      for (var sectionJson in sectionsList) {
        final sectionId = sectionJson['_id'] ?? '';
        final sectionTitle = sectionJson['title'] ?? '';
        final sectionType = sectionJson['type'] ?? 'subject';
        final sectionSubtitle = sectionJson['subtitle'] ?? '';
        final sectionBannerImage = sectionJson['bannerImage'] ?? '';
        final isActive = sectionJson['isActive'] ?? false;
        final showViewAll = sectionJson['showViewAll'] ?? true;
        final position = sectionJson['position'] ?? 0;
        final columns = sectionJson['columns'] ?? 2;
        final isHorizontal = sectionJson['isHorizontal'] ?? true;
        final exam = sectionJson['exam'] is Map
            ? sectionJson['exam']['name'] ?? ''
            : sectionJson['exam']?.toString() ?? '';

        final List<dynamic> sectionSubjectIds = sectionJson['subjects'] ?? [];

        List<SubjectItem> sectionSubjects = [];
        for (var subjectIdObj in sectionSubjectIds) {
          String subjectId;
          if (subjectIdObj is String) {
            subjectId = subjectIdObj;
          } else if (subjectIdObj is Map && subjectIdObj.containsKey('_id')) {
            subjectId = subjectIdObj['_id'];
          } else {
            continue;
          }

          if (subjectMap.containsKey(subjectId)) {
            sectionSubjects.add(subjectMap[subjectId]!);
            debugPrint("  ✓ Added subject: ${subjectMap[subjectId]!.name} to section: $sectionTitle");
          } else {
            debugPrint("  ✗ Subject not found: $subjectId");
          }
        }

        final section = SubjectSection(
          id: sectionId,
          title: sectionTitle,
          subtitle: sectionSubtitle,
          type: sectionType,
          bannerImage: sectionBannerImage,
          isActive: isActive,
          showViewAll: showViewAll,
          subjects: sectionSubjects,
          position: position,
          columns: columns,
          isHorizontal: isHorizontal,
          exam: exam,
        );

        _subjects.add(section);

        if (sectionSubjects.isNotEmpty) {
          debugPrint("✅ CREATED SECTION: ${section.title} with ${section.subjects.length} subjects");
        } else {
          debugPrint("⚠️ SECTION: ${section.title} has 0 subjects (will be filtered out)");
        }
      }

      _subjects = _subjects
          .where((section) => section.isActive && section.hasContent)
          .toList();

      debugPrint("========== FINAL RESULTS ==========");
      debugPrint("✅ TOTAL SECTIONS LOADED: ${_subjects.length}");
      for (var section in _subjects) {
        debugPrint("  📚 ${section.title}: ${section.subjects.length} subjects");
        for (var subject in section.subjects) {
          debugPrint("     - ${subject.name} (Videos: ${subject.totalVideos}, Chapters: ${subject.totalChapters})");
        }
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Network error: $e';
      debugPrint("❌ NETWORK ERROR: $e");
      debugPrint("STACK TRACE: ${StackTrace.current}");
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Chapter> _parseChapters(List<dynamic> chaptersData) {
    List<Chapter> chapters = [];

    for (var chapterData in chaptersData) {
      List<TopicItem> topics = [];

      if (chapterData['topics'] != null && chapterData['topics'] is List) {
        for (var topicData in chapterData['topics']) {
          List<Video> videos = [];

          if (topicData['videos'] != null && topicData['videos'] is List) {
            for (var videoData in topicData['videos']) {
              videos.add(Video(
                id: videoData['_id'] ?? '',
                title: videoData['title'] ?? '',
                url: videoData['videoUrl'] ?? '',
                thumbnail: videoData['thumbnail'],
                duration: videoData['duration'],
              ));
            }
          }

          topics.add(TopicItem(
            id: topicData['_id'] ?? '',
            name: topicData['name'] ?? '',
            totalVideos: topicData['totalVideos'] ?? videos.length,
            videos: videos,
            thumbnailUrl: topicData['thumbnail'],
            duration: topicData['duration'],
            educator: topicData['educator'],
          ));
        }
      }

      chapters.add(Chapter(
        id: chapterData['_id'],
        name: chapterData['chapter'] ?? '',
        topics: topics,
      ));
    }

    return chapters;
  }

  void clearSubjects() {
    _subjects = [];
    notifyListeners();
  }
}