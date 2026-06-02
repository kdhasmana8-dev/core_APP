
import 'package:core_app/view/reel_view_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/subject_model.dart';

class SubjectDetailsScreen extends StatelessWidget {
  final String subjectName;
  final SubjectSection? subjectSection;
  final SubjectItem? subjectItem;
  final TopicItem? topic;

  const SubjectDetailsScreen({
    super.key,
    required this.subjectName,
    this.subjectSection,
    this.subjectItem,
    this.topic,
  });

  List<Map<String, dynamic>> getTopics() {
    if (topic != null) {
      return [
        {
          "title": topic!.name,
          "duration": topic!.duration ?? "${topic!.totalVideos * 10} min",
          "locked": false,
          "totalVideos": topic!.totalVideos,
          "thumbnail": topic!.thumbnailUrl ?? "",
          "description": "Learn ${topic!.name} with detailed explanations",
          "videos": topic!.videos,
        }
      ];
    }

    if (subjectItem != null) {
      if (subjectItem!.chapters.isNotEmpty) {
        List<Map<String, dynamic>> chapterTopics = [];
        for (var chapter in subjectItem!.chapters) {
          chapterTopics.add({
            "title": chapter.name,
            "duration": _calculateChapterDuration(chapter),
            "locked": false,
            "totalVideos": chapter.topics.fold(0, (sum, t) => sum + t.totalVideos),
            "thumbnail": subjectItem!.image,
            "description": "Master ${chapter.name} with detailed video lectures",
            "chapters": chapter,
            "topics": chapter.topics,
          });
        }
        return chapterTopics;
      }

      // Agar chapters nahi hain to subject ko hi ek topic bana do
      return [
        {
          "title": subjectItem!.name,
          "duration": "${subjectItem!.totalVideos * 10} min",
          "locked": false,
          "totalVideos": subjectItem!.totalVideos,
          "thumbnail": subjectItem!.image,
          "description": subjectItem!.description,
        }
      ];
    }


    if (subjectSection != null && subjectSection!.subjects.isNotEmpty) {
      return subjectSection!.subjects.map((subject) {
        return {
          "title": subject.name,
          "duration": "${subject.totalVideos * 10} min",
          "locked": false,
          "totalVideos": subject.totalVideos,
          "thumbnail": subject.image,
          "description": subject.description,
          "subjectId": subject.id,
          "subject": subject,
        };
      }).toList();
    }

    return [];
  }

  String _calculateChapterDuration(Chapter chapter) {
    int totalMinutes = 0;
    for (var topic in chapter.topics) {
      if (topic.duration != null) {
        int minutes = int.tryParse(topic.duration!.split(' ')[0]) ?? 10;
        totalMinutes += minutes;
      } else {
        totalMinutes += topic.totalVideos * 10;
      }
    }
    return "$totalMinutes min";
  }

  int getTotalVideos(List<Map<String, dynamic>> topics) {
    return topics.fold(0, (sum, item) {
      int count = item["totalVideos"] ?? 1;
      count = count.toInt();
      return sum + count;
    });
  }

  String getTotalDuration(List<Map<String, dynamic>> topics) {
    int totalMinutes = 0;
    for (var topic in topics) {
      String duration = topic["duration"] ?? "0 min";
      String minutesStr = duration.split(' ')[0];
      int minutes = int.tryParse(minutesStr) ?? 0;
      totalMinutes += minutes;
    }

    if (totalMinutes >= 60) {
      int hours = totalMinutes ~/ 60;
      int minutes = totalMinutes % 60;
      return "$hours hr ${minutes > 0 ? "$minutes min" : ""}";
    }
    return "$totalMinutes min";
  }

