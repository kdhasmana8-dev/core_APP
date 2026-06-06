import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/reel_model.dart';

class ReelsEarnViewModel extends ChangeNotifier {
  bool loading = false;
  int currentIndex = 0;
  List<ReelEarnModel> reels = [];

  final String baseUrl =
      'https://core-backend-38rr.onrender.com/api/reels';

  final String authBaseUrl =
      'https://core-backend-38rr.onrender.com';

  final String engagementBase =
      'https://core-backend-38rr.onrender.com/api/reel-engagement';

  // ================= TOKEN =================
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("user_token");
  }

  // ================= LOAD REELS =================
  Future<void> loadReels() async => _fetchReels();
  Future<void> loadStudyReels() async => _fetchReels(type: 'Study');
  Future<void> loadPYQReels() async => _fetchReels(type: 'PYQ');

  // ================= FILTERS =================
  Map<String, List<String>> filters = {};

  // ================= FETCH REELS =================
  Future<void> _fetchReels({String? type}) async {
    loading = true;
    notifyListeners();

    try {
      final token = await _getToken();

      String url = baseUrl;
      if (type != null && type.isNotEmpty) {
        url = '$baseUrl?type=$type';
      }

      final res = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (data['success'] == true && data['reels'] != null) {
          final List list = data['reels'];

          final temp = <ReelEarnModel>[];

          for (var item in list) {
            final teacher = item['teacher_id'] ?? {};
            final stats = item['stats'] ?? {};

            final videoUrl =
            (item['video_url'] ?? '').toString().trim().isNotEmpty
                ? item['video_url']
                : (item['hls_master_url'] ?? '').toString().trim();

            if (videoUrl.toString().isEmpty) continue;
            debugPrint(
                "REEL=${item['_id']} "
                    "LIKED=${item['isLiked']} "
                    "SAVED=${item['isSaved']}"
            );
            temp.add(ReelEarnModel(
              reelId: item['_id'] ?? '',
              videoUrl: videoUrl,
              thumbnail: item['thumbnail_url'] ?? '',
              title: item['title'] ?? '',
              description: item['description'] ?? '',
              likes: stats['likes'] ?? item['total_likes'] ?? 0,
              type: item['is_pyq'] == true ? "PYQ" : "Study",
              teacherName: teacher['teacherName'] ?? '',
              teacherUsername: teacher['email'] ?? '',
              teacherProfile: teacher['profile_image'] ?? '',
              tags: List<String>.from(item['tags'] ?? []),
              isLiked: item['isLiked'] ?? false,
              isSaved: item['isSaved'] ?? false,
            ));
          }

          reels = temp;
        } else {
          _fallback();
        }
      } else {
        _fallback();
      }
    } catch (e) {
      debugPrint("ERROR => $e");
      _fallback();
    }

    loading = false;
    notifyListeners();
  }

  void _fallback() {
    reels = [
      ReelEarnModel(
        reelId: "fallback",
        videoUrl:
        "https://vz-fd5fa6c8-ece.b-cdn.net/39f61af3-3e12-4687-86e2-d10c16ede091/playlist.m3u8",
        title: "Physics Kinematics",
        description: "Learn basics",
        likes: 1200,
        type: "Study",
        tags: ["physics"],
      ),
    ];
  }

  // ================= SAVE REEL =================
  Future<void> saveReel(int index) async {
    final reel = reels[index];

    final oldSaved = reel.isSaved;

    reels[index] = reel.copyWith(isSaved: !oldSaved);
    notifyListeners();

    try {
      final token = await _getToken();

      final res = await http.post(
        Uri.parse('$authBaseUrl/api/save-reels/save'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"reelId": reel.reelId}),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        reels[index] = reel.copyWith(
          isSaved: data['isSaved'] ?? !oldSaved,
        );
        notifyListeners();
      } else {
        throw Exception("failed");
      }
    } catch (e) {
      reels[index] = reel.copyWith(isSaved: oldSaved);
      notifyListeners();
    }
  }
  // ================= LIKE =================
  Future<void> like(int index) async {
    final reel = reels[index];

    final oldLiked = reel.isLiked;
    final oldLikes = reel.likes;

    // Optimistic UI update
    reels[index] = reel.copyWith(
      isLiked: true,
      likes: oldLiked ? oldLikes : oldLikes + 1,
    );
    notifyListeners();

    try {
      final token = await _getToken();

      final res = await http.post(
        Uri.parse('$engagementBase/like/${reel.reelId}'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);

        reels[index] = reels[index].copyWith(
          isLiked: true,
          likes: data['totalLikes'] ?? reels[index].likes,
        );

        notifyListeners();
      } else {
        throw Exception("Like failed");
      }
    } catch (e) {
      // Rollback
      reels[index] = reel.copyWith(
        isLiked: oldLiked,
        likes: oldLikes,
      );
      notifyListeners();

      debugPrint("Like Error: $e");
    }
  }

