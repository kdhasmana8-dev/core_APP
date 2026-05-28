import 'package:core_app/view/test_exam_screen.dart';
import 'package:flutter/material.dart';

class TestInstructionsScreen extends StatefulWidget {
  const TestInstructionsScreen({Key? key}) : super(key: key);

  @override
  State<TestInstructionsScreen> createState() => _TestInstructionsScreenState();
}

class _TestInstructionsScreenState extends State<TestInstructionsScreen> {
  bool _isAgreed = false;
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Hindi', 'Spanish', 'German'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0203), // Deep Premium Black Accent
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 120,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Color(0xFFFF2E37), size: 20),
          label: const Text(
            'Exit test',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
            decoration: BoxDecoration(
              color: const Color(0xFFFF2E37).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFF2E37).withOpacity(0.4), width: 1),
            ),
            child: const Center(
              child: Text(
                'Test series',
                style: TextStyle(
                  color: Color(0xFFFF2E37),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          // Main Scrollable Body
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), // Extra bottom padding for button
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // SECTION 1: Physics Mega Test Card
                  _buildTestDetailsCard(),

                  const SizedBox(height: 20),

                  // SECTION 2: Instructions Main Container
                  _buildInstructionsCard(),

                ],
              ),
            ),
          ),

          // Sticky Bottom Premium Proceed Button Layer
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0B0203).withOpacity(0.0),
                    const Color(0xFF0B0203).withOpacity(0.9),
                    const Color(0xFF0B0203),
                  ],
                ),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: _isAgreed
                      ? const LinearGradient(
                    colors: [Color(0xFFFF2E37), Color(0xFF990005)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                      : null,
                  color: _isAgreed ? null : Colors.white.withOpacity(0.1),
                  boxShadow: _isAgreed
                      ? [
                    BoxShadow(
                      color: const Color(0xFFFF2E37).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    )
                  ]
                      : [],
                ),
                child: ElevatedButton(
                  onPressed: _isAgreed
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TestExamScreen()),
                    );
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    'Proceed',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _isAgreed ? Colors.white : Colors.white.withOpacity(0.3),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget 1: Top Test Card Detail
  Widget _buildTestDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161A1D),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Test series',
              style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Physics mega test - mechanics',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Physics + Chemistry + Biology | 60 questions | 1.5 hours | Suggested from weak topics',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 20),

          // Row Blocks (Exam Code & Schedule)
          Row(
            children: [
              Expanded(
                child: _buildMetaBox(
                  icon: Icons.assignment_outlined,
                  title: 'Exam code',
                  subtitle: 'PHY-SERIES',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetaBox(
                  icon: Icons.schedule_outlined,
                  title: 'Schedule',
                  subtitle: 'Take test',
                  isHighlight: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Chips Row
          Row(
            children: [
              _buildMiniChip(Icons.timer, '90 min'),
              const SizedBox(width: 8),
              _buildMiniChip(Icons.help_outline_rounded, '9 questions'),
              const SizedBox(width: 8),
              _buildMiniChip(Icons.translate_rounded, 'English'),
            ],
          )
        ],
      ),
    );
  }

  // Widget 2: Instructions Main Container
  Widget _buildInstructionsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161A1D),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Instructions',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Please read the instructions carefully',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          // Bullets
          _buildBulletPoint('The timer will run continuously after the test starts.'),
          _buildBulletPoint('Each question carries 4 marks and incorrect attempts can carry negative marking according to the test setup from the admin panel.'),

          const SizedBox(height: 20),
          const Text(
            'Question palette and navigation',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildBulletPoint('Use the palette to identify answered, not answered, marked for review, and not visited questions.'),
          _buildBulletPoint('You can jump to any question at any time from the question list.'),

          const SizedBox(height: 20),
          const Text(
            'Before you proceed',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildBulletPoint('Review responses before final submission.'),
          _buildBulletPoint('Marked for review questions are tracked separately so students can revisit them quickly.'),

          const SizedBox(height: 24),

          // Dropdown Language Selector
          Theme(
            data: Theme.of(context).copyWith(canvasColor: const Color(0xFF1E2225)),
            child: DropdownButtonFormField<String>(
              value: _selectedLanguage,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                labelText: 'Language',
                labelStyle: const TextStyle(color: Color(0xFFFF2E37), fontSize: 13),
                filled: true,
                fillColor: Colors.white.withOpacity(0.04),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFF2E37), width: 1.5),
                ),
              ),
              items: _languages.map((String lang) {
                return DropdownMenuItem<String>(
                  value: lang,
                  child: Text(lang),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedLanguage = newValue!;
                });
              },
            ),
          ),

          const SizedBox(height: 24),

          // Rules Acceptance Checkbox row
          InkWell(
            onTap: () {
              setState(() {
                _isAgreed = !_isAgreed;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _isAgreed ? const Color(0xFFFF2E37) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _isAgreed ? const Color(0xFFFF2E37) : Colors.white.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: _isAgreed
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'I have read and understood the instructions. I agree that the exam rules will be followed during this attempt.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Component: Internal Info Box
  Widget _buildMetaBox({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFF2E37), size: 20),
          const SizedBox(height: 10),
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: isHighlight ? const Color(0xFFFF2E37) : Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Component: Mini Chips
  Widget _buildMiniChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white60, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Reusable Component: Premium Bullet Items
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFFF2E37),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}