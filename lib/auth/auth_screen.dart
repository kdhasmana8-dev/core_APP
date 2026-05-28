import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../view/bottom_view_nav.dart';
import '../utils/app_colors.dart';

class OttAuthScreen extends StatefulWidget {
  const OttAuthScreen({super.key});

  @override
  State<OttAuthScreen> createState() => _OttAuthScreenState();
}

class _OttAuthScreenState extends State<OttAuthScreen> {
  final PageController _pageController = PageController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();

  String selectedClass = "";
  String selectedExam = "";
  int _currentPage = 0;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage++);
  }

  void _prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage--);
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        // serverClientId:
        // '241826914412-1eshqrf2stdhbki8nt4nis447vbamfd426914412-i7n4j1ncprr6bf7m4g1r3l9aq7per8jp.apps.googleusercontent.com',
      );

      // Account picker force
      await googleSignIn.disconnect().catchError((_) {});
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser =
      await googleSignIn.signIn();

      if (googleUser == null) return;

      final googleAuth =
      await googleUser.authentication;

      final credential =
      GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await FirebaseAuth.instance
          .signInWithCredential(
        credential,
      );

      // Fresh token
      final firebaseToken =
      await userCredential.user!
          .getIdToken(true);

      debugPrint("TOKEN GENERATED");

      const baseUrl =
          "http://192.168.1.20:5000";

      final response =
      await http.post(
        Uri.parse(
          "$baseUrl/api/auth/google-login",
        ),
        headers: {
          "Content-Type":
          "application/json",
        },
        body: jsonEncode({
          "token":
          firebaseToken,
        }),
      );

      debugPrint("STATUS => ${response.statusCode}");
      debugPrint("BODY => ${response.body}");

      debugPrint(response.body);

      if (response.statusCode != 200) {
        throw Exception(response.body);
      }

      final data =
      jsonDecode(response.body);

      final prefs =
      await SharedPreferences.getInstance();

      await prefs.setString(
        "user_token",
        data["token"],
      );

      await prefs.setBool(
        "isLoggedIn",
        true,
      );

      await prefs.setString(
        "user_name",
        data["user"]["name"] ?? "",
      );

      await prefs.setString(
        "user_email",
        data["user"]["email"] ?? "",
      );

      await prefs.setString(
        "profile_pic",
        data["user"]["profilePic"] ?? "",
      );

      if (!mounted) return;

      // Continue directly to OTP screen
      _nextPage();

    } catch (e) {

      debugPrint(
        "GOOGLE LOGIN ERROR => $e",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content:
          Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_currentPage == 0) ...[
            Positioned.fill(child: Image.asset('assets/images/bgg5.png', fit: BoxFit.cover)),
            Positioned.fill(child: Container(color: Colors.black.withOpacity(0.7))),
          ],
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildAuthPage("Welcome to CORE", "Sign in to continue", _buildPhoneForm(), isWelcome: true),
              _buildAuthPage("Verify OTP", "Enter the 6 digit OTP sent to your number", _buildOtpForm(), showBack: true),
              _buildAuthPage("Select your class", "Choose your current learning stage.", _buildClassSelection(), showBack: true),
              _buildAuthPage("Tell us your name", "Personalize your learning experience.", _buildNameForm(), showBack: true),
              _buildAuthPage("Select your exam", "Decide your content and subject filters.", _buildExamSelection(), showBack: true),
            ],
          ),
        ],
      ),
    );
  }

  // --- Supporting Methods (kept identical to your logic) ---
  Widget _buildAuthPage(String title, String sub, Widget child, {bool showBack = false, bool isWelcome = false}) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showBack) IconButton(onPressed: _prevPage, icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28)),
            if (!isWelcome) ...[
              const SizedBox(height: 20),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 40),
              child,
            ] else ...[
              const Spacer(),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.normal)),
              const SizedBox(height: 8),
              Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 40),
              child,
              const SizedBox(height: 20),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildCustomButton(String text, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          side: const BorderSide(color: AppColors.primaryOrange, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text, style: const TextStyle(color: AppColors.primaryOrange, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildPhoneForm() => Column(children: [
    ElevatedButton.icon(
      onPressed: _signInWithGoogle,
      icon: const FaIcon(FontAwesomeIcons.google, size: 22),
      label: const Text("Continue with Google"),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 55),
        backgroundColor: Colors.white.withOpacity(0.1),
        foregroundColor: Colors.white,
      ),
    ),
    const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Text("OR", style: TextStyle(color: Colors.white54))),
    TextField(
      controller: _phoneController,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(hintText: "Mobile number", filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
    ),
    const SizedBox(height: 15),
    _buildCustomButton("Send OTP", _nextPage),
  ]);

  Widget _buildOtpForm() => Column(children: [
    TextField(controller: _otpController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Enter 6 digit OTP", filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))))),
    const SizedBox(height: 20),
    _buildCustomButton("Verify", _nextPage),
  ]);

  Widget _buildClassSelection() => Column(children: [
    Row(children: [Expanded(child: _selectableButton("11th", "11th")), const SizedBox(width: 15), Expanded(child: _selectableButton("12th", "12th"))]),
    const SizedBox(height: 15),
    _selectableButton("Dropper", "Dropper", isFull: true),
    const SizedBox(height: 20),
    _buildCustomButton("Continue", selectedClass.isNotEmpty ? _nextPage : null),
  ]);

  Widget _buildNameForm() => Column(children: [
    TextField(controller: _nameController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Enter Full Name", filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))))),
    const SizedBox(height: 20),
    _buildCustomButton("Continue", _nextPage),
  ]);

  Widget _buildExamSelection() => Column(children: [
    Row(children: [Expanded(child: _selectableButton("NEET UG", "NEET")), const SizedBox(width: 15), Expanded(child: _selectableButton("JEE (Main+Adv)", "JEE"))]),
    const SizedBox(height: 40),
    _buildCustomButton("Get Started", () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainShellDashboard()))),
  ]);

  Widget _selectableButton(String label, String value, {bool isFull = false}) {
    bool isSelected = (value == selectedClass || value == selectedExam);
    return InkWell(
      onTap: () => setState(() {
        if (value == "11th" || value == "12th" || value == "Dropper") {
          selectedClass = value;
        } else {
          selectedExam = value;
        }
      }),
      child: Container(
        height: 70,
        width: isFull ? double.infinity : null,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryOrange.withOpacity(0.3) : Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primaryOrange : Colors.white24),
        ),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}