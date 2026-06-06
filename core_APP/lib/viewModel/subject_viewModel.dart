import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/subject_model.dart';

class SubjectViewModel extends ChangeNotifier {
  List<SubjectItem> _subjects = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<SubjectItem> get subjects => _subjects;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final String baseUrl = "https://core-backend-38rr.onrender.com";

  Future<void> fetchSubjects() async {
    debugPrint("================================");
    debugPrint("FETCH SUBJECTS CALLED");
    debugPrint("================================");

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("user_token") ?? "";

      final examId =
          prefs.getString("selected_exam_id") ?? "";

      debugPrint("TOKEN => $token");
      debugPrint("EXAM ID => $examId");

      if (examId.isEmpty) {
        _errorMessage = "Exam ID not found";

        _isLoading = false;
        notifyListeners();

        return;
      }

      final url = Uri.parse(
        "$baseUrl/api/subjects/exam/$examId",
      );

      debugPrint("URL => $url");

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      debugPrint("STATUS => ${response.statusCode}");
      debugPrint("BODY => ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == true) {
          final List<dynamic> subjectsJson =
              data["subjects"] ?? [];

          _subjects = subjectsJson
              .map((e) => SubjectItem.fromJson(e))
              .toList();
        } else {
          _errorMessage =
              data["message"] ?? "Something went wrong";
        }
      } else {
        _errorMessage =
        "Server Error ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearSubjects() {
    _subjects.clear();
    notifyListeners();
  }
}