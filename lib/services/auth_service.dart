import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

class AuthService with ChangeNotifier {
  String? _token;
  User? _user;
  bool _isInitialized = false;

  String? get token => _token;
  User? get user => _user;
  bool get isAuthenticated => _token != null && _user != null;
  bool get isInitialized => _isInitialized;

  AuthService() {
    _loadAuthData();
  }

  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('authToken');
    final userJson = prefs.getString('currentUser');

    if (userJson != null) {
      try {
        _user = User.fromJson(jsonDecode(userJson));
      } catch (e) {
        // Fallback für altes Format
        final parts = userJson.split('|');
        if (parts.length >= 2) {
          _user = User(username: parts[0], email: parts[1]);
        }
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setAuth(String token, User user) async {
    _token = token;
    _user = user;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    await prefs.setString('currentUser', jsonEncode(user.toJson()));

    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _user = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('currentUser');

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (_user != null) {
      await prefs.setString('currentUser', jsonEncode(_user!.toJson()));
    }
    notifyListeners();
  }

  Future<void> updateUser(User user) async {
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUser', jsonEncode(user.toJson()));
    notifyListeners();
  }
}
