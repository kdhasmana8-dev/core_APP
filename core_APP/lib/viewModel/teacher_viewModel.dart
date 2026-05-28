import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/teacher_model.dart';

class TeacherViewModel extends ChangeNotifier {
  List<Teacher> _teachers = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Teacher> get teachers => _teachers;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  TeacherViewModel() {
    fetchTeachers();
  }

  Future<void> fetchTeachers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('http://192.168.1.22:5000/api/teachers'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> dataList = responseData['data'] ?? [];

        _teachers = dataList.map((json) => Teacher.fromJson(json)).toList();
        _errorMessage = '';
      } else {
        _errorMessage = 'Failed to load data: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}