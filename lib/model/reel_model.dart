class ReelEarnModel {
  final String videoUrl;
  bool isLiked;
  int likes;

  ReelEarnModel({
    required this.videoUrl,
    this.isLiked = false,
    this.likes = 0,
  });

  ReelEarnModel copyWith({
    String? videoUrl,
    bool? isLiked,
    int? likes,
  }) {
    return ReelEarnModel(
      videoUrl: videoUrl ?? this.videoUrl,
      isLiked: isLiked ?? this.isLiked,
      likes: likes ?? this.likes,
    );
  }
}