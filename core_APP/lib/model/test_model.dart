class TestModel {
  final String id;
  final String title;
  final String category;
  final int questions;
  final int duration;
  final String imagePath;
  final List<String> instructions; // New field

  TestModel({
    required this.id,
    required this.title,
    required this.category,
    required this.questions,
    required this.duration,
    required this.imagePath,
    required this.instructions,

  });

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? 'Untitled Test',
      // Ab 'category' field ka use kar rahe hain
      category: json['category'] != null ? json['category']['name'] : 'General',
      questions: json['totalQuestions'] ?? 0,
      duration: json['duration'] ?? 0,
      imagePath: json['imagePath'] ?? '',
      instructions: List<String>.from(json['instructions'] ?? []),
    );
  }
}
class QuestionModel {

  final String id;
  final String question;
  final List<String> options;
  final String subject;

  QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.subject,
  });

  factory QuestionModel.fromJson(
      Map<String, dynamic> json) {

    return QuestionModel(

      id: json['_id'] ?? "",

      question: json['question'] ?? "",

      options: List<String>.from(
        json['options'] ?? [],
      ),

      subject: json['subject'] ?? "",
    );
  }
}