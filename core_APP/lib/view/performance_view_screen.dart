import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PerformanceOverviewCard extends StatefulWidget {
  final String testId;

  const PerformanceOverviewCard({
    super.key,
    required this.testId,
  });

  @override
  State<PerformanceOverviewCard> createState() =>
      _PerformanceOverviewCardState();
}

class _PerformanceOverviewCardState extends State<PerformanceOverviewCard> {
  bool isLoading = true;

  int totalQuestions = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  double percentage = 0;

  List<Map<String, dynamic>> results = [];

  @override
  void initState() {
    super.initState();
    fetchPerformanceData();
  }

  Future<void> fetchPerformanceData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("user_token") ?? "";

      final url =
          "https://core-backend-38rr.onrender.com/api/assessments/submit/${widget.testId}";

      debugPrint("🌐 API URL => $url");
      debugPrint("🔑 TOKEN => $token");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      debugPrint("📩 RESPONSE BODY => ${response.body}");
      debugPrint("📊 STATUS CODE => ${response.statusCode}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final performance = data['performance'];

        setState(() {
          totalQuestions = performance['total_questions'] ?? 0;
          correctAnswers = performance['correct_answers'] ?? 0;
          wrongAnswers = performance['wrong_answers'] ?? 0;
          percentage =
              double.tryParse(performance['percentage'].toString()) ?? 0;

          results = List<Map<String, dynamic>>.from(data['results'] ?? []);
          isLoading = false;
        });
      } else {
        debugPrint("❌ API FAILED OR SUCCESS FALSE");
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("🔥 ERROR => $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: isLoading
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "PERFORMANCE OVERVIEW",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: _scoreCard("Total", "$totalQuestions")),
              const SizedBox(width: 10),
              Expanded(child: _scoreCard("Correct", "$correctAnswers")),
              const SizedBox(width: 10),
              Expanded(child: _scoreCard("Wrong", "$wrongAnswers")),
              const SizedBox(width: 10),
              Expanded(
                child: _scoreCard(
                  "Score",
                  "${percentage.toStringAsFixed(1)}%",
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Text(
            "Question Review",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ...results.map((q) => _buildResultTile(q)),
        ],
      ),
    );
  }

  Widget _buildResultTile(Map q) {
    bool isCorrect = q['is_correct'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q['question'] ?? "",
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            "Your: ${q['selected_option'] ?? 'Not Answered'}",
            style: TextStyle(
              color: isCorrect ? Colors.green : Colors.red,
            ),
          ),
          Text(
            "Correct: ${q['correct_answer'] ?? ''}",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _scoreCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}