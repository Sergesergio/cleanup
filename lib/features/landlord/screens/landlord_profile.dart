// lib/screens/landlord/landlord_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandlordProfileScreen extends StatelessWidget {
  void logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Landlord Profile')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => logout(context),
          child: Text("Logout"),
        ),
      ),
    );
  }
}
