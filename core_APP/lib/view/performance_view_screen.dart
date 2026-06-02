import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PerformanceOverviewCard extends StatefulWidget {
  const PerformanceOverviewCard({super.key});

  @override
  State<PerformanceOverviewCard> createState() => _PerformanceOverviewCardState();
}

class _PerformanceOverviewCardState extends State<PerformanceOverviewCard> {
  bool isLoading = true;
  int totalAttempts = 0;
  double overallAccuracy = 0;
  int totalCorrect = 0;
  List<Map<String, dynamic>> processedSubjects = [];

  @override
  void initState() {
    super.initState();
    fetchPerformanceData();
  }

  Future<void> fetchPerformanceData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("user_token") ?? "";

      final response = await http.get(
        Uri.parse("https://core-backend-38rr.onrender.com/api/test-attempt/performance-analysis"),
        headers: {"Authorization": "Bearer $token", "Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          totalAttempts = data['totalAttempts'] ?? 0;
          List rawSubjects = data['subjectAnalysis'] ?? [];

          // Grouping logic for duplicate subjects (e.g., 'physics' and 'Physics')
          Map<String, Map<String, dynamic>> groupMap = {};
          int grandCorrect = 0;
          int grandTotal = 0;

          for (var item in rawSubjects) {
            String subName = item['subject'].toString().toLowerCase();
            int corr = int.tryParse(item['correct'].toString()) ?? 0;
            int wrong = int.tryParse(item['wrong'].toString()) ?? 0;
            int total = int.tryParse(item['total'].toString()) ?? 0;

            if (!groupMap.containsKey(subName)) {
              groupMap[subName] = {'subject': item['subject'], 'correct': 0, 'wrong': 0, 'total': 0};
            }
            groupMap[subName]!['correct'] += corr;
            groupMap[subName]!['wrong'] += wrong;
            groupMap[subName]!['total'] += total;

            grandCorrect += corr;
            grandTotal += total;
          }

          processedSubjects = groupMap.values.map((e) {
            double acc = e['total'] > 0 ? (e['correct'] / e['total']) * 100 : 0;
            e['accuracy'] = acc.toStringAsFixed(1);
            e['weak'] = acc < 50; // Logic for weak area
            return e;
          }).toList();

          totalCorrect = grandCorrect;
          overallAccuracy = grandTotal > 0 ? (grandCorrect / grandTotal) * 100 : 0;
        }
      }
    } catch (e) {
      debugPrint("PERFORMANCE ERROR => $e");
    }
    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator(color: Colors.orange));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("PERFORMANCE OVERVIEW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(onPressed: () {}, child: const Text("View all", style: TextStyle(color: Colors.white, fontSize: 12))),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _scoreCard("Attempts", totalAttempts.toString())),
              const SizedBox(width: 10),
              Expanded(child: _scoreCard("Correct", totalCorrect.toString())),
              const SizedBox(width: 10),
              Expanded(child: _scoreCard("Accuracy", "${overallAccuracy.toStringAsFixed(1)}%")),
            ],
          ),
          const SizedBox(height: 24),
          const Text("Subject Analysis", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          ...processedSubjects.map((sub) => _buildSubjectTile(sub)),
        ],
      ),
    );
  }

  Widget _buildSubjectTile(Map sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(sub['subject'], style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            Text("Correct: ${sub['correct']}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text("${sub['accuracy']}%", style: TextStyle(color: sub['weak'] ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
            Text("Wrong: ${sub['wrong']}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ]),
        ],
      ),
    );
  }

  Widget _scoreCard(String title, String score) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          Text(score, style: const TextStyle(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}