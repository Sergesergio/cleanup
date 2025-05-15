import 'package:flutter/material.dart';
import 'features/auth/role_selector.dart';
import 'core/theme.dart';

void main() {
  runApp(const CleanWasteApp());
}

class CleanWasteApp extends StatelessWidget {
  const CleanWasteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clean Waste Pickup',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Here you can check if user is logged in (simulate for now)
    return const RoleSelectorScreen(); // Default starting screen
  }
}
