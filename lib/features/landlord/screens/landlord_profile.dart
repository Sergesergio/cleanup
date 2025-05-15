import 'package:flutter/material.dart';

class LandlordProfileScreen extends StatelessWidget {
  const LandlordProfileScreen({super.key});

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
        child: Text('Landlord profile info here.'),
      ),
    );
  }
}
