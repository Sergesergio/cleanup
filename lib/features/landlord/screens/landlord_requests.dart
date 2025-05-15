import 'package:flutter/material.dart';

class LandlordRequestsScreen extends StatelessWidget {
  const LandlordRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('My Pickup Requests'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'You have no pickup requests yet.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
