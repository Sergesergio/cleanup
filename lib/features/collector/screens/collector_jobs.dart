import 'package:flutter/material.dart';

class CollectorJobsScreen extends StatelessWidget {
  const CollectorJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Available Pickup Jobs'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'No jobs available yet.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
