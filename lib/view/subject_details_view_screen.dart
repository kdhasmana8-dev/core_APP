import 'package:flutter/material.dart';

class SubjectDetailsScreen extends StatelessWidget {
  final String subjectName;

  const SubjectDetailsScreen({
    super.key,
    required this.subjectName,
  });

  List<Map<String, dynamic>> getTopics() {
    switch (subjectName) {
      case "Physics":
        return [
          {
            "title": "Units & Dimensions",
            "duration": "12 min",
            "locked": false,
          },
          {
            "title": "Motion In One Dimension",
            "duration": "18 min",
            "locked": true,
          },
          {
            "title": "Laws Of Motion",
            "duration": "20 min",
            "locked": true,
          },
          {
            "title": "Work Power Energy",
            "duration": "15 min",
            "locked": true,
          },
        ];

      case "Chemistry":
        return [
          {
            "title": "Mole Concept",
            "duration": "10 min",
            "locked": true,
          },
          {
            "title": "Atomic Structure",
            "duration": "1:46 min",
            "locked": false,
          },
          {
            "title": "Chemical Thermodynamics",
            "duration": "12 min",
            "locked": true,
          },
          {
            "title": "Chemical Equilibrium",
            "duration": "9 min",
            "locked": true,
          },
          {
            "title": "Redox Reactions",
            "duration": "14 min",
            "locked": true,
          },
        ];

      default:
        return [
          {
            "title": "Introduction",
            "duration": "10 min",
            "locked": false,
          }
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final topics = getTopics();

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              subjectName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subjectName,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),

      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: topics.length,

        separatorBuilder: (_, __) {
          return const Divider(
            color: Colors.white10,
            height: 30,
          );
        },

        itemBuilder: (context, index) {
          final item = topics[index];

          return Row(
            children: [

              Container(
                width: 110,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xff0C1738),
                  borderRadius:
                  BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 40,
                    color: Colors.white38,
                  ),
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    Text(
                      item["title"],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    if (!item["locked"])
                      Text(
                        item["duration"],
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 15,
                        ),
                      ),
                  ],
                ),
              ),

              item["locked"]
                  ? const Icon(
                Icons.lock_outline,
                color: Colors.white38,
                size: 38,
              )
                  : Container(
                width: 55,
                height: 55,
                decoration:
                const BoxDecoration(
                  color: Color(0xff6D86FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}