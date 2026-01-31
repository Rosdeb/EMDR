import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Ekhane API Call hobe
    await Future.delayed(const Duration(seconds: 2));

    _isLoading = false;
    notifyListeners();
    return true; // Success dhore nichhi
  }
}