  @override
  Widget build(BuildContext context) {
    final topics = getTopics();
    final totalVideos = getTotalVideos(topics);
    final totalDuration = getTotalDuration(topics);

    // Banner image
    String bannerImage = '';
    if (subjectSection?.bannerImage.isNotEmpty ?? false) {
      bannerImage = subjectSection!.bannerImage;
    } else if (subjectItem?.image.isNotEmpty ?? false) {
      bannerImage = subjectItem!.image;
    }

    // Title
    String displayTitle = subjectName;
    if (topic != null) {
      displayTitle = topic!.name;
    } else if (subjectItem != null) {
      displayTitle = subjectItem!.name;
    } else if (subjectSection != null) {
      displayTitle = subjectSection!.title;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (topic == null) ...[
              Text(
                "$totalVideos videos • $totalDuration",
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: topics.isEmpty
          ? const Center(
        child: Text(
          "No topics available",
          style: TextStyle(color: Colors.white54),
        ),
      )
          : Column(
        children: [
          if (bannerImage.isNotEmpty)
            Container(
              height: 120,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(bannerImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: topics.length,
              separatorBuilder: (_, _) => const Divider(color: Colors.white10, height: 30),
              itemBuilder: (context, index) {
                final item = topics[index];
                final isLocked = item["locked"] ?? false;
                final videoCount = (item["totalVideos"] ?? 1) as int;

                return Row(
                  children: [
                    // Thumbnail
                    Container(
                      width: 110,
                      height: 150,
                      decoration: BoxDecoration(
                        color: const Color(0xff0C1738),
                        borderRadius: BorderRadius.circular(18),
                        image: item["thumbnail"] != null && item["thumbnail"].toString().isNotEmpty
                            ? DecorationImage(
                          image: NetworkImage(item["thumbnail"]),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: item["thumbnail"] == null || item["thumbnail"].toString().isEmpty
                          ? const Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          size: 40,
                          color: Colors.white38,
                        ),
                      )
                          : null,
                    ),
                    const SizedBox(width: 18),
                    // Title and info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item["title"],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (item["description"] != null && item["description"].toString().isNotEmpty)
                            Text(
                              item["description"],
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 4),
                          if (!isLocked)
                            Row(
                              children: [
                                const Icon(
                                  Icons.play_circle_outline,
                                  color: Colors.white54,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item["duration"],
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.video_library,
                                  color: Colors.white54,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "$videoCount videos",
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    // Play button
                    if (!isLocked)
                      GestureDetector(
                        onTap: () {
                          _onTopicTap(context, item);
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: Color(0xff6D86FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onTopicTap(BuildContext context, Map<String, dynamic> item) {
    // Agar yeh chapter hai aur uske andar topics hain
    if (item.containsKey("topics") && item["topics"] is List && (item["topics"] as List).isNotEmpty) {
      // Chapter Topics screen dikhao
      _showChapterTopics(context, item);
    }
    // Agar yeh subject hai
    else if (item.containsKey("subject") && item["subject"] is SubjectItem) {
      final subject = item["subject"] as SubjectItem;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SubjectDetailsScreen(
            subjectName: subject.name,
            subjectItem: subject,
          ),
        ),
      );
    }
    // Direct video play
    else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ReelsEarnScreen(
            isVisible: true,
            initialType: "Study",
          ),
        ),
      );
    }
  }

  void _showChapterTopics(BuildContext context, Map<String, dynamic> chapterItem) {
    final topics = chapterItem["topics"] as List<TopicItem>;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xff1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    chapterItem["title"],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: topics.length,
                    separatorBuilder: (_, _) => const Divider(color: Colors.white10),
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      return ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xff0C1738),
                            borderRadius: BorderRadius.circular(12),
                            image: topic.thumbnailUrl != null && topic.thumbnailUrl!.isNotEmpty
                                ? DecorationImage(
                              image: NetworkImage(topic.thumbnailUrl!),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                          child: topic.thumbnailUrl == null || topic.thumbnailUrl!.isEmpty
                              ? const Icon(Icons.play_circle_outline, color: Colors.white54)
                              : null,
                        ),
                        title: Text(
                          topic.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          "${topic.totalVideos} videos",
                          style: const TextStyle(color: Colors.white54),
                        ),
                        trailing: const Icon(Icons.play_arrow, color: Color(0xff6D86FF)),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReelsEarnScreen(
                                isVisible: true,
                                initialType: "Study",
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}