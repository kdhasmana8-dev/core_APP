import 'package:core_app/view/test_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../viewModel/test_viewModel.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  String _selectedCategory = "All";
  final List<String> _filters = ["All", "Main", "Advanced", "Boards"];

  // Reusable Gradient using AppColors
  BoxDecoration get _orangeGradientDecoration => BoxDecoration(
    gradient: LinearGradient(
      colors: [AppColors.primaryOrange.withOpacity(0.8), AppColors.primaryOrange],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<TestViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator(color: AppColors.primaryOrange));
          }

          final filteredSections = _selectedCategory == "All"
              ? ["Main", "Advanced", "Boards"]
              : [_selectedCategory];

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 90,
                pinned: true,
                backgroundColor: Colors.black,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: const Text("Mock Tests", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.primaryOrange.withOpacity(0.3), Colors.black.withOpacity(0.0)],
                      ),
                    ),
                  ),
                ),
              ),

              // Filter Section
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 60,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = _selectedCategory == filter;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = filter),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: isSelected
                              ? _orangeGradientDecoration.copyWith(borderRadius: BorderRadius.circular(20))
                              : BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(20)),
                          alignment: Alignment.center,
                          child: Text(filter, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
                ),
              ),

              ...filteredSections.map((section) {
                final tests = viewModel.tests.where((t) => t.category == section).toList();
                if (tests.isEmpty) return const SliverToBoxAdapter();

                return SliverMainAxisGroup(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Text("JEE $section Tests",
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildTestCard(tests[index]),
                        childCount: tests.length,
                      ),
                    ),
                  ],
                );
              }).toList(),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTestCard(test) {
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: Image.asset(
                test.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(decoration: _orangeGradientDecoration, child: const Icon(Icons.quiz_rounded, size: 50, color: Colors.white24));
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(test.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _infoChip("${test.questions} Qs", Icons.help_outline_rounded),
                    const SizedBox(width: 8),
                    _infoChip("${test.duration} Mins", Icons.timer_rounded),
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  decoration: _orangeGradientDecoration.copyWith(borderRadius: BorderRadius.circular(12)),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const TestInstructionsScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    child: const Text("START TEST", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(6)),
      child: Row(children: [
        Icon(icon, size: 12, color: AppColors.primaryOrange),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
      ]),
    );
  }
}