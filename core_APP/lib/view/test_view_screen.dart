import 'package:core_app/view/test_exam_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/app_colors.dart';

import '../model/test_model.dart';
import '../viewModel/test_viewModel.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  String _selectedCategory = "All";

  BoxDecoration get _orangeGradientDecoration => BoxDecoration(
    gradient: LinearGradient(
      colors: [
        AppColors.primaryOrange.withOpacity(0.8),
        AppColors.primaryOrange
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<AssessmentViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          final filters = [
            "All",
            ...viewModel.assessments.map((e) => e.subjectName).toSet()
          ];

          final displayTests = _selectedCategory == "All"
              ? viewModel.assessments
              : viewModel.assessments
              .where((t) => t.subjectName == _selectedCategory)
              .toList();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 90,
                pinned: true,
                backgroundColor: Colors.black,
                flexibleSpace: const FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    "Mock Tests",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),

              /// FILTERS
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 60,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    scrollDirection: Axis.horizontal,
                    itemCount: filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final filter = filters[index];
                      final isSelected = _selectedCategory == filter;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = filter;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: isSelected
                              ? _orangeGradientDecoration.copyWith(
                            borderRadius: BorderRadius.circular(20),
                          )
                              : BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              filter,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              /// LIST
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                      _buildTestCard(displayTests[index]),
                  childCount: displayTests.length,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          );
        },
      ),
    );
  }

  /// CARD UI
  Widget _buildTestCard(AssessmentModel test) {
    final image = test.thumbnailUrl;

    final hasValidImage =
        image.isNotEmpty && image.startsWith("http");

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: hasValidImage
                  ? Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _dummyImageWidget(),
              )
                  : _dummyImageWidget(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    _infoChip(
                      "${test.totalQuestions} Qs",
                      Icons.help_outline,
                    ),
                    const SizedBox(width: 8),
                    _infoChip(
                      "${test.duration} Min",
                      Icons.timer,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  decoration: _orangeGradientDecoration.copyWith(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => TestExamScreen(testId: test.id,)));
                    },
                    child: const Text(
                      "START TEST",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _dummyImageWidget() {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Icon(Icons.quiz, color: Colors.white, size: 50),
      ),
    );
  }

  Widget _infoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.orange),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          )
        ],
      ),
    );
  }
}