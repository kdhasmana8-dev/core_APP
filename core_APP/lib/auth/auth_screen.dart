import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/drawer_model.dart';
import '../utils/app_colors.dart';
import '../view/bottom_view_nav.dart';

class OttAuthScreen extends StatefulWidget {
  const OttAuthScreen({super.key});

  @override
  State<OttAuthScreen> createState() =>
      _OttAuthScreenState();
}

class _OttAuthScreenState
    extends State<OttAuthScreen> {
  final PageController _pageController =
  PageController();

  final TextEditingController
  _phoneController =
  TextEditingController();

  final TextEditingController
  _otpController =
  TextEditingController();

  final TextEditingController
  _nameController =
  TextEditingController();

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  static const String baseUrl =
      "https://core-backend-38rr.onrender.com";

  String selectedClass = "";
  String selectedExam = "";
  String selectedExamName = "";

  int _currentPage = 0;

  bool isExamLoading = false;

  List<dynamic> exams = [];

  @override
  void initState() {
    super.initState();

    checkLogin();

    getAllExams();
  }

  Future<void> checkLogin() async {
    final prefs =
    await SharedPreferences
        .getInstance();

    final isLoggedIn =
        prefs.getBool("isLoggedIn") ??
            false;

    final token =
        prefs.getString("user_token") ??
            "";

    debugPrint(
      "========== CHECK LOGIN ==========",
    );

    debugPrint(
      "IS LOGGED IN : $isLoggedIn",
    );

    debugPrint(
      "TOKEN : $token",
    );

    if (isLoggedIn &&
        token.isNotEmpty) {
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
            const MainShellDashboard(),
          ),
        );
      });
    }
  }

  Future<void> getAllExams() async {
    try {
      setState(() {
        isExamLoading = true;
      });

      final url = "$baseUrl/api/exams";

      debugPrint("GET EXAMS URL: $url");

      final response = await http.get(Uri.parse(url));

      debugPrint("STATUS CODE: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() {
          exams = List<Map<String, dynamic>>.from(data["exams"]);
        });

        debugPrint("EXAMS LOADED: ${exams.length}");
      } else {
        debugPrint("API FAILED OR SUCCESS FALSE");
      }
    } catch (e) {
      debugPrint("GET EXAMS ERROR: $e");
    } finally {
      setState(() {
        isExamLoading = false;
      });
    }
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(
        milliseconds: 300,
      ),
      curve: Curves.easeInOut,
    );

    setState(() {
      _currentPage++;
    });
  }

  void _prevPage() {
    _pageController.previousPage(
      duration: const Duration(
        milliseconds: 300,
      ),
      curve: Curves.easeInOut,
    );

    setState(() {
      _currentPage--;
    });
  }

  Future<void> _signInWithGoogle() async {
    try {
      debugPrint(
        "========== GOOGLE SIGN IN START ==========",
      );

      final GoogleSignIn googleSignIn =
      GoogleSignIn();

      await googleSignIn
          .disconnect()
          .catchError((e) {
        debugPrint(
          "DISCONNECT ERROR : $e",
        );
      });

      await googleSignIn.signOut();

      final GoogleSignInAccount?
      googleUser =
      await googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint(
          "USER CANCELLED LOGIN",
        );
        return;
      }

      debugPrint(
        "GOOGLE USER : ${googleUser.email}",
      );

      final googleAuth =
      await googleUser.authentication;

      final credential =
      GoogleAuthProvider.credential(
        accessToken:
        googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await FirebaseAuth.instance
          .signInWithCredential(
        credential,
      );

      final firebaseToken =
      await userCredential.user!
          .getIdToken(true);

      debugPrint(
        "FIREBASE TOKEN : $firebaseToken",
      );

      final response = await http.post(
        Uri.parse(
          "$baseUrl/api/auth/google-login",
        ),
        headers: {
          "Content-Type":
          "application/json",
        },
        body: jsonEncode({
          "token": firebaseToken,
        }),
      );

      debugPrint(
        "LOGIN STATUS : ${response.statusCode}",
      );

      debugPrint(
        "LOGIN BODY : ${response.body}",
      );

      if (response.statusCode != 200) {
        throw Exception(response.body);
      }

      final data =
      jsonDecode(response.body);

      final prefs =
      await SharedPreferences
          .getInstance();

      await prefs.setString(
        "user_token",
        data["token"] ?? "",
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
        data["user"]["profilePic"] ??
            "",
      );
      await Provider.of<AuthViewModel>(
        context,
        listen: false,
      ).saveUser(
        name: data["user"]["name"] ?? "",
        email: data["user"]["email"] ?? "",
        profile: data["user"]["profilePic"] ?? "",
      );

      debugPrint(
        "========== LOGIN SUCCESS ==========",
      );

      if (!mounted) return;

      _pageController.jumpToPage(2);

      setState(() {
        _currentPage = 2;
      });
    } catch (e) {
      debugPrint(
        "========== GOOGLE LOGIN ERROR ==========",
      );

      debugPrint(
        e.toString(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  Future<void> saveUserSelections() async {
    try {
      debugPrint(
        "========== SAVE USER SELECTION START ==========",
      );

      final prefs =
      await SharedPreferences.getInstance();

      final token =
          prefs.getString("user_token") ?? "";

      debugPrint("TOKEN : $token");

      debugPrint(
        "SELECTED CLASS : $selectedClass",
      );

      debugPrint(
        "SELECTED EXAM ID : $selectedExam",
      );

      /// LOCAL SAVE

      await prefs.setString(
        "selected_class",
        selectedClass,
      );

      await prefs.setString(
        "selected_exam_id",
        selectedExam,
      );

      await prefs.setString(
        "selected_exam_name",
        selectedExamName,
      );

      await prefs.setString(
        "full_name",
        _nameController.text.trim(),
      );

      debugPrint(
        "========== LOCAL DATA SAVED ==========",
      );

      final body = {
        "selectedClass": selectedClass,
        "examId": selectedExam,
      };

      debugPrint(
        "========== SAVE SELECTION API ==========",
      );

      debugPrint(
        "URL : $baseUrl/api/app/save-selection",
      );

      debugPrint(
        "BODY : ${jsonEncode(body)}",
      );

      final response = await http.post(
        Uri.parse(
          "$baseUrl/api/app/save-selection",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      debugPrint(
        "STATUS CODE : ${response.statusCode}",
      );

      debugPrint(
        "RESPONSE : ${response.body}",
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        debugPrint(
          "========== SAVE SUCCESS ==========",
        );
      } else {
        debugPrint(
          "========== SAVE FAILED ==========",
        );
      }
    } catch (e) {
      debugPrint(
        "SAVE USER SELECTION ERROR : $e",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
      true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_currentPage == 0) ...[
            Positioned.fill(
              child: Image.asset(
                "assets/images/bgg5.png",
                fit: BoxFit.cover,
              ),
            ),

            Positioned.fill(
              child: Container(
                color: Colors.black
                    .withOpacity(0.7),
              ),
            ),
          ],

          PageView(
            controller: _pageController,
            physics:
            const NeverScrollableScrollPhysics(),
            children: [
              _buildAuthPage(
                "Welcome to CORE",
                "Sign in to continue",
                _buildPhoneForm(),
                isWelcome: true,
              ),

              _buildAuthPage(
                "Verify OTP",
                "Enter the 6 digit OTP sent to your number",
                _buildOtpForm(),
                showBack: true,
              ),

              _buildAuthPage(
                "Select your class",
                "Choose your current learning stage.",
                _buildClassSelection(),
              ),

              _buildAuthPage(
                "Tell us your name",
                "Personalize your learning experience.",
                _buildNameForm(),
                showBack: true,
              ),

              _buildAuthPage(
                "Select your exam",
                "Decide your content and subject filters.",
                _buildExamSelection(),
                showBack: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuthPage(
      String title,
      String sub,
      Widget child, {
        bool showBack = false,
        bool isWelcome = false,
      }) {
    return SafeArea(
      child: SingleChildScrollView(
        physics:
        const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
            MediaQuery.of(context)
                .size
                .height,
          ),
          child: Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 30,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                if (showBack &&
                    _currentPage != 2)
                  IconButton(
                    onPressed:
                    _prevPage,
                    icon: const Icon(
                      Icons.arrow_back,
                      color:
                      Colors.white,
                      size: 28,
                    ),
                  ),

                if (!isWelcome) ...[
                  const SizedBox(
                    height: 20,
                  ),

                  Text(
                    title,
                    style:
                    const TextStyle(
                      color:
                      Colors.white,
                      fontSize: 24,
                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    sub,
                    style:
                    const TextStyle(
                      color: Colors
                          .white70,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(
                    height: 40,
                  ),

                  child,
                ] else ...[
                  SizedBox(
                    height:
                    MediaQuery.of(
                      context,
                    )
                        .size
                        .height *
                        0.45,
                  ),

                  Text(
                    title,
                    style:
                    const TextStyle(
                      color:
                      Colors.white,
                      fontSize: 22,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    sub,
                    style:
                    const TextStyle(
                      color: Colors
                          .white70,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(
                    height: 40,
                  ),

                  child,

                  const SizedBox(
                    height: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomButton(
      String text,
      VoidCallback? onPressed,
      ) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style:
        ElevatedButton.styleFrom(
          backgroundColor:
          Colors.transparent,
          elevation: 0,
          side: const BorderSide(
            color:
            AppColors.primaryOrange,
            width: 2,
          ),
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              12,
            ),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color:
            AppColors.primaryOrange,
            fontSize: 16,
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneForm() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed:
          _signInWithGoogle,
          icon: const FaIcon(
            FontAwesomeIcons.google,
            size: 22,
          ),
          label: const Text(
            "Continue with Google",
          ),
          style:
          ElevatedButton.styleFrom(
            minimumSize:
            const Size(
              double.infinity,
              55,
            ),
            backgroundColor:
            Colors.white
                .withOpacity(0.1),
            foregroundColor:
            Colors.white,
          ),
        ),

        const Padding(
          padding:
          EdgeInsets.symmetric(
            vertical: 15,
          ),
          child: Text(
            "OR",
            style: TextStyle(
              color:
              Colors.white54,
            ),
          ),
        ),

        TextField(
          controller:
          _phoneController,
          style: const TextStyle(
            color: Colors.white,
          ),
          decoration:
          const InputDecoration(
            hintText:
            "Mobile number",
            filled: true,
            fillColor:
            Colors.white10,
            border:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.all(
                Radius.circular(
                  12,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 15),

        _buildCustomButton(
          "Send OTP",
          _nextPage,
        ),
      ],
    );
  }

  Widget _buildOtpForm() {
    return Column(
      children: [
        TextField(
          controller:
          _otpController,
          keyboardType:
          TextInputType.number,
          style: const TextStyle(
            color: Colors.white,
          ),
          decoration:
          const InputDecoration(
            hintText:
            "Enter 6 digit OTP",
            filled: true,
            fillColor:
            Colors.white10,
            border:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.all(
                Radius.circular(
                  12,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        _buildCustomButton(
          "Verify",
          _nextPage,
        ),
      ],
    );
  }

  Widget _buildClassSelection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child:
              _selectableButton(
                "11th",
                "11th",
              ),
            ),

            const SizedBox(
              width: 15,
            ),

            Expanded(
              child:
              _selectableButton(
                "12th",
                "12th",
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        _selectableButton(
          "Dropper",
          "Dropper",
          isFull: true,
        ),

        const SizedBox(height: 20),

        _buildCustomButton(
          "Continue",
          selectedClass.isNotEmpty
              ? _nextPage
              : null,
        ),
      ],
    );
  }

  Widget _buildNameForm() {
    return Column(
      children: [
        TextField(
          controller:
          _nameController,
          onChanged: (value) {
            setState(() {});
          },
          style: const TextStyle(
            color: Colors.white,
          ),
          decoration:
          const InputDecoration(
            hintText:
            "Enter Full Name",
            filled: true,
            fillColor:
            Colors.white10,
            border:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.all(
                Radius.circular(
                  12,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        _buildCustomButton(
          "Continue",
          _nameController.text
              .trim()
              .isNotEmpty
              ? () {
            debugPrint(
              "NAME ENTERED : ${_nameController.text}",
            );

            _nextPage();
          }
              : null,
        ),
      ],
    );
  }

  Widget _buildExamSelection() {
    if (isExamLoading) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics:
          const NeverScrollableScrollPhysics(),
          itemCount: exams.length,
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 2.2,
          ),
          itemBuilder:
              (context, index) {
            final exam =
            exams[index];

            return _selectableButton(
              exam["name"] ?? "",
              exam["_id"] ?? "",
            );
          },
        ),

        const SizedBox(height: 40),

        _buildCustomButton(
          "Get Started",
          selectedExam.isNotEmpty
              ? () async {
            debugPrint(
              "GET STARTED CLICKED",
            );

            debugPrint(
              "SELECTED EXAM : $selectedExamName",
            );

            await saveUserSelections();

            if (!mounted) {
              return;
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                const MainShellDashboard(),
              ),
            );
          }
              : null,
        ),
      ],
    );
  }

  Widget _selectableButton(
      String label,
      String value, {
        bool isFull = false,
      }) {
    bool isSelected =
        value == selectedClass ||
            value ==
                selectedExam;

    return InkWell(
      onTap: () {
        setState(() {
          if (label == "11th" ||
              label == "12th" ||
              label ==
                  "Dropper") {
            selectedClass =
                value;
          } else {
            selectedExam =
                value;

            selectedExamName =
                label;
          }
        });

        debugPrint(
          "SELECTED : $label",
        );
      },
      child: Container(
        height: 70,
        width: isFull
            ? double.infinity
            : null,
        decoration:
        BoxDecoration(
          color: isSelected
              ? AppColors
              .primaryOrange
              .withOpacity(
            0.3,
          )
              : Colors.white10,
          borderRadius:
          BorderRadius.circular(
            12,
          ),
          border: Border.all(
            color: isSelected
                ? AppColors
                .primaryOrange
                : Colors.white24,
          ),
        ),
        alignment:
        Alignment.center,
        child: Text(
          label,
          textAlign:
          TextAlign.center,
          style:
          const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// import '../view/bottom_view_nav.dart';
// import '../utils/app_colors.dart';

// class OttAuthScreen extends StatefulWidget {
//   const OttAuthScreen({super.key});

//   @override
//   State<OttAuthScreen> createState() => _OttAuthScreenState();
// }

// class _OttAuthScreenState extends State<OttAuthScreen> {
//   final PageController _pageController = PageController();
//   final _phoneController = TextEditingController();
//   final _otpController = TextEditingController();
//   final _nameController = TextEditingController();

//   String selectedClass = "";
//   String selectedExam = "";
//   int _currentPage = 0;

//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   void _nextPage() {
//     _pageController.nextPage(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//     setState(() => _currentPage++);
//   }

//   void _prevPage() {
//     _pageController.previousPage(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//     setState(() => _currentPage--);
//   }

//   Future<void> _signInWithGoogle() async {
//     try {
//       debugPrint("========== GOOGLE SIGN IN START ==========");

//       final GoogleSignIn googleSignIn = GoogleSignIn();

//       debugPrint("Disconnecting old session...");
//       await googleSignIn.disconnect().catchError((e) {
//         debugPrint("DISCONNECT ERROR : $e");
//       });

//       debugPrint("Signing out old account...");
//       await googleSignIn.signOut();

//       debugPrint("Opening Google Sign In...");
//       final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

//       if (googleUser == null) {
//         debugPrint("USER CANCELLED GOOGLE LOGIN");
//         return;
//       }

//       debugPrint("GOOGLE USER : ${googleUser.email}");

//       final googleAuth = await googleUser.authentication;

//       debugPrint("ACCESS TOKEN : ${googleAuth.accessToken}");
//       debugPrint("ID TOKEN : ${googleAuth.idToken}");

//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       debugPrint("Firebase credential created");

//       final userCredential = await FirebaseAuth.instance.signInWithCredential(
//         credential,
//       );

//       debugPrint("FIREBASE LOGIN SUCCESS");
//       debugPrint("FIREBASE UID : ${userCredential.user?.uid}");
//       debugPrint("FIREBASE EMAIL : ${userCredential.user?.email}");

//       final firebaseToken = await userCredential.user!.getIdToken(true);

//       debugPrint("FIREBASE TOKEN : $firebaseToken");

//       const baseUrl = "http://192.168.1.15:5000";

//       debugPrint("========== API CALL ==========");
//       debugPrint("URL : $baseUrl/api/auth/google-login");

//       final response = await http.post(
//         Uri.parse("$baseUrl/api/auth/google-login"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"token": firebaseToken}),
//       );

//       debugPrint("STATUS CODE : ${response.statusCode}");
//       debugPrint("RESPONSE BODY : ${response.body}");

//       if (response.statusCode != 200) {
//         throw Exception(response.body);
//       }

//       final data = jsonDecode(response.body);

//       debugPrint("========== SAVE DATA ==========");

//       final prefs = await SharedPreferences.getInstance();

//       await prefs.setString("user_token", data["token"]);
//       await prefs.setBool("isLoggedIn", true);
//       await prefs.setString("user_name", data["user"]["name"] ?? "");
//       await prefs.setString("user_email", data["user"]["email"] ?? "");
//       await prefs.setString("profile_pic", data["user"]["profilePic"] ?? "");

//       debugPrint("TOKEN SAVED : ${data["token"]}");
//       debugPrint("NAME SAVED : ${data["user"]["name"]}");
//       debugPrint("EMAIL SAVED : ${data["user"]["email"]}");
//       debugPrint("PROFILE SAVED : ${data["user"]["profilePic"]}");

//       if (!mounted) return;

//       debugPrint("MOVING TO NEXT PAGE");

//       _pageController.jumpToPage(2);

//       setState(() {
//         _currentPage = 2;
//       });

//       debugPrint("========== GOOGLE LOGIN SUCCESS ==========");
//     } catch (e, stackTrace) {
//       debugPrint("========== GOOGLE LOGIN ERROR ==========");
//       debugPrint("ERROR : $e");
//       debugPrint("STACKTRACE : $stackTrace");

//       if (!mounted) return;

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(e.toString())));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           if (_currentPage == 0) ...[
//             Positioned.fill(
//               child: Image.asset('assets/images/bgg5.png', fit: BoxFit.cover),
//             ),
//             Positioned.fill(
//               child: Container(color: Colors.black.withOpacity(0.7)),
//             ),
//           ],
//           PageView(
//             controller: _pageController,
//             physics: const NeverScrollableScrollPhysics(),
//             children: [
//               _buildAuthPage(
//                 "Welcome to CORE",
//                 "Sign in to continue",
//                 _buildPhoneForm(),
//                 isWelcome: true,
//               ),
//               _buildAuthPage(
//                 "Verify OTP",
//                 "Enter the 6 digit OTP sent to your number",
//                 _buildOtpForm(),
//                 showBack: true,
//               ),
//               _buildAuthPage(
//                 "Select your class",
//                 "Choose your current learning stage.",
//                 _buildClassSelection(),
//                 showBack: true,
//               ),
//               _buildAuthPage(
//                 "Tell us your name",
//                 "Personalize your learning experience.",
//                 _buildNameForm(),
//                 showBack: true,
//               ),
//               _buildAuthPage(
//                 "Select your exam",
//                 "Decide your content and subject filters.",
//                 _buildExamSelection(),
//                 showBack: true,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAuthPage(
//     String title,
//     String sub,
//     Widget child, {
//     bool showBack = false,
//     bool isWelcome = false,
//   }) {
//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (showBack && _currentPage != 2)
//               IconButton(
//                 onPressed: () {
//                   _prevPage();
//                 },
//                 icon: const Icon(
//                   Icons.arrow_back,
//                   color: Colors.white,
//                   size: 28,
//                 ),
//               ),
//             if (!isWelcome) ...[
//               const SizedBox(height: 20),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 sub,
//                 style: const TextStyle(color: Colors.white70, fontSize: 16),
//               ),
//               const SizedBox(height: 40),
//               child,
//             ] else ...[
//               const Spacer(),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 22,
//                   fontWeight: FontWeight.normal,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 sub,
//                 style: const TextStyle(color: Colors.white70, fontSize: 16),
//               ),
//               const SizedBox(height: 40),
//               child,
//               const SizedBox(height: 20),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCustomButton(String text, VoidCallback? onPressed) {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           side: const BorderSide(color: AppColors.primaryOrange, width: 2),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         child: Text(
//           text,
//           style: const TextStyle(
//             color: AppColors.primaryOrange,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPhoneForm() => Column(
//     children: [
//       ElevatedButton.icon(
//         onPressed: _signInWithGoogle,
//         icon: const FaIcon(FontAwesomeIcons.google, size: 22),
//         label: const Text("Continue with Google"),
//         style: ElevatedButton.styleFrom(
//           minimumSize: const Size(double.infinity, 55),
//           backgroundColor: Colors.white.withOpacity(0.1),
//           foregroundColor: Colors.white,
//         ),
//       ),
//       const Padding(
//         padding: EdgeInsets.symmetric(vertical: 15),
//         child: Text("OR", style: TextStyle(color: Colors.white54)),
//       ),
//       TextField(
//         controller: _phoneController,
//         style: const TextStyle(color: Colors.white),
//         decoration: const InputDecoration(
//           hintText: "Mobile number",
//           filled: true,
//           fillColor: Colors.white10,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.all(Radius.circular(12)),
//           ),
//         ),
//       ),
//       const SizedBox(height: 15),
//       _buildCustomButton("Send OTP", _nextPage),
//     ],
//   );

//   Widget _buildOtpForm() => Column(
//     children: [
//       TextField(
//         controller: _otpController,
//         keyboardType: TextInputType.number,
//         style: const TextStyle(color: Colors.white),
//         decoration: const InputDecoration(
//           hintText: "Enter 6 digit OTP",
//           filled: true,
//           fillColor: Colors.white10,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.all(Radius.circular(12)),
//           ),
//         ),
//       ),
//       const SizedBox(height: 20),
//       _buildCustomButton("Verify", _nextPage),
//     ],
//   );

//   Widget _buildClassSelection() => Column(
//     children: [
//       Row(
//         children: [
//           Expanded(child: _selectableButton("11th", "11th")),
//           const SizedBox(width: 15),
//           Expanded(child: _selectableButton("12th", "12th")),
//         ],
//       ),
//       const SizedBox(height: 15),
//       _selectableButton("Dropper", "Dropper", isFull: true),
//       const SizedBox(height: 20),
//       _buildCustomButton(
//         "Continue",
//         selectedClass.isNotEmpty ? _nextPage : null,
//       ),
//     ],
//   );

//   Widget _buildNameForm() => Column(
//     children: [
//       TextField(
//         controller: _nameController,
//         style: const TextStyle(color: Colors.white),
//         decoration: const InputDecoration(
//           hintText: "Enter Full Name",
//           filled: true,
//           fillColor: Colors.white10,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.all(Radius.circular(12)),
//           ),
//         ),
//       ),
//       const SizedBox(height: 20),
//       _buildCustomButton("Continue", _nextPage),
//     ],
//   );

//   Widget _buildExamSelection() => Column(
//     children: [
//       Row(
//         children: [
//           Expanded(child: _selectableButton("NEET UG", "NEET")),
//           const SizedBox(width: 15),
//           Expanded(child: _selectableButton("JEE (Main+Adv)", "JEE")),
//         ],
//       ),
//       const SizedBox(height: 40),
//       _buildCustomButton(
//         "Get Started",
//         () => Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const MainShellDashboard()),
//         ),
//       ),
//     ],
//   );

//   Widget _selectableButton(String label, String value, {bool isFull = false}) {
//     bool isSelected = (value == selectedClass || value == selectedExam);
//     return InkWell(
//       onTap: () => setState(() {
//         if (value == "11th" || value == "12th" || value == "Dropper") {
//           selectedClass = value;
//         } else {
//           selectedExam = value;
//         }
//       }),
//       child: Container(
//         height: 70,
//         width: isFull ? double.infinity : null,
//         decoration: BoxDecoration(
//           color: isSelected
//               ? AppColors.primaryOrange.withOpacity(0.3)
//               : Colors.white10,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? AppColors.primaryOrange : Colors.white24,
//           ),
//         ),
//         alignment: Alignment.center,
//         child: Text(
//           label,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }