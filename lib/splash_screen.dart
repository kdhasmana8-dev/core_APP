import 'dart:async';

import 'package:core_app/auth/auth_screen.dart';
import 'package:core_app/view/on_boarding_view_screen.dart';
import 'package:core_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    _navigateNext();
  }

  Future<void> _navigateNext() async {

    await Future.delayed(
      const Duration(seconds: 6),
    );

    final prefs =
        await SharedPreferences.getInstance();

    final bool onboardingSeen =
        prefs.getBool('onboarding_seen') ?? false;

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration:
            const Duration(milliseconds: 800),

        pageBuilder: (_, _, _) =>
            onboardingSeen
                ? const OttAuthScreen()
                : const OnboardingScreen(),

        transitionsBuilder:
            (_, animation, _, child) {

          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,

      body: FadeTransition(
        opacity: _animation,

        child: Stack(
          children: [

            /// Background
            Positioned.fill(
              child: Opacity(
                opacity: 0.7,

                child: Image.asset(
                  'assets/images/bg1.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            /// Center Content
            Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [

                  /// Logo
                  Image.asset(
                    'assets/images/logo7.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 20),

                  /// Title
                  const Text(
                    "CORE",

                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                      color: Colors.white,
                    ),
                  ),

                  /// Subtitle
                  const Text(
                    "CONCEPT REELS",

                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w400,
                      color:
                          AppColors.primaryOrange,
                    ),
                  ),

                  /// Loading
                  const SizedBox(height: 60),

                  const Text(
                    "LOADING...",

                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      letterSpacing: 4,
                      color:
                          AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Container(
                    width: 180,

                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(10),
                    ),

                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(10),

                      child: const LinearProgressIndicator(
                        minHeight: 3,
                        backgroundColor:
                            AppColors.borderStroke,

                        valueColor:
                            AlwaysStoppedAnimation<Color>(
                          AppColors.primaryOrange,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// import 'dart:async';
// import 'package:core_app/view/on_boarding_view_screen.dart';
// import 'package:core_app/utils/app_colors.dart';
// import 'package:flutter/material.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
//     _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
//     _controller.forward();

//     Timer(const Duration(seconds: 6), () {
//       Navigator.pushReplacement(
//         context,
//         PageRouteBuilder(
//           pageBuilder: (_, __, ___) => const OnboardingScreen(),
//           transitionDuration: const Duration(milliseconds: 800),
//           transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
//         ),
//       );
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: FadeTransition(
//         opacity: _animation,
//         child: Stack(
//           children: [
//             // Background Graphics
//             Positioned.fill(
//               child: Opacity(
//                 opacity: 0.7,
//                 child: Image.asset(
//                   'assets/images/bg1.png',
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),

//             Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Image.asset(
//                     'assets/images/logo7.png',
//                     width: 200,
//                     height: 200,
//                     fit: BoxFit.contain,
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     "CORE",
//                     style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 40,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 8,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const Text(
//                     "CONCEPT REELS",
//                     style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 14,
//                       letterSpacing: 4,
//                       fontWeight: FontWeight.w400,
//                       color: AppColors.primaryOrange,
//                     ),
//                   ),

//                   // LOADING INDICATOR SECTION
//                   const SizedBox(height: 60),
//                   const Text(
//                     "LOADING...",
//                     style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 10,
//                       letterSpacing: 4,
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                   const SizedBox(height: 15),
//                   Container(
//                     width: 180,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: LinearProgressIndicator(
//                         minHeight: 3,
//                         backgroundColor: AppColors.borderStroke,
//                         valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }