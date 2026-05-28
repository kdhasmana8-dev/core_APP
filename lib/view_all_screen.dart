import 'package:flutter/material.dart';
import '../model/teacher_model.dart';

class ViewAllScreen extends StatelessWidget {
  final String title;
  final List<Topic> topics;

  const ViewAllScreen({super.key, required this.title, required this.topics});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: topics.isEmpty
          ? const Center(child: Text("No content available", style: TextStyle(color: Colors.white54)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];
          return _buildTopicItem(topic);
        },
      ),
    );
  }

  Widget _buildTopicItem(Topic topic) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail container
          Stack(
            alignment: Alignment.topLeft,
            children: [
              Container(
                height: 85,
                width: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[800], // Placeholder color
                  image: topic.thumbnailUrl.isNotEmpty
                      ? DecorationImage(image: NetworkImage(topic.thumbnailUrl), fit: BoxFit.cover)
                      : null,
                ),
              ),
              // Dynamic Lock Icon based on model
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Icon(
                    topic.isLocked ? Icons.lock : Icons.play_arrow,
                    color: Colors.white.withOpacity(0.9),
                    size: 18
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Text details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  "${topic.duration}  •  ${topic.educator}",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

