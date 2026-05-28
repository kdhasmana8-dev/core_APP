import 'package:flutter/material.dart';
import '../model/reel_model.dart';

class ReelsEarnViewModel extends ChangeNotifier {
  bool loading = false;
  int currentIndex = 0;
  List<ReelEarnModel> reels = [];

  Future<void> loadReels() async {
    loading = true;
    notifyListeners();

    reels = [
      ReelEarnModel(
        videoUrl: "https://vz-fd5fa6c8-ece.b-cdn.net/39f61af3-3e12-4687-86e2-d10c16ede091/playlist.m3u8",
        likes: 12400,
      ),
      ReelEarnModel(
        videoUrl: "https://vz-fd5fa6c8-ece.b-cdn.net/6dabdd00-761e-4149-871d-4789d4fe75fc/playlist.m3u8",
        likes: 8500,
      ),
    ];

    loading = false;
    notifyListeners();
  }

  Future<void> loadStudyReels() async {
    loading = true;
    notifyListeners();

    reels = [
      ReelEarnModel(
        videoUrl: "https://vz-fd5fa6c8-ece.b-cdn.net/9280db5a-f3ca-4255-a8da-b7b2b4bc0764/playlist.m3u8",
        likes: 3200,
      ),
    ];

    loading = false;
    notifyListeners();
  }

  Future<void> loadPYQReels() async {
    loading = true;
    notifyListeners();

    reels = [
      ReelEarnModel(
        videoUrl: "https://vz-fd5fa6c8-ece.b-cdn.net/ec98e638-572b-4629-9bf8-db2302ae64f3/playlist.m3u8",
        likes: 1420,
      ),
    ];

    loading = false;
    notifyListeners();
  }

  void changePage(int index) {
    currentIndex = index;

    notifyListeners();
  }

  void like(int index) {
    if (index >= 0 && index < reels.length) {
      reels[index] = reels[index].copyWith(
        isLiked: !reels[index].isLiked,
        likes: reels[index].isLiked ? reels[index].likes - 1 : reels[index].likes + 1,
      );
      notifyListeners();
    }
  }
}