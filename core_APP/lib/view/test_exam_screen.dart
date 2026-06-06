import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/test_model.dart';
import 'score_board_screen.dart';

class TestExamScreen extends StatefulWidget {
  final String testId;

  const TestExamScreen({super.key, required this.testId});

  @override
  State<TestExamScreen> createState() => _TestExamScreenState();
}

class _TestExamScreenState extends State<TestExamScreen> {
  List<QuestionModel> _questions = [];
  bool isLoading = true;
  Timer? _timer;
  int _remainingSeconds = 0;
  int _currentIndex = 0;
  late List<int?> _selectedAnswers;
  late List<bool> _isAnswered;

  @override
  void initState() {
    super.initState();
    fetchAssessment();
  }

  Future<void> fetchAssessment() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("user_token") ?? "";

      final response = await http.get(
        Uri.parse('https://core-backend-38rr.onrender.com/api/assessments'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final List assessments = data['assessments'];

        Map<String, dynamic>? selectedAssessment;

        for (var assessment in assessments) {
          if (assessment['_id'] == widget.testId) {
            selectedAssessment = assessment;
            break;
          }
        }

        if (selectedAssessment != null &&
            selectedAssessment['questions'] != null) {
          _questions = (selectedAssessment['questions'] as List)
              .map((e) => QuestionModel.fromJson(e))
              .toList();
        }

        _selectedAnswers =
        List<int?>.generate(_questions.length, (_) => null);

        _isAnswered =
        List<bool>.generate(_questions.length, (_) => false);
      }
    } catch (e) {
      debugPrint("FETCH ERROR => $e");
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }
  void startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          timer.cancel();
          submitTest();
        }
      },
    );
  }

  String get formattedTime {
    final minutes =
    (_remainingSeconds ~/ 60).toString().padLeft(2, '0');

    final seconds =
    (_remainingSeconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }
  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      submitTest();
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  Future<void> submitTest() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("user_token") ?? "";

      List<Map<String, dynamic>> answers = [];

      for (int i = 0; i < _questions.length; i++) {
        final selectedIndex = _selectedAnswers[i];

        answers.add({
          "question_id": _questions[i].id,
          "selected_option": selectedIndex != null
              ? _questions[i].options[selectedIndex].option
              : null,
        });
      }

      final body = {"answers": answers};

      final response = await http.post(
        Uri.parse(
            'https://core-backend-38rr.onrender.com/api/assessments/submit/${widget.testId}'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultDashboardScreen(resultData: data, testId: '',),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Submit Failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "No Questions Found",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      );
    }

    final q = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Exit Test",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "$formattedTime left",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Question ${_currentIndex + 1}/${_questions.length}",
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// QUESTION CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xff0F0F10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Physics",
                          style: TextStyle(
                              color: Colors.indigoAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _selectedAnswers[_currentIndex] == null
                            ? "Not answered"
                            : "Answered",
                        style: TextStyle(
                          color: _selectedAnswers[_currentIndex] == null
                              ? Colors.red
                              : Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Question ${_currentIndex + 1}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "Single correct answer",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    q.questionText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// OPTIONS
            Expanded(
              child: ListView.builder(
                itemCount: q.options.length,
                itemBuilder: (context, index) {
                  final opt = q.options[index];
                  final selected =
                      _selectedAnswers[_currentIndex] == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAnswers[_currentIndex] = index;
                        _isAnswered[_currentIndex] = true;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xff111111),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? const Color(0xff5B5EFF)
                              : Colors.white10,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: selected
                                ? const Color(0xff5B5EFF)
                                : const Color(0xff222222),
                            child: Text(
                              opt.option,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              opt.text,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                            ),
                          ),
                          if (selected)
                            const Icon(Icons.check_circle,
                                color: Color(0xff5B5EFF), size: 18),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            /// BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff16182B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed:
                    _currentIndex > 0 ? _previousQuestion : null,
                    child: const Text("Previous",
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _nextQuestion,
                    child: Text(
                      _currentIndex == _questions.length - 1
                          ? "Submit"
                          : "Save & Next",
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text("Mark Review",
                    style: TextStyle(fontSize: 12)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedAnswers[_currentIndex] = null;
                    _isAnswered[_currentIndex] = false;
                  });
                },
                child:
                const Text("Clear", style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}