import 'package:core_app/view/test_exam_screen.dart';
import 'package:core_app/utils/app_colors.dart';
import 'package:flutter/material.dart';

class TestInstructionsScreen extends StatefulWidget {
  final String testId;
  final String testTitle;
  final int duration;
  final int questionsCount;
  final List<String> instructions;

  const TestInstructionsScreen({
    super.key,
    required this.testId,
    required this.testTitle,
    required this.duration,
    required this.questionsCount,
    required this.instructions,
  });

  @override
  State<TestInstructionsScreen> createState() => _TestInstructionsScreenState();
}

class _TestInstructionsScreenState extends State<TestInstructionsScreen> {
  bool _isAgreed = false;
  final String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Hindi'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 120,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: AppColors.primaryOrange, size: 20),
          label: const Text('Exit', style: TextStyle(color: Colors.white, fontSize: 15)),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            child: Column(
              children: [
                _buildTestHeader(),
                const SizedBox(height: 20),
                _buildInstructionsList(),
              ],
            ),
          ),
          _buildProceedButton(),
        ],
      ),
    );
  }

  Widget _buildTestHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.testTitle, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              _infoBadge(Icons.timer, "${widget.duration} Mins"),
              const SizedBox(width: 10),
              _infoBadge(Icons.quiz, "${widget.questionsCount} Questions"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInstructionsList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Instructions", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          ...widget.instructions.map((ins) => _buildBulletPoint(ins)),
          const SizedBox(height: 20),
          CheckboxListTile(
            title: const Text("I have read and agree to all instructions.", style: TextStyle(color: Colors.white70)),
            value: _isAgreed,
            activeColor: AppColors.primaryOrange,
            onChanged: (val) => setState(() => _isAgreed = val!),
          )
        ],
      ),
    );
  }

  Widget _buildProceedButton() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,

      child: ElevatedButton(
        onPressed: _isAgreed
            ? () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TestExamScreen(
              testId: widget.testId,
            ),
          ),
        )
            : null,

        child: const Text("PROCEED TO TEST"),
      ),
    );
  }



  Widget _infoBadge(IconData icon, String label) => Row(children: [Icon(icon, color: Colors.white54, size: 16), SizedBox(width: 5), Text(label, style: TextStyle(color: Colors.white54))]);

  Widget _buildBulletPoint(String text) => Padding(padding: EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("• ", style: TextStyle(color: AppColors.primaryOrange)), Expanded(child: Text(text, style: TextStyle(color: Colors.white70)))]));
}