class ReelEarnModel {
  final String videoUrl;
  final String reelId;
  final String title;
  final String description;
  final String thumbnail;
  final int likes;
  final bool isLiked;
  final bool isSaved;
  final String type;
  final String teacherName;
  final String teacherUsername;
  final String teacherProfile;
  final List<String> tags;

  ReelEarnModel({
    required this.videoUrl,
    required this.reelId,
    this.title = '',
    this.description = '',
    this.thumbnail = '',
    this.likes = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.type = '',
    this.teacherName = '',
    this.teacherUsername = '',
    this.teacherProfile = '',
    this.tags = const [],
  });

  ReelEarnModel copyWith({
    String? videoUrl,
    String? videoId,
    String? title,
    String? description,
    String? thumbnail,
    int? likes,
    bool? isLiked,
    bool? isSaved,
    String? type,
    String? teacherName,
    String? teacherUsername,
    String? teacherProfile,
    List<String>? tags,
  }) {
    return ReelEarnModel(
      videoUrl: videoUrl ?? this.videoUrl,
      reelId: videoId ?? this.reelId,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      type: type ?? this.type,
      teacherName: teacherName ?? this.teacherName,
      teacherUsername: teacherUsername ?? this.teacherUsername,
      teacherProfile: teacherProfile ?? this.teacherProfile,
      tags: tags ?? this.tags,
    );
  }
}