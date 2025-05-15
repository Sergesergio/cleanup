import 'package:flutter/material.dart';
import 'login.dart';
import '../../core/theme.dart';

class RoleSelectorScreen extends StatelessWidget {
  const RoleSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Your Role")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _roleCard(context, "Landlord", Icons.home, "landlord"),
            const SizedBox(height: 20),
            _roleCard(context, "Garbage Collector", Icons.local_shipping, "collector"),
          ],
        ),
      ),
    );
  }

  Widget _roleCard(BuildContext context, String title, IconData icon, String role) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen(role: role)),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Icon(icon, size: 40, color: AppTheme.primaryGreen),
              const SizedBox(width: 20),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
      ),
    );
  }
}
