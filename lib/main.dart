import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:core_app/splash_screen.dart';
import 'package:core_app/utils/app_colors.dart';
import 'package:core_app/viewModel/course_viewmodel.dart';
import 'package:core_app/viewModel/profile_viewModel.dart';
import 'package:core_app/viewModel/progress_viewModel.dart';
import 'package:core_app/viewModel/reel_viewModel.dart';
import 'package:core_app/viewModel/teacher_viewModel.dart';
import 'package:core_app/viewModel/test_viewModel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase Init
  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const AppProvider());
}

class AppProvider extends StatelessWidget {
  const AppProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CourseViewModel()),
        ChangeNotifierProvider(create: (_) => ReelsEarnViewModel()),
        ChangeNotifierProvider(create: (_) => TestViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => ProgressViewModel()),
        ChangeNotifierProvider(create: (_) => TeacherViewModel()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CORE Concept Reels',
      theme: ThemeData(
        primaryColor: AppColors.primaryOrange,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Poppins',
        colorScheme: const ColorScheme.dark().copyWith(
          primary: AppColors.primaryOrange,
          secondary: AppColors.primaryOrange,
          surface: AppColors.cardSurface,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: AppColors.textPrimary,
          ),
          bodySmall: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
// import 'package:flutter/material.dart';

// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';
//
// import 'package:core_app/splash_screen.dart';
// import 'package:core_app/utils/app_colors.dart';
// import 'package:core_app/viewModel/course_viewmodel.dart';
// import 'package:core_app/viewModel/profile_viewModel.dart';
// import 'package:core_app/viewModel/progress_viewModel.dart';
// import 'package:core_app/viewModel/reel_viewModel.dart';
// import 'package:core_app/viewModel/teacher_viewModel.dart';
// import 'package:core_app/viewModel/test_viewModel.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   try {
//     await Firebase.initializeApp(
//       // options: DefaultFirebaseOptions.currentPlatform,
//     );
//     print("Firebase Initialized Successfully");
//   } catch (e) {
//     print("CRASH ERROR: $e");
//   }
//
//   SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//     statusBarColor: Colors.transparent,
//     statusBarIconBrightness: Brightness.light,
//   ));
//
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => CourseViewModel()),
//         ChangeNotifierProvider(create: (_) => ReelsEarnViewModel()),
//         ChangeNotifierProvider(create: (_) => TestViewModel()),
//         ChangeNotifierProvider(create: (_) => ProfileViewModel()),
//         ChangeNotifierProvider(create: (_) => ProgressViewModel()),
//         ChangeNotifierProvider(create: (_) => TeacherViewModel()),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'CORE Concept Reels',
//       theme: ThemeData(
//         primaryColor: AppColors.primaryOrange,
//         scaffoldBackgroundColor: AppColors.background,
//         fontFamily: 'Poppins',
//         colorScheme: const ColorScheme.dark().copyWith(
//           primary: AppColors.primaryOrange,
//           secondary: AppColors.primaryOrange,
//           surface: AppColors.cardSurface,
//           background: AppColors.background,
//         ),
//         textTheme: const TextTheme(
//           bodyMedium: TextStyle(color: AppColors.textPrimary),
//           bodySmall: TextStyle(color: AppColors.textSecondary),
//         ),
//       ),
//       home: const SplashScreen(),
//     );
//   }
// }