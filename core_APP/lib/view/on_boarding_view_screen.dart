import 'package:core_app/auth/auth_screen.dart';
import 'package:core_app/utils/app_colors.dart';
import 'package:flutter/material.dart';

// Separate lists for Text and Images
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Page Controller
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Separate Lists
  final List<String> images = [
    "assets/images/bgg5.png",
    "assets/images/bgg4.png",
    "assets/images/bgg2.png",
  ];

  final List<Map<String, String>> textData = [
    {
      "title": "Stream Knowledge,\nAnytime",
      "desc": "Dive into high-quality educational reels. Your daily dose of learning, curated just for you.",
    },
    {
      "title": "Master the Test,\nBeat the Rank",
      "desc": "Real-time performance analytics. Compete with thousands and climb the leaderboard.",
    },
    {
      "title": "Premium Content,\nZero Distraction",
      "desc": "Experience a distraction-free environment designed to help you focus and achieve more.",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return _buildFullPage(index);
            },
          ),

          _buildNavigationArea(),
        ],
      ),
    );
  }

  Widget _buildFullPage(int index) {
    return Stack(
      children: [
        // Background Image using index from images list
        Positioned.fill(
          child: Image.asset(images[index], fit: BoxFit.cover),
        ),

        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
            ),
          ),
        ),

        // Text Content using index from textData list
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                textData[index]["title"]!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1.1, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 16),
              Text(
                textData[index]["desc"]!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 150),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationArea() {
    return Positioned(
      bottom: 50,
      left: 32,
      right: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(images.length, (i) => _buildIndicator(i == _currentPage)),
          ),
          GestureDetector(
            onTap: () {
              if (_currentPage < images.length - 1) {
                _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
              } else {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OttAuthScreen()));
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                _currentPage == images.length - 1 ? "GET STARTED" : "NEXT",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Poppins'),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 6,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryOrange : Colors.white30,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}