import 'package:core_app/view/score_board_screen.dart';
import 'package:flutter/material.dart';

class TestExamScreen extends StatefulWidget {
  const TestExamScreen({Key? key}) : super(key: key);

  @override
  State<TestExamScreen> createState() => _TestExamScreenState();
}

class _TestExamScreenState extends State<TestExamScreen> {
  // Dummy Questions Dataset
  // 10 Detailed Dummy Mock Questions/Tests List
  final List<Map<String, dynamic>> _questions = [
    {'subject': 'Physics', 'questionText': 'Unit of electric field is?', 'options': ['N/C', 'J', 'C', 'W'], 'correctIndex': 0},
    {'subject': 'Physics', 'questionText': 'Dimensional formula for gravitational constant (G)?', 'options': ['[M⁻¹ L³ T⁻²]', '[M¹ L² T⁻²]', '[M⁻² L³ T⁻¹]', '[M¹ L³ T⁻²]'], 'correctIndex': 0},
    {'subject': 'Physics', 'questionText': 'Which law describes the force between two point charges?', 'options': ['Newton’s Law', 'Coulomb’s Law', 'Faraday’s Law', 'Gauss’s Law'], 'correctIndex': 1},
    {'subject': 'Physics', 'questionText': 'What is the SI unit of Magnetic Flux?', 'options': ['Tesla', 'Weber', 'Henry', 'Ampere'], 'correctIndex': 1},

    {'subject': 'Chemistry', 'questionText': 'Which of the following is an amphoteric oxide?', 'options': ['CO2', 'Al2O3', 'Na2O', 'SO2'], 'correctIndex': 1},
    {'subject': 'Chemistry', 'questionText': 'What is the pH of a neutral solution at 25°C?', 'options': ['0', '7', '14', '1'], 'correctIndex': 1},
    {'subject': 'Chemistry', 'questionText': 'Which element has the highest electronegativity?', 'options': ['Oxygen', 'Fluorine', 'Chlorine', 'Nitrogen'], 'correctIndex': 1},

    {'subject': 'Biology', 'questionText': 'Which cell organelle is known as the powerhouse of the cell?', 'options': ['Golgi Bodies', 'Ribosomes', 'Mitochondria', 'Lysosomes'], 'correctIndex': 2},
    {'subject': 'Biology', 'questionText': 'Which blood group is known as the universal donor?', 'options': ['A+', 'B+', 'AB-', 'O-'], 'correctIndex': 3},
    {'subject': 'Biology', 'questionText': 'The basic unit of life is?', 'options': ['Tissue', 'Organ', 'Cell', 'Nucleus'], 'correctIndex': 2},
  ];

  int _currentIndex = 0;
  String _selectedSubject = 'Physics';

