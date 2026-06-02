import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
      // Get token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("user_token");

      debugPrint("========== FETCH NEW ARRIVALS ==========");
      debugPrint("TOKEN EXISTS: ${token != null}");

      if (token == null || token.isEmpty) {
        _errorMessage = 'No authentication token found. Please login again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/new-arrivals'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("NEW ARRIVALS STATUS: ${response.statusCode}");
      debugPrint("NEW ARRIVALS RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          _newArrivals = (data['newArrivals'] as List)
              .map((item) => NewArrival.fromJson(item))
              .toList();
          debugPrint("NEW ARRIVALS LOADED: ${_newArrivals.length}");
        } else {
          _errorMessage = data['message'] ?? 'Failed to load new arrivals';
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Session expired. Please login again.';
        // Clear invalid token
        await prefs.remove('user_token');
        await prefs.setBool('isLoggedIn', false);
      } else {
        _errorMessage = 'Failed to load new arrivals: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      debugPrint('Error fetching new arrivals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear data if needed
  void clearData() {
    _newArrivals = [];
    _errorMessage = null;
    notifyListeners();
  }
}
// // lib/viewModel/new_arrival_viewmodel.dart
// import 'package:core_app/model/new_arival.dart';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class NewArrivalViewModel extends ChangeNotifier {
//   List<NewArrival> _newArrivals = [];
//   bool _isLoading = false;
//   String? _errorMessage;

//   List<NewArrival> get newArrivals => _newArrivals;
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;

//   Future<void> fetchNewArrivals() async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       // Replace with your actual API URL
//       final response = await http.get(
//         Uri.parse('https://core-backend-38rr.onrender.com/api/new-arrivals'),
//         headers: {
//           'Content-Type': 'application/json',
//           // Add auth token if needed
//           // 'Authorization': 'Bearer YOUR_TOKEN',
//         },
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);

//         if (data['success'] == true) {
//           _newArrivals = (data['newArrivals'] as List)
//               .map((item) => NewArrival.fromJson(item))
//               .toList();
//         } else {
//           _errorMessage = 'Failed to load new arrivals';
//         }
//       } else {
//         _errorMessage = 'Failed to load new arrivals: ${response.statusCode}';
//       }
//     } catch (e) {
//       _errorMessage = 'Error: ${e.toString()}';
//       debugPrint('Error fetching new arrivals: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Clear data if needed
//   void clearData() {
//     _newArrivals = [];
//     _errorMessage = null;
//     notifyListeners();
//   }
// }