import 'package:flutter/material.dart';

class CollectorProfileScreen extends StatelessWidget {
  const CollectorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Your Profile'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Collector profile info here.'),
      ),
    );
  }
}
