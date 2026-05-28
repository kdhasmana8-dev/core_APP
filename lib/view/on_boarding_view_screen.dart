import 'package:core_app/auth/auth_screen.dart';
import 'package:core_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState
    extends State<OnboardingScreen> {

  final PageController _pageController =
      PageController();

  int _currentPage = 0;

  // Images
  final List<String> images = [
    "assets/images/bgg5.png",
    "assets/images/bgg4.png",
    "assets/images/bgg2.png",
  ];

  // Titles + Descriptions
  final List<Map<String, String>> textData = [
    {
      "title": "Stream Knowledge,\nAnytime",
      "desc":
          "Dive into high-quality educational reels. Your daily dose of learning, curated just for you.",
    },
    {
      "title": "Master the Test,\nBeat the Rank",
      "desc":
          "Real-time performance analytics. Compete with thousands and climb the leaderboard.",
    },
    {
      "title": "Premium Content,\nZero Distraction",
      "desc":
          "Experience a distraction-free environment designed to help you focus and achieve more.",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Save onboarding
  Future<void> _finishOnboarding() async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      'onboarding_seen',
      true,
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const OttAuthScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [

          /// BACKGROUND IMAGE ONLY CHANGE
          AnimatedSwitcher(
            duration:
                const Duration(milliseconds: 500),

            child: SizedBox.expand(
              key: ValueKey(images[_currentPage]),

              child: Image.asset(
                images[_currentPage],
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// GRADIENT
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,

                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
          ),

          /// TEXT + BUTTON AREA
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 32,
              ),

              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.end,

                children: [

                  /// TITLE ANIMATION
                  AnimatedSwitcher(
                    duration:
                        const Duration(
                      milliseconds: 400,
                    ),

                    child: Text(
                      textData[_currentPage]["title"]!,
                      key: ValueKey(
                        textData[_currentPage]["title"],
                      ),

                      textAlign: TextAlign.center,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight:
                            FontWeight.w900,
                        height: 1.1,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// DESCRIPTION ANIMATION
                  AnimatedSwitcher(
                    duration:
                        const Duration(
                      milliseconds: 400,
                    ),

                    child: Text(
                      textData[_currentPage]["desc"]!,
                      key: ValueKey(
                        textData[_currentPage]["desc"],
                      ),

                      textAlign: TextAlign.center,

                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.5,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),

                  /// INDICATORS + BUTTON
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                    children: [

                      /// INDICATORS
                      Row(
                        children: List.generate(
                          images.length,
                          (i) => _buildIndicator(
                            i == _currentPage,
                          ),
                        ),
                      ),

                      /// BUTTON
                      GestureDetector(
                        onTap: () async {

                          if (_currentPage <
                              images.length - 1) {

                            setState(() {
                              _currentPage++;
                            });
                          }

                          else {
                            await _finishOnboarding();
                          }
                        },

                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),

                          decoration: BoxDecoration(
                            color:
                                AppColors
                                    .primaryOrange,

                            borderRadius:
                                BorderRadius
                                    .circular(30),
                          ),

                          child: AnimatedSwitcher(
                            duration:
                                const Duration(
                              milliseconds: 300,
                            ),

                            child: Text(
                              _currentPage ==
                                      images.length -
                                          1
                                  ? "GET STARTED"
                                  : "NEXT",

                              key: ValueKey(
                                _currentPage,
                              ),

                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                                color:
                                    Colors.white,
                                fontFamily:
                                    'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {

    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 300),

      margin:
          const EdgeInsets.only(right: 8),

      height: 6,
      width: isActive ? 24 : 8,

      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryOrange
            : Colors.white30,

        borderRadius:
            BorderRadius.circular(3),
      ),
    );
  }
}
// import 'package:core_app/auth/auth_screen.dart';
// import 'package:core_app/utils/app_colors.dart';
// import 'package:flutter/material.dart';

// // Separate lists for Text and Images
// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});

//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen> {
//   // Page Controller
//   final PageController _pageController = PageController();
//   int _currentPage = 0;

//   // Separate Lists
//   final List<String> images = [
//     "assets/images/bgg5.png",
//     "assets/images/bgg4.png",
//     "assets/images/bgg2.png",
//   ];

//   final List<Map<String, String>> textData = [
//     {
//       "title": "Stream Knowledge,\nAnytime",
//       "desc": "Dive into high-quality educational reels. Your daily dose of learning, curated just for you.",
//     },
//     {
//       "title": "Master the Test,\nBeat the Rank",
//       "desc": "Real-time performance analytics. Compete with thousands and climb the leaderboard.",
//     },
//     {
//       "title": "Premium Content,\nZero Distraction",
//       "desc": "Experience a distraction-free environment designed to help you focus and achieve more.",
//     },
//   ];

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           PageView.builder(
//             controller: _pageController,
//             onPageChanged: (index) => setState(() => _currentPage = index),
//             itemCount: images.length,
//             itemBuilder: (context, index) {
//               return _buildFullPage(index);
//             },
//           ),

//           _buildNavigationArea(),
//         ],
//       ),
//     );
//   }

//   Widget _buildFullPage(int index) {
//     return Stack(
//       children: [
//         // Background Image using index from images list
//         Positioned.fill(
//           child: Image.asset(images[index], fit: BoxFit.cover),
//         ),

//         // Gradient Overlay
//         Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
//             ),
//           ),
//         ),

//         // Text Content using index from textData list
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 32.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               Text(
//                 textData[index]["title"]!,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1.1, fontFamily: 'Poppins'),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 textData[index]["desc"]!,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5, fontFamily: 'Poppins'),
//               ),
//               const SizedBox(height: 150),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildNavigationArea() {
//     return Positioned(
//       bottom: 50,
//       left: 32,
//       right: 32,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: List.generate(images.length, (i) => _buildIndicator(i == _currentPage)),
//           ),
//           GestureDetector(
//             onTap: () {
//               if (_currentPage < images.length - 1) {
//                 _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
//               } else {
//                 Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OttAuthScreen()));
//               }
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//               decoration: BoxDecoration(
//                 color: AppColors.primaryOrange,
//                 borderRadius: BorderRadius.circular(30),
//               ),
//               child: Text(
//                 _currentPage == images.length - 1 ? "GET STARTED" : "NEXT",
//                 style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Poppins'),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildIndicator(bool isActive) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       margin: const EdgeInsets.only(right: 8),
//       height: 6,
//       width: isActive ? 24 : 8,
//       decoration: BoxDecoration(
//         color: isActive ? AppColors.primaryOrange : Colors.white30,
//         borderRadius: BorderRadius.circular(3),
//       ),
//     );
//   }
// }