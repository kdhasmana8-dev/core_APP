import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/new_arrival_model.dart';

class NewArrivalViewModel extends ChangeNotifier {
  List<NewArrival> _newArrivals = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<NewArrival> get newArrivals => _newArrivals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final String baseUrl = "https://core-backend-38rr.onrender.com";

  Future<void> fetchNewArrivals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("user_token");

      if (token == null) {
        _errorMessage = "Token missing. Please login again.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/reels/new-arrivals'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List reels = data['reels'] ?? [];

        _newArrivals = reels
            .map((e) => NewArrival.fromJson(e))
            .toList();
      } else {
        _errorMessage = data['message'] ?? "Something went wrong";
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _newArrivals = [];
    _errorMessage = null;
    notifyListeners();
  }
}