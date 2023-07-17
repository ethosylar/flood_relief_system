import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String _userId = '';

  bool get isLoggedIn => _isLoggedIn;
  String get userId => _userId;

  void login(String userId) {
    _isLoggedIn = true;
    _userId = userId;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userId = '';
    notifyListeners();
  }
}