// ================= UNLIKE =================
  Future<void> unlike(int index) async {
    final reel = reels[index];

    final oldLiked = reel.isLiked;
    final oldLikes = reel.likes;

    // Optimistic UI update
    reels[index] = reel.copyWith(
      isLiked: false,
      likes: oldLiked && oldLikes > 0
          ? oldLikes - 1
          : oldLikes,
    );

    notifyListeners();

    try {
      final token = await _getToken();

      final res = await http.delete(
        Uri.parse('$engagementBase/unlike/${reel.reelId}'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200 || res.statusCode == 204) {
        Map<String, dynamic>? data;

        if (res.body.isNotEmpty) {
          data = jsonDecode(res.body);
        }

        reels[index] = reels[index].copyWith(
          isLiked: false,
          likes: data?['totalLikes'] ?? reels[index].likes,
        );

        notifyListeners();
      } else {
        throw Exception("Unlike failed");
      }
    } catch (e) {
      // Rollback
      reels[index] = reel.copyWith(
        isLiked: oldLiked,
        likes: oldLikes,
      );

      notifyListeners();

      debugPrint("Unlike Error: $e");
    }
  }

// ================= SHARE =================
  Future<void> shareReel(String videoId) async {
    await _post(
      '$engagementBase/share/$videoId',
      {},
    );
  }
  // ================= VIEW =================
  Future<void> viewReel(String videoId) async {
    await _post(
      '$engagementBase/view/$videoId',
      {},
    );
  }
// ================= DOWNLOAD =================
  // ================= DOWNLOAD =================
  Future<String?> downloadReel(String reelId) async {
    try {
      final token = await _getToken();

      final res = await http.post(
        Uri.parse('$engagementBase/download/$reelId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint("DOWNLOAD STATUS => ${res.statusCode}");
      debugPrint("DOWNLOAD BODY => ${res.body}");

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);

        return data["download_url"];
      }
    } catch (e) {
      debugPrint("DOWNLOAD ERROR => $e");
    }

    return null;
  }
  // ================= CONTINUE WATCHING =================
  Future<void> saveContinueWatching({
    required String videoId,
    required int watchedSeconds,
    required int durationSeconds,
  }) async {
    await _post(
      'http://192.168.1.8:5000/api/continue-watching/save',
      {
        "videoId": videoId,
        "watchedSeconds": watchedSeconds,
        "durationSeconds": durationSeconds,
      },
    );
  }

  // ================= GENERIC POST =================
  Future<bool> _post(String url, Map body) async {
    try {
      final token = await _getToken();

      final res = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print("POST URL => $url");
      print("POST STATUS => ${res.statusCode}");
      print("POST BODY => ${res.body}");

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      print("POST ERROR => $e");
      return false;
    }
  }
  Future<List<Map<String, dynamic>>> fetchComments(
      String videoId,
      ) async {
    try {
      final token = await _getToken();

      final res = await http.get(
        Uri.parse(
          '$engagementBase/comments/$videoId',
        ),
        headers: {
          'Content-Type': 'application/json',
          if (token != null)
            'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        return List<Map<String, dynamic>>.from(
          (data["comments"] ?? []).map(
                (item) => {
              "id": item["_id"],
              "userName":
              item["user_id"]?["name"] ??
                  "Anonymous User",
              "comment":
              item["comment_text"] ?? "",
              "createdAt":
              item["createdAt"] ?? "",
            },
          ),
        );
      }
    } catch (e) {
      debugPrint("COMMENT ERROR => $e");
    }

    return [];
  }
  Future<bool> commentReel(
      String videoId,
      String comment,
      ) async {
    try {
      final token = await _getToken();

      final res = await http.post(
        Uri.parse(
          '$engagementBase/comment/$videoId',
        ),
        headers: {
          'Content-Type': 'application/json',
          if (token != null)
            'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "comment_text": comment,
        }),
      );

      debugPrint("STATUS => ${res.statusCode}");
      debugPrint("BODY => ${res.body}");

      return res.statusCode == 200 ||
          res.statusCode == 201;
    } catch (e) {
      debugPrint("COMMENT POST ERROR => $e");
      return false;
    }
  }
  void changePage(int index) {
    currentIndex = index;
    notifyListeners();
  }
}

