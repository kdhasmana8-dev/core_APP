import 'package:flutter/material.dart';
import '../model/test_model.dart';

class TestViewModel extends ChangeNotifier {
  // Private list of tests
  final List<TestModel> _tests = [
    // JEE Main Tests
    TestModel(
        id: '1',
        title: 'Full Mock Test - 01',
        subject: 'Physics',
        questions: 45,
        duration: 60,
        category: 'Main',
        imagePath: 'assets/images/ban1.jpg',
    ),
    TestModel(
        id: '2',
        title: 'Mechanics Chapter Test',
        subject: 'Physics',
        questions: 20,
        duration: 30,
        category: 'Main',
        imagePath: 'assets/images/ban2.jpg'
    ),

    // JEE Advanced Tests
    TestModel(
        id: '3',
        title: 'Advanced Calculus Quiz',
        subject: 'Maths',
        questions: 30,
        duration: 90,
        category: 'Advanced',
        imagePath: 'assets/images/ban.jpg'
    ),

    // Boards Tests
    TestModel(
        id: '4',
        title: 'Chemistry Board Prep',
        subject: 'Chemistry',
        questions: 35,
        duration: 45,
        category: 'Boards',
        imagePath: 'assets/images/ban1.jpg'
    ),
  ];

  // Getters
  List<TestModel> get tests => _tests;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Constructor
  TestViewModel() {
    fetchTests();
  }

  // Fetch Logic
  Future<void> fetchTests() async {
    _isLoading = true;
    notifyListeners();

    // API Simulation
    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();
  }

  // Filter Logic
  List<TestModel> getTestsByCategory(String category) {
    if (category == "All") return _tests;
    return _tests.where((t) => t.category == category).toList();
  }
}