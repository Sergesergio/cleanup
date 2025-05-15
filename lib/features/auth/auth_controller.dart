import 'package:flutter/material.dart';

class AuthController with ChangeNotifier {
  String role = ''; // 'landlord' or 'collector'

  void selectRole(String selected) {
    role = selected;
    notifyListeners();
  }
}
