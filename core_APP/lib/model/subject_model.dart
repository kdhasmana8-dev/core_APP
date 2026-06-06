// lib/model/section_model.dart
import 'package:flutter/material.dart';

class SubjectSectionResponse {
  final bool success;
  final int total;
  final List<SubjectSection> sections;

  SubjectSectionResponse({
    required this.success,
    required this.total,
    required this.sections,
  });

  factory SubjectSectionResponse.fromJson(Map<String, dynamic> json) {
    return SubjectSectionResponse(
      success: json['success'] ?? false,
      total: json['total'] ?? 0,
      sections: (json['sections'] as List?)
          ?.map((section) => SubjectSection.fromJson(section))
          .toList() ??
          [],
    );
  }
}

class SubjectSection {
  final String id;
  final String title;
  final String subtitle;
  final String type;
  final String bannerImage;
  final bool isActive;
  final bool showViewAll;
  final List<SubjectItem> subjects; // Changed from chapters to subjects
  final int position;
  final int columns;
  final bool isHorizontal;
  final String exam;

  SubjectSection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.bannerImage,
    required this.isActive,
    required this.showViewAll,
    required this.subjects,
    required this.position,
    required this.columns,
    required this.isHorizontal,
    required this.exam,
  });

  // Check if section has any content (subjects)
  bool get hasContent {
    return subjects.isNotEmpty;
  }

  int get totalSubjects => subjects.length;

  factory SubjectSection.fromJson(Map<String, dynamic> json) {
    List<SubjectItem> parsedSubjects = [];

    if (json['subjects'] != null && json['subjects'] is List) {
      parsedSubjects = (json['subjects'] as List)
          .map((subject) => SubjectItem.fromJson(subject))
          .toList();
    }

    return SubjectSection(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      type: json['type'] ?? 'subject',
      bannerImage: json['bannerImage'] ?? '',
      isActive: json['isActive'] ?? false,
      showViewAll: json['showViewAll'] ?? true,
      subjects: parsedSubjects,
      position: json['position'] ?? 0,
      columns: json['columns'] ?? 2,
      isHorizontal: json['isHorizontal'] ?? true,
      exam: json['exam'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'subtitle': subtitle,
      'type': type,
      'bannerImage': bannerImage,
      'isActive': isActive,
      'showViewAll': showViewAll,
      'subjects': subjects.map((s) => s.toJson()).toList(),
      'position': position,
      'columns': columns,
      'isHorizontal': isHorizontal,
      'exam': exam,
    };
  }
}

// Add this to your section_model.dart
class SubjectItem {
  final String id;
  final String examID;

  final String name;
  final String description;
  final String image;
  final String icon;
  final String status;

  final int totalVideos;
  final int totalChapters;

  final List<Chapter> chapters;
  final List<TopicItem> topics;

  SubjectItem({
    required this.id,
    required this.examID,
    required this.name,
    required this.description,
    required this.image,
    required this.icon,
    required this.status,
    this.totalVideos = 0,
    this.totalChapters = 0,
    this.chapters = const [],
    this.topics = const [],
  });

  factory SubjectItem.fromJson(Map<String, dynamic> json) {
    debugPrint("SubjectItem.fromJson => ${json['name']}");

    List<Chapter> parsedChapters = [];
    if (json['chapters'] != null && json['chapters'] is List) {
      parsedChapters = (json['chapters'] as List)
          .map((chapter) => Chapter.fromJson(chapter))
          .toList();
    }

    List<TopicItem> parsedTopics = [];
    if (json['topics'] != null && json['topics'] is List) {
      parsedTopics = (json['topics'] as List)
          .map((topic) => TopicItem.fromJson(topic))
          .toList();
    }

    return SubjectItem(
      id: json['_id'] ?? '',
      examID: json['examId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      icon: json['icon'] ?? '',
      status: json['status'] ?? 'Active',
      totalVideos: json['totalVideos'] ?? 0,
      totalChapters: json['totalChapters'] ?? 0,
      chapters: parsedChapters,
      topics: parsedTopics,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'examId': examID,
      'name': name,
      'description': description,
      'image': image,
      'icon': icon,
      'status': status,
      'totalVideos': totalVideos,
      'totalChapters': totalChapters,
      'chapters': chapters.map((c) => c.toJson()).toList(),
      'topics': topics.map((t) => t.toJson()).toList(),
    };
  }
}
// Keep Chapter and TopicItem for backward compatibility if needed
class Chapter {
  final String? id;
  final String name;

  Chapter({
    this.id,
    required this.name,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['_id'],
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }
}

class TopicItem {
  final String id;
  final String chapterId;
  final String name;

  final int totalVideos;
  final List<Video> videos;

  final String? thumbnailUrl;
  final String? duration;
  final String? educator;

  TopicItem({
    required this.id,
    required this.chapterId,
    required this.name,
    this.totalVideos = 0,
    this.videos = const [],
    this.thumbnailUrl,
    this.duration,
    this.educator,
  });

  factory TopicItem.fromJson(Map<String, dynamic> json) {
    List<Video> parsedVideos = [];

    if (json['videos'] != null && json['videos'] is List) {
      parsedVideos = (json['videos'] as List)
          .map((video) => Video.fromJson(video))
          .toList();
    }

    return TopicItem(
      id: json['_id'] ?? '',
      chapterId: json['chapterId'] ?? '',
      name: json['name'] ?? '',
      totalVideos: json['totalVideos'] ?? parsedVideos.length,
      videos: parsedVideos,
      thumbnailUrl: json['thumbnailUrl'],
      duration: json['duration'],
      educator: json['educator'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'chapterId': chapterId,
      'name': name,
      'totalVideos': totalVideos,
      'videos': videos.map((v) => v.toJson()).toList(),
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'educator': educator,
    };
  }
}

class Video {
  final String id;
  final String title;
  final String url;
  final String? thumbnail;
  final String? duration;

  Video({
    required this.id,
    required this.title,
    required this.url,
    this.thumbnail,
    this.duration,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      url: json['videoUrl'] ?? json['url'] ?? '',
      thumbnail: json['thumbnail'] ?? json['thumbnailUrl'],
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'videoUrl': url,
      'thumbnail': thumbnail,
      'duration': duration,
    };
  }
}

// Topic class for ViewAllScreen
class Topic {
  final String title;
  final String duration;
  final String educator;
  final String videoUrl;
  final String thumbnailUrl;

  Topic({
    required this.title,
    required this.duration,
    required this.educator,
    required this.videoUrl,
    required this.thumbnailUrl,
  });
}