  // Track state for each question
  late List<int?> _selectedAnswers;
  late List<bool> _isMarkedForReview;
  late List<bool> _isAnswered;
  void _finishTest() {
    int correctAnswers = 0;
    int attempted = 0;

    for (int i = 0; i < _questions.length; i++) {
      if (_isAnswered[i]) {
        attempted++;
        if (_selectedAnswers[i] == _questions[i]['correctIndex']) {
          correctAnswers++;
        }
      }
    }

    // Logic: +4 for Correct, -1 for Incorrect
    double totalScore = (correctAnswers * 4.0) - (attempted - correctAnswers);

    // Subject wise insights calculate karna (Logic: simple distribution)
    Map<String, SubjectInsight> metrics = {};
    for (var subject in ['Physics', 'Chemistry', 'Biology']) {
      metrics[subject] = SubjectInsight(
        accuracy: 75.0, // Aap yahan real calculation add kar sakte hain
        averageTimePerQuestion: "2m 15s",
      );
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultDashboardScreen(
          result: TestResultData(
            totalScore: totalScore,
            maxPossibleScore: _questions.length * 4.0,
            totalQuestionsInTest: _questions.length,
            questionsAttempted: attempted,
            correctAnswers: correctAnswers,
            timeTaken: const Duration(minutes: 15), // Yahan timer ka actual data pass karein
            subjectMetrics: metrics,
          ),
        ),
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    _selectedAnswers = List.generate(_questions.length, (index) => null);
    _isMarkedForReview = List.generate(_questions.length, (index) => false);
    _isAnswered = List.generate(_questions.length, (index) => false);
  }

  // Filtered lists based on chosen tab
  List<int> get _filteredIndices {
    List<int> indices = [];
    for (int i = 0; i < _questions.length; i++) {
      if (_questions[i]['subject'] == _selectedSubject) {
        indices.add(i);
      }
    }
    return indices;
  }

  void _nextQuestion() {
    int currentFilteredPos = _filteredIndices.indexOf(_currentIndex);

    // 1. Agar filtered list mein next question hai
    if (currentFilteredPos < _filteredIndices.length - 1) {
      setState(() {
        _currentIndex = _filteredIndices[currentFilteredPos + 1];
      });
    }
    // 2. Agar ye section ka last question hai, toh pura test finish karein
    else {
      _finishTest();
    }
  }
  void _previousQuestion() {
    int currentFilteredPos = _filteredIndices.indexOf(_currentIndex);
    if (currentFilteredPos > 0) {
      setState(() {
        _currentIndex = _filteredIndices[currentFilteredPos - 1];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentIndex];
    final filteredIndices = _filteredIndices;
    final displayIndex = filteredIndices.indexOf(_currentIndex) + 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0304), // Deep Premium Matte Black
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 120,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Color(0xFFFF8C1A), size: 18),
          label: const Text(
            'Exit test',
            style: TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  '89:55 left',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                Text(
                  'Question $displayIndex/${filteredIndices.length}',
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                ),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // SECTION 1: Subject Tabs & Question Matrix Grid Trigger
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: ['Physics', 'Chemistry', 'Biology'].map((subject) {
                        bool isSelected = _selectedSubject == subject;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSubject = subject;
                              _currentIndex = _questions.indexWhere((q) => q['subject'] == subject);
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFFF8C1A).withOpacity(0.15) : Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isSelected ? const Color(0xFFFF8C1A) : Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              subject,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white60,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Question Palette Anchor Button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8C1A).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFF8C1A).withOpacity(0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.grid_view_rounded, color: Color(0xFFFF8C1A), size: 16),
                      SizedBox(width: 6),
                      Text('Questions', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // SECTION 2: Question & Options Display Box
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF14171A),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Dynamic State Badges
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF8C1A).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _selectedSubject,
                                  style: const TextStyle(color: Color(0xFFFF8C1A), fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _isMarkedForReview[_currentIndex]
                                      ? Colors.amber.withOpacity(0.12)
                                      : (_isAnswered[_currentIndex] ? Colors.green.withOpacity(0.12) : Colors.red.withOpacity(0.12)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _isMarkedForReview[_currentIndex]
                                      ? 'Review'
                                      : (_isAnswered[_currentIndex] ? 'Answered' : 'Not answered'),
                                  style: TextStyle(
                                    color: _isMarkedForReview[_currentIndex]
                                        ? Colors.amber
                                        : (_isAnswered[_currentIndex] ? Colors.green : const Color(0xFFFF5252)),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'Question $displayIndex',
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Single correct answer',
                            style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 13),
                          ),

                          const SizedBox(height: 16),

                          // Marking Metrics Row
                          Row(
                            children: [
                              _buildScoreTag('+4 marks', const Color(0xFF2E7D32), const Color(0xFFE8F5E9)),
                              const SizedBox(width: 8),
                              _buildScoreTag('-1 negative', const Color(0xFFC62828), const Color(0xFFFFEBEE)),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // The Question core text
                          Text(
                            currentQuestion['questionText'],
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, height: 1.4),
                          ),

                          const SizedBox(height: 24),

                          // Render MCQ Options list
                          ...List.generate(currentQuestion['options'].length, (index) {
                            String optionLetter = String.fromCharCode(65 + index); // A, B, C, D
                            bool isSelected = _selectedAnswers[_currentIndex] == index;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedAnswers[_currentIndex] = index;
                                  _isAnswered[_currentIndex] = true;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFFF8C1A).withOpacity(0.04) : Colors.white.withOpacity(0.02),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFFFF8C1A) : Colors.white.withOpacity(0.08),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected ? const Color(0xFFFF8C1A) : Colors.white.withOpacity(0.06),
                                      ),
                                      child: Center(
                                        child: Text(
                                          optionLetter,
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.white70,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        currentQuestion['options'][index],
                                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  // In-Card Sub-Navigation Panel (Previous & Save next)
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: (displayIndex > 1) ? _previousQuestion : null,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.white.withOpacity(0.12)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            'Previous',
                            style: TextStyle(color: (displayIndex > 1) ? Colors.white70 : Colors.white24, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _nextQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8C1A),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Save & next', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // SECTION 3: Persistent Sticky Bottom Floating Operations Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0405),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // Mark for Review Button toggle
                  Expanded(
                    flex: 5,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isMarkedForReview[_currentIndex] = !_isMarkedForReview[_currentIndex];
                        });
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isMarkedForReview[_currentIndex] ? Icons.bookmark : Icons.bookmark_border_rounded,
                              color: _isMarkedForReview[_currentIndex] ? Colors.amber : const Color(0xFFFF2E37),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Mark for review',
                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Clear Response reset state button
                  Expanded(
                    flex: 5,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedAnswers[_currentIndex] = null;
                          _isAnswered[_currentIndex] = false;
                        });
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.blur_off_rounded, color: Colors.white60, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Clear response',
                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Options Icon Menu button
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.more_vert_rounded, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Score Badge builder components
  Widget _buildScoreTag(String title, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        title,
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}