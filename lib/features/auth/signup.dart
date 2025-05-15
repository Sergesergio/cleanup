import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SignupScreen extends StatelessWidget {
  final String role;

  const SignupScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text("Sign Up as ${role.toUpperCase()}")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Call backend API
              },
              child: const Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
