import 'package:core_app/view/bottom_view_nav.dart';
import 'package:core_app/view/core_view_home.dart';
import 'package:core_app/view/performance_view_screen.dart';
import 'package:flutter/material.dart';

class ResultDashboardScreen extends StatelessWidget {
  final dynamic resultData;
  final String testId;

  const ResultDashboardScreen({
    super.key,
    required this.resultData,
    required this.testId,
  });

  @override
  Widget build(BuildContext context) {
    // Keeping your original logic intact
    final performance = resultData['performance'] ?? {};
    final List results = resultData['results'] ?? [];
    final int totalQuestions = int.tryParse(performance['total_questions'].toString()) ?? 0;
    final int correct = int.tryParse(performance['correct_answers'].toString()) ?? 0;
    final int wrong = int.tryParse(performance['wrong_answers'].toString()) ?? 0;
    final double score = double.tryParse(performance['score'].toString()) ?? 0;
    final double percentage = double.tryParse(performance['percentage'].toString()) ?? 0;
    final int attempted = correct + wrong;
    final int skipped = totalQuestions - attempted;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("Result dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Score + Metrics
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildMetricCard("Score", "${score.toInt()}", "/$totalQuestions", Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildSmallMetric("Accuracy", "${percentage.toInt()}%", Colors.greenAccent),
                      const SizedBox(height: 8),
                      _buildSmallMetric("Attempted", "$attempted/$totalQuestions", Colors.purpleAccent),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section Title
            const Text("Question Review", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Question List
            ...results.map((item) {
              final bool isCorrect = item['is_correct'] == true;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xff111111),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: (isCorrect ? Colors.green : Colors.red).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['question'] ?? "", style: const TextStyle(color: Colors.white, fontSize: 16)),
                    const Divider(color: Colors.white24, height: 24),
                    _buildReviewRow("Your Answer:", item['selected_option']?.toString() ?? "-", Colors.white70),
                    _buildReviewRow("Correct Answer:", item['correct_answer']?.toString() ?? "-", Colors.greenAccent),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MainShellDashboard())),
          child: const Text("View Performance Overview", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, String subValue, Color color) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xff111111), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.5))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          Text(subValue, style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildSmallMetric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xff111111), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}