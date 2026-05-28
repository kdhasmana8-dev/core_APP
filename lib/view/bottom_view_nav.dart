import 'package:flutter/material.dart';
import '../utils/app_colors.dart'; // Ensure correct path
import 'package:core_app/view/course_list_view.dart';
import 'package:core_app/view/profile_view_screen.dart';
import 'package:core_app/view/reel_view_screen.dart' hide AppColors;
import 'package:core_app/view/test_view_screen.dart';
import 'package:core_app/view/core_view_home.dart';

class MainShellDashboard extends StatefulWidget {
  const MainShellDashboard({super.key});

  @override
  State<MainShellDashboard> createState() => _MainShellDashboardState();
}

class _MainShellDashboardState extends State<MainShellDashboard> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const CourseListView(),
      const ReelsEarnScreen(),
      const TestScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bool isReelsActive = _currentIndex == 2;

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: isReelsActive ? 0 : 90,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardSurface, // Consistent with your UI
            border: Border(
              top: BorderSide(color: AppColors.borderStroke, width: 1.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _navItem(0, Icons.home_filled, "Home"),
              _navItem(1, Icons.video_library_rounded, "Courses"),
              _floatingButton(),
              _navItem(3, Icons.quiz_rounded, "Tests"),
              _navItem(4, Icons.person_rounded, "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _floatingButton() {
    final bool isSelected = _currentIndex == 2;
    return Transform.translate(
      offset: const Offset(0, -15),
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = 2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.background,
            border: Border.all(
              color: isSelected ? AppColors.primaryOrange.withOpacity(0.5) : AppColors.borderStroke,
              width: 2,
            ),
          ),
          child: Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryOrange,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryOrange.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: SizedBox(
                width: 60,
                height: 60,
                child: Image.asset(
                  "assets/images/icon.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryOrange : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}