import 'package:cleanup/features/auth/signup.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/api_service.dart';
import '../collector/dashboard/collector_dashboard.dart';
import '../landlord/dashboard/landlord_dashboard.dart';

class LoginScreen extends StatelessWidget {
  final String role;

  const LoginScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text("Login as ${role.toUpperCase()}")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
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
              onPressed: () async {
                final email = emailController.text.trim();
                final password = passwordController.text.trim();

                if (email.isEmpty || password.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (_) => const AlertDialog(
                      title: Text("Error"),
                      content: Text("Please fill in all fields."),
                    ),
                  );
                  return;
                }

                final userData = await ApiService.loginUser(
                  email: email,
                  password: password,
                );

                if (userData != null && userData['role'] == role.toLowerCase()) {
                  // ✅ You can save the token with shared_preferences or Provider here

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Success"),
                      content: Text("Logged in as ${userData['role']}"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // close dialog
                            // 🧭 Navigate to role-specific dashboard
                            // Example:
                            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LandlordDashboard()));
                          },
                          child: const Text("Continue"),
                        ),
                      ],
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (_) => const AlertDialog(
                      title: Text("Login Failed"),
                      content: Text("Invalid credentials or role mismatch."),
                    ),
                  );
                }
              },

              child: const Text("Login"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close the dialog first

                if (role.toLowerCase() == "collector") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => CollectorDashboard()),
                  );
                } else if (role.toLowerCase() == "landlord") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LandlordDashboard()),
                  );
                }
              },
              child: const Text("Continue"),
            ),

          ],
        ),
      ),
    );
  }
}
