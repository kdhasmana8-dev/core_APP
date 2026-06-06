import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/test_model.dart';



class AssessmentViewModel extends ChangeNotifier {
  List<AssessmentModel> _assessments = [];
  bool _isLoading = false;

  List<AssessmentModel> get assessments => _assessments;
  bool get isLoading => _isLoading;

  AssessmentViewModel() {
    fetchAssessments();
  }

  Future<void> fetchAssessments() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
          'https://core-backend-38rr.onrender.com/api/assessments',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final List<dynamic> list =
              data['assessments'] ?? [];

          _assessments = list
              .map(
                (e) => AssessmentModel.fromJson(e),
          )
              .toList();

          debugPrint(
            "Assessments Loaded = ${_assessments.length}",
          );
        }
      }
    } catch (e) {
      debugPrint("Assessment Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  List<String> get availableCategories {
    final Set<String> categories = {"All"};

    for (var assessment in _assessments) {
      categories.add(
        assessment.subjectName.isEmpty
            ? "General"
            : assessment.subjectName,
      );
    }

    return categories.toList();
  }
}