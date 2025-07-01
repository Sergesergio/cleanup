import 'package:flutter/material.dart';
import 'package:cleanup/features/auth/role_selector.dart';
import 'package:cleanup/core/theme.dart';
import 'package:cleanup/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.initializeBaseUrl();
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

    return const RoleSelectorScreen(); // Default starting screen
  }
}