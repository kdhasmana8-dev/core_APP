import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel extends ChangeNotifier {

  String? _userName;
  String? _userEmail;
  String? _profileUrl;

  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get profileUrl => _profileUrl;

  // SAVE USER
  Future<void> saveUser({
    required String name,
    required String email,
    String profile = "",
  }) async {

    _userName = name;
    _userEmail = email;
    _profileUrl = profile;

    final prefs = await SharedPreferences.getInstance();

    // SAME KEYS
    await prefs.setString("full_name", name);
    await prefs.setString("user_email", email);
    await prefs.setString("profile_pic", profile);

    notifyListeners();
  }

  // LOAD USER
  Future<void> loadUser() async {

    final prefs = await SharedPreferences.getInstance();

    // SAME KEYS
    _userName = prefs.getString("full_name");
    _userEmail = prefs.getString("user_email");
    _profileUrl = prefs.getString("profile_pic");

    notifyListeners();
  }

  // LOGOUT
  Future<void> logout() async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    _userName = null;
    _userEmail = null;
    _profileUrl = null;

    notifyListeners();
  }
}