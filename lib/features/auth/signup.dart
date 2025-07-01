import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:cleanup/features/auth/login.dart'; // Import the LoginScreen

class SignupScreen extends StatelessWidget {
  final String role;

  const SignupScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up as ${role.toUpperCase()}"),
        backgroundColor: Colors.green[700], // Consistent app bar color
        foregroundColor: Colors.white,
        centerTitle: true, // Center the app bar title
      ),
      body: SingleChildScrollView( // Allows scrolling if content overflows
        padding: const EdgeInsets.all(24.0), // Increased padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
          crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children horizontally
          children: [
            // Logo or app icon placeholder
            Icon(
              Icons.app_registration, // Example icon for signup
              size: 100,
              color: Colors.green[700],
            ),
            const SizedBox(height: 30),

            Text(
              "Join as a ${role.toUpperCase()}!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Create your account to get started",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                hintText: "Enter your full name",
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                hintText: "Enter your email",
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                hintText: "Choose a strong password",
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final email = emailController.text.trim();
                final password = passwordController.text.trim();

                if (name.isEmpty || email.isEmpty || password.isEmpty) {
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Error"),
                        content: const Text("Please fill in all fields."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    );
                  }
                  return;
                }

                try {
                  final result = await ApiService.registerUser(
                    name: name,
                    email: email,
                    password: password,
                    role: role.toLowerCase(), // Ensure lowercase consistency
                  );

                  if (result == true) {
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Success"),
                          content: const Text("Registration successful! You can now log in."),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close dialog
                                Navigator.pop(context); // Go back to login screen
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    throw Exception("Registration failed. Please try again.");
                  }
                } catch (e) {
                  print("Signup error: $e");

                  String errorMessage = "An unexpected error occurred.";
                  if (e is Exception) {
                    errorMessage = e.toString().replaceFirst('Exception: ', '');
                  } else {
                    errorMessage = "Failed to sign up: ${e.toString()}";
                  }

                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Signup Failed"),
                        content: Text(errorMessage),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700], // Button background color
                foregroundColor: Colors.white, // Button text color
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text("Sign Up"),
            ),
            const SizedBox(height: 20),

            TextButton(
              onPressed: () {
                if (context.mounted) {
                  Navigator.pop(context); // Go back to the previous screen (should be login)

                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.green[700], // Text button color
              ),
              child: const Text("Already have an account? Login here"),
            ),
          ],
        ),
      ),
    );
  }
}
