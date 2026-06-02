import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/reel_model.dart';

class ReelsEarnViewModel extends ChangeNotifier {
  bool loading = false;
  int currentIndex = 0;
  List<ReelEarnModel> reels = [];

  final String baseUrl = 'https://core-backend-38rr.onrender.com/api/reel-model';
  final String authBaseUrl = 'https://core-backend-38rr.onrender.com'; // Auth server

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("user_token");
    print("🔐 TOKEN => ${token != null ? "Present" : "NULL"}");
    return token;
  }

  Future<void> loadReels() async {
    print("=== LOAD FOR YOU REELS ===");
    await _fetchReels();
  }

  Future<void> loadStudyReels() async {
    print("=== LOAD STUDY REELS ===");
    await _fetchReels(type: 'Study');
  }

  Future<void> loadPYQReels() async {
    print("=== LOAD PYQ REELS ===");
    await _fetchReels(type: 'PYQ');
  }

  Map<String, List<String>> filters = {};

  Future<void> loadFilters() async {
    try {
      final token = await _getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/filters'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        filters = {
          "Exam": List<String>.from(data["exams"] ?? []),
          "Subject": List<String>.from(data["subjects"] ?? []),
          "Chapter": List<String>.from(data["chapters"] ?? []),
          "Topic": List<String>.from(data["topics"] ?? []),
          "Teacher": List<String>.from(data["teachers"] ?? []),
        };

        notifyListeners();
      }
    } catch (e) {
      print("Filter Error => $e");
    }
  }
  Future<void> _fetchReels({String? type}) async {
    loading = true;
    notifyListeners();

    try {
      final token = await _getToken();

      String url = baseUrl;
      if (type != null && type.isNotEmpty) {
        url = '$baseUrl?type=$type';
      }

      print("📡 API URL: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['result'] != null) {
          final List<dynamic> resultList = data['result'];

          reels = resultList.map((item) {
            return ReelEarnModel(
              videoId: item['_id']?.toString() ?? '',
              videoUrl: item['videoUrl'] ?? '',
              title: item['title'] ?? '',
              description: item['description'] ?? '',
              thumbnail: item['thumbnail'] ?? '',
              likes: item['likes'] ?? 0,
              isLiked: item['isLiked'] ?? false,
              isSaved: item['isSaved'] ?? false,
              type: item['type'] ?? '',
              teacherName: item['teacherName'] ?? '',
              teacherUsername: item['teacherUsername'] ?? '',
              teacherProfile: item['teacherProfile'] ?? '',
              tags: item['tags'] != null ? List<String>.from(item['tags']) : [],
            );
          }).toList();

          print("🎉 Reels loaded: ${reels.length}");
        } else {
          _loadFallbackReels(type: type);
        }
      } else {
        _loadFallbackReels(type: type);
      }
    } catch (e) {
      print("🔥 Error: $e");
      _loadFallbackReels(type: type);
    }

    loading = false;
    notifyListeners();
  }

  void _loadFallbackReels({String? type}) {
    if (type == 'Study') {
      reels = [
        ReelEarnModel(
          videoId: "fallback_study_1",
          videoUrl: "https://vz-fd5fa6c8-ece.b-cdn.net/9280db5a-f3ca-4255-a8da-b7b2b4bc0764/playlist.m3u8",
          title: "Study Tips & Tricks",
          description: "Learn how to study effectively.",
          likes: 3200,
          type: "Study",
          tags: ["study", "tips"],
        ),
      ];
    } else if (type == 'PYQ') {
      reels = [
        ReelEarnModel(
          videoId: "fallback_pyq_1",
          videoUrl: "https://vz-fd5fa6c8-ece.b-cdn.net/ec98e638-572b-4629-9bf8-db2302ae64f3/playlist.m3u8",
          title: "JEE Previous Year Questions",
          description: "Important PYQ solutions.",
          likes: 1420,
          type: "PYQ",
          tags: ["pyq", "jee"],
        ),
      ];
    } else {
      reels = [
        ReelEarnModel(
          videoId: "fallback_1",
          videoUrl: "https://vz-fd5fa6c8-ece.b-cdn.net/39f61af3-3e12-4687-86e2-d10c16ede091/playlist.m3u8",
          title: "Physics Kinematics",
          description: "Learn Kinematics basics.",
          likes: 12400,
          tags: ["physics", "jee"],
        ),
      ];
    }
  }

  // ================= SAVE REEL - MULTIPLE ENDPOINTS TRY =================

  Future<void> saveReel(int index) async {
    if (index < 0 || index >= reels.length) return;

    final oldSaved = reels[index].isSaved;

    // Optimistic update
    reels[index] = reels[index].copyWith(
      isSaved: !reels[index].isSaved,
    );
    notifyListeners();

    // Try multiple endpoints
    bool success = false;

    // Try endpoint 1
    success = await _trySaveEndpoint1(reels[index].videoId);

    // If failed, try endpoint 2
    if (!success) {
      print("🔄 Trying endpoint 2...");
      success = await _trySaveEndpoint2(reels[index].videoId);
    }

    // If failed, try endpoint 3
    if (!success) {
      print("🔄 Trying endpoint 3...");
      success = await _trySaveEndpoint3(reels[index].videoId);
    }

    // If failed, try endpoint 4
    if (!success) {
      print("🔄 Trying endpoint 4...");
      success = await _trySaveEndpoint4(reels[index].videoId);
    }

    if (!success) {
      // Revert on failure
      reels[index] = reels[index].copyWith(isSaved: oldSaved);
      notifyListeners();
      print("❌ All save endpoints failed - reverted");
    } else {
      print("✅ Save successful!");
    }
  }

  // Endpoint 1: /api/reel-model/save
  Future<bool> _trySaveEndpoint1(String videoId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final url = '$authBaseUrl/api/save-reels/save';
      print("📡 Trying: POST $url");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'reelId': videoId}),
      );

      print("Status: ${response.statusCode}");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  // Endpoint 2: /api/save-reel
  Future<bool> _trySaveEndpoint2(String videoId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final url = 'https://core-backend-38rr.onrender.com/api/save-reels/save';
      print("📡 Trying: POST $url");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'reelId': videoId}),
      );

      print("Status: ${response.statusCode}");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  // Endpoint 3: /api/reels/save
  Future<bool> _trySaveEndpoint3(String videoId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final url = 'https://core-backend-38rr.onrender.com/api/save-reels/save';
      print("📡 Trying: POST $url");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'reelId': videoId}),
      );

      print("Status: ${response.statusCode}");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  // Endpoint 4: /api/bookmark
  Future<bool> _trySaveEndpoint4(String videoId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final url = 'https://core-backend-38rr.onrender.com/api/save-reels/save';
      print("📡 Trying: POST $url");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'reelId': videoId}),
      );

      print("Status: ${response.statusCode}");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  // ================= LIKE API =================

  void like(int index) async {
    if (index < 0 || index >= reels.length) return;

    final oldLiked = reels[index].isLiked;
    final oldLikes = reels[index].likes;

    reels[index] = reels[index].copyWith(
      isLiked: !reels[index].isLiked,
      likes: reels[index].isLiked ? reels[index].likes - 1 : reels[index]
          .likes + 1,
    );
    notifyListeners();

    final success = await _sendLikeToApi(
        reels[index].videoId, reels[index].isLiked);

    if (!success) {
      reels[index] = reels[index].copyWith(isLiked: oldLiked, likes: oldLikes);
      notifyListeners();
    }
  }

  Future<bool> _sendLikeToApi(String videoId, bool isLiked) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/like'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'videoId': videoId, 'liked': isLiked}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("🔥 LIKE ERROR => $e");
      return false;
    }
  }

  Future<void> saveContinueWatching({
    required String videoId,
    required int watchedSeconds,
    required int durationSeconds,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        print("❌ Token not found");
        return;
      }

      final response = await http.post(
        Uri.parse(
          'http://192.168.1.8:5000/api/continue-watching/save',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "videoId": videoId,
          "watchedSeconds": watchedSeconds,
          "durationSeconds": durationSeconds,
        }),
      );

      print("📺 Continue Watching Status => ${response.statusCode}");
      print("📺 Continue Watching Response => ${response.body}");
    } catch (e) {
      print("🔥 Continue Watching Error => $e");
    }
  }

  void changePage(int index) {
    if (index >= 0 && index < reels.length) {
      currentIndex = index;
      notifyListeners();
    }
  }
}