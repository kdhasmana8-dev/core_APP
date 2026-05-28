import 'package:flutter/material.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryName;

  const CategoryDetailScreen({
    Key? key,
    required this.categoryName,
  }) : super(key: key);

  // Helper method to resolve dynamic colors based on your Category blocks layout
  Color _getCategoryThemeColor() {
    switch (categoryName.toLowerCase()) {
      case 'physics':
        return const Color(0xFF1E88E5); // Blue tint
      case 'chemistry':
        return const Color(0xFF8E24AA); // Purple tint
      case 'maths':
      case 'mathematics':
        return const Color(0xFFF57C00); // Amber/Orange tint
      case 'biology':
        return const Color(0xFF388E3C); // Green tint
      default:
        return Colors.redAccent;
    }
  }

  // Dummy dynamic content mapping matching your mega test criteria
  List<Map<String, dynamic>> _getMockDataForCategory() {
    return [
      {
        'title': '$categoryName Mega Test - Mechanics & Core',
        'questions': '60 Questions',
        'duration': '1.5 Hours',
        'code': 'MOCK-SERIES-01',
        'tag': 'Mega Test'
      },
      {
        'title': '$categoryName Revision Pack - Conceptual Practice',
        'questions': '30 Questions',
        'duration': '45 Mins',
        'code': 'REV-PACK-04',
        'tag': 'Practice Set'
      },
      {
        'title': '$categoryName Advanced Level Assessment Matrix',
        'questions': '9 Questions',
        'duration': '90 Mins',
        'code': '${categoryName.substring(0, 3).toUpperCase()}-SERIES',
        'tag': 'Live Test'
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _getCategoryThemeColor();
    final contentList = _getMockDataForCategory();

    return Scaffold(
      backgroundColor: Colors.black, // Matching your core system black theme
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          categoryName,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white10, height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SECTION 1: HEADER HERO OVERVIEW PROFILE
                _buildCategoryHeroBanner(themeColor),

                const SizedBox(height: 24),

                // SECTION 2: SECTION TITLE INFO
                const Text(
                  'Available Test Series & Modules',
                  style: TextStyle(
                    color: Colors.white30,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),

                // SECTION 3: DYNAMIC LIST CARDS BLOCK
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: contentList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = contentList[index];
                    return _buildTestSeriesCard(context, item, themeColor);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Upper Core Highlight Metric Banner Component
  Widget _buildCategoryHeroBanner(Color themeColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [themeColor.withOpacity(0.15), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: themeColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'CORE MODULE',
                  style: TextStyle(color: themeColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
              Icon(Icons.analytics_outlined, color: themeColor, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Mastering $categoryName',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Explore multi-tier structural evaluation mock series explicitly structured by your weakness tracking index.',
            style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }

  // Custom Test Action Card Layout exactly styled like your test specifications layout
  Widget _buildTestSeriesCard(BuildContext context, Map<String, dynamic> item, Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item['tag'],
                  style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.star_border_rounded, color: Colors.white24, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item['title'],
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),

          // Technical Chips Row
          Row(
            children: [
              _buildInlineMetricsChip(Icons.timer_outlined, item['duration']),
              const SizedBox(width: 8),
              _buildInlineMetricsChip(Icons.help_outline_rounded, item['questions']),
              const SizedBox(width: 8),
              _buildInlineMetricsChip(Icons.g_translate_rounded, 'English'),
            ],
          ),

          const Divider(color: Colors.white10, height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Exam Code', style: TextStyle(color: Colors.white38, fontSize: 10)),
                  const SizedBox(height: 2),
                  Text(item['code'], style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  // Direct navigation hook mock setup
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Starting execution for ${item['title']}'),
                      backgroundColor: themeColor,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.05),
                  side: const BorderSide(color: Colors.white10),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  'Take Test',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInlineMetricsChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF161618),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white38, size: 12),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}