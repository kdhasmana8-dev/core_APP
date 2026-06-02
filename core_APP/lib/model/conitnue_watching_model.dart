class ContinueWatchingModel {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String videoUrl;
  final String progress;
  final String educator;

  ContinueWatchingModel({
    required this.id, required this.title, required this.thumbnailUrl,
    required this.videoUrl, required this.progress, required this.educator,
  });

  factory ContinueWatchingModel.fromJson(Map<String, dynamic> json) {
    return ContinueWatchingModel(
      id: json['id'],
      title: json['title'],
      thumbnailUrl: json['thumbnailUrl'] ?? "",
      videoUrl: json['videoUrl'],
      progress: json['progress'],
      educator: json['educator'],
    );
  }
}