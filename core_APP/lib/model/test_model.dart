class AssessmentModel {
  final String id;
  final String title;
  final String type;
  final int duration;
  final int totalQuestions;
  final bool negativeMarking;
  final bool leaderboardEnabled;
  final bool isPro;
  final String thumbnailUrl;

  final String examName;
  final String subjectName;
  final String chapterName;
  final String topicName;

  final List<QuestionModel> questions;

  AssessmentModel({
    required this.id,
    required this.title,
    required this.type,
    required this.duration,
    required this.totalQuestions,
    required this.negativeMarking,
    required this.leaderboardEnabled,
    required this.isPro,
    required this.thumbnailUrl,
    required this.examName,
    required this.subjectName,
    required this.chapterName,
    required this.topicName,
    required this.questions,
  });

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      duration: json['duration'] ?? 0,

      totalQuestions: (json['questions'] as List?)?.length ??
          json['total_questions'] ??
          0,

      negativeMarking: json['negative_marking'] ?? false,
      leaderboardEnabled: json['leaderboard_enabled'] ?? false,
      isPro: json['is_pro'] ?? false,
      thumbnailUrl: json['thumbnail_url'] ?? '',

      examName: json['exam_id']?['name'] ?? '',
      subjectName: json['subject_id']?['name'] ?? '',
      chapterName: json['chapter_id']?['name'] ?? '',
      topicName: json['topic_id']?['name'] ?? '',

      questions: (json['questions'] as List?)
          ?.map((e) => QuestionModel.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class QuestionModel {
  final String id;
  final String questionText;
  final List<OptionModel> options;
  final String correctAnswer;
  final String explanation;
  final int marks;
  final int negativeMarks;
  final String difficulty;

  QuestionModel({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.marks,
    required this.negativeMarks,
    required this.difficulty,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['_id'] ?? '',
      questionText: json['question_text'] ?? '',
      correctAnswer: json['correct_answer'] ?? '',
      explanation: json['explanation'] ?? '',
      marks: json['marks'] ?? 0,
      negativeMarks: json['negative_marks'] ?? 0,
      difficulty: json['difficulty'] ?? '',

      options: _parseOptions(json['options']),
    );
  }

  // 🔥 SAFE OPTION PARSER (IMPORTANT FIX)
  static List<OptionModel> _parseOptions(dynamic optionsJson) {
    List<OptionModel> optionsList = [];

    if (optionsJson == null) return optionsList;

    if (optionsJson is List) {
      for (var item in optionsJson) {
        if (item is Map<String, dynamic>) {

          // New API Format
          if (item.containsKey('option') && item.containsKey('text')) {
            optionsList.add(
              OptionModel(
                id: item['_id']?.toString() ?? '',
                option: item['option']?.toString() ?? '',
                text: item['text']?.toString() ?? '',
              ),
            );
          }

          // Old API Format
          else if (item.containsKey('A') ||
              item.containsKey('B') ||
              item.containsKey('C') ||
              item.containsKey('D')) {

            ['A', 'B', 'C', 'D'].forEach((key) {
              if (item[key] != null) {
                optionsList.add(
                  OptionModel(
                    id: item['_id']?.toString() ?? '',
                    option: key,
                    text: item[key].toString(),
                  ),
                );
              }
            });
          }
        }
      }
    }

    return optionsList;
  }
}

class OptionModel {
  final String id;
  final String option;
  final String text;

  OptionModel({
    required this.id,
    required this.option,
    required this.text,
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      id: json['_id']?.toString() ?? '',
      option: json['option']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
    );
  }
}