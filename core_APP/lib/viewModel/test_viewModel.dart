import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/test_model.dart';

class TestViewModel extends ChangeNotifier {
  List<TestModel> _tests = [];
  bool _isLoading = false;

  List<TestModel> get tests => _tests;
  bool get isLoading => _isLoading;

  // Constructor call karte hi data load ho jaye
  TestViewModel() {
    fetchTests();
  }

  // API Fetch Logic
  Future<void> fetchTests() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://core-backend-38rr.onrender.com/api/tests/all'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Response check: success true hona chahiye
        if (data['success'] == true && data['tests'] != null) {
          List<dynamic> testsJson = data['tests'];

          // JSON ko Model mein convert karein
          // (TestModel.fromJson ab updated structure handle karega)
          _tests = testsJson.map((json) => TestModel.fromJson(json)).toList();
        }
      } else {
        debugPrint("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Exception in fetchTests: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // UI ke filter tabs ke liye dynamic categories nikalna
  List<String> get availableCategories {
    // "All" pehle hona chahiye
    Set<String> categories = {"All"};

    // API se aayi category names ko add karein
    for (var test in _tests) {
      categories.add(test.category);
    }

    return categories.toList();
  }
}