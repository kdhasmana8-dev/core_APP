class Teacher {
  final String id;
  final String name;
  final String subject;
  final String imageUrl;
  final String description;
  final String email;
  final int experience;
  final String phone;
  final String qualification;
  final String status;
  final List<String> subjects;
  final List<Reel> reels; // New field


  Teacher({
    required this.id,
    required this.name,
    required this.subject,
    required this.imageUrl,
    required this.description,
    required this.email,
    required this.experience,
    required this.phone,
    required this.qualification,
    required this.status,
    required this.subjects,
    this.reels = const [],
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['_id'] ?? "",
      name: json['teacherName'] ?? "",
      subject: json['subject'] ?? "",
      imageUrl: json['profileImage'] ?? "",
      description: json['description'] ?? "",
      email: json['email'] ?? "",
      experience: json['experience'] ?? 0,
      phone: json['phone'] ?? "",
      qualification: json['qualification'] ?? "",
      status: json['status'] ?? "",
      subjects: List<String>.from(json['subjects'] ?? []),
      reels: (json['reels'] as List<dynamic>?)
          ?.map((e) => Reel.fromJson(e))
          .toList() ?? [],
    );
  }
}

class Reel {
  final String id;
  final String title;
  final String videoUrl;
  final String subject;
  final String topic;
  final String chapter; // Added
  final String type;    // Added

  Reel({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.subject,
    required this.topic,
    required this.chapter,
    required this.type,
  });

  factory Reel.fromJson(Map<String, dynamic> json) {
    return Reel(
      id: json['_id'] ?? "",
      title: json['title'] ?? "",
      videoUrl: json['videoUrl'] ?? "",
      subject: json['subject'] ?? "",
      topic: json['topic'] ?? "",
      chapter: json['chapter'] ?? "",
      type: json['type'] ?? "Study",
    );
  }
}
class Chapter {
  final String title;
  final List<Topic> topics;

  Chapter({required this.title, required this.topics});

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      title: json['title'] ?? "",
      topics: (json['topics'] as List<dynamic>?)
          ?.map((e) => Topic.fromJson(e))
          .toList() ?? [],
    );
  }
}

class Topic {
  final String title;
  final String duration;
  final String educator;
  final String videoUrl;
  final String thumbnailUrl;
  final bool isLocked;

  Topic({
    required this.title,
    required this.duration,
    required this.educator,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.isLocked = true,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      title: json['title'] ?? "",
      duration: json['duration'] ?? "",
      educator: json['educator'] ?? "",
      videoUrl: json['videoUrl'] ?? "",
      thumbnailUrl: json['thumbnailUrl'] ?? "",
      isLocked: json['isLocked'] ?? true,
    );
  }
}