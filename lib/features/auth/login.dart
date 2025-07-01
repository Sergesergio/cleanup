import 'package:cleanup/features/auth/signup.dart';
import 'package:flutter/material.dart';
import 'package:cleanup/services/api_service.dart'; // Make sure this path is correct
import 'package:cleanup/services/auth_service.dart'; // Make sure this path is correct
import '../collector/dashboard/collector_dashboard.dart';
import '../landlord/dashboard/landlord_dashboard.dart';   // Adjust import path if different


class LoginScreen extends StatelessWidget {
  final String role;

  const LoginScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text("Login as ${role.toUpperCase()}"),
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
              Icons.cleaning_services, // Example icon
              size: 100,
              color: Colors.green[700],
            ),
            const SizedBox(height: 30),

            Text(
              "Welcome Back, ${role.toUpperCase()}!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Sign in to continue",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),

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
                hintText: "Enter your password",
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
                final email = emailController.text.trim();
                final password = passwordController.text.trim();

                if (email.isEmpty || password.isEmpty) {
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
                  final userData = await ApiService.loginUser(
                    email: email,
                    password: password,
                  );

                  if (userData == null) {
                    throw Exception("Login failed. Please check your credentials.");
                  }

                  final String token = userData['token'] as String;
                  final String userRole = userData['role'] as String;
                  final String userName = userData['name'] as String? ?? 'User';
                  final String userEmail = userData['email'] as String? ?? 'No Email';
                  final String userId = userData['_id'] as String;

                  if (userRole.toLowerCase() != role.toLowerCase()) {
                    await AuthService.clearUserSession();
                    throw Exception("Logged-in role '$userRole' does not match expected role '$role'. Please select the correct role.");
                  }

                  await AuthService.saveUserSession(
                    userToken: token,
                    userId: userId,
                    userRole: userRole,
                  );

                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Success"),
                        content: Text("Logged in as ${userRole.toUpperCase()}"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              if (context.mounted) {
                                Navigator.pop(context);

                                if (userRole.toLowerCase() == "collector") {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CollectorDashboard(
                                        userName: userName,
                                        userEmail: userEmail,
                                        userRole: userRole,
                                      ),
                                    ),
                                  );
                                } else if (userRole.toLowerCase() == "landlord") {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LandlordDashboard(
                                        userName: userName,
                                        userEmail: userEmail,
                                        userRole: userRole,
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text("Continue"),
                          ),
                        ],
                      ),
                    );
                  }
                } catch (e) {
                  print("Login error: $e");

                  String errorMessage = "An unexpected error occurred.";
                  if (e is Exception) {
                    errorMessage = e.toString().replaceFirst('Exception: ', '');
                  } else {
                    errorMessage = "Failed to login: ${e.toString()}";
                  }

                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Login Failed"),
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
              child: const Text("Login"),
            ),
            const SizedBox(height: 20),

            TextButton(
              onPressed: () {
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupScreen(role: '')),
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.green[700], // Text button color
              ),
              child: const Text("Don't have an account? Sign up here"),
            ),
          ],
        ),
      ),
    );
  }
}
// import 'package:cleanup/features/auth/signup.dart';
// import 'package:flutter/material.dart';
// import 'package:cleanup/services/api_service.dart'; // Make sure this path is correct
// import 'package:cleanup/services/auth_service.dart'; // Make sure this path is correct
// import '../collector/dashboard/collector_dashboard.dart';
// import '../landlord/dashboard/landlord_dashboard.dart';   // Adjust import path if different
//
//
// class LoginScreen extends StatelessWidget {
//   final String role;
//
//   const LoginScreen({super.key, required this.role});
//
//   @override
//   Widget build(BuildContext context) {
//     final emailController = TextEditingController();
//     final passwordController = TextEditingController();
//
//     return Scaffold(
//       appBar: AppBar(title: Text("Login as ${role.toUpperCase()}")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(labelText: "Email"),
//             ),
//             TextField(
//               controller: passwordController,
//               obscureText: true,
//               decoration: const InputDecoration(labelText: "Password"),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 final email = emailController.text.trim();
//                 final password = passwordController.text.trim();
//
//                 if (email.isEmpty || password.isEmpty) {
//                   if (context.mounted) {
//                     showDialog(
//                       context: context,
//                       builder: (_) => const AlertDialog(
//                         title: Text("Error"),
//                         content: Text("Please fill in all fields."),
//                       ),
//                     );
//                   }
//                   return;
//                 }
//
//                 try {
//                   // Attempt to log in the user
//                   final userData = await ApiService.loginUser(
//                     email: email,
//                     password: password,
//                   );
//
//                   if (userData == null) {
//                     // This case is typically handled by ApiService throwing an exception,
//                     // but keeping this check as a safeguard or for specific null handling.
//                     throw Exception("Login failed. Please check your credentials.");
//                   }
//
//                   // Extract all necessary user data directly from the login response
//                   final String token = userData['token'] as String;
//                   final String userRole = userData['role'] as String;
//                   // These fields are returned by ApiService.loginUser as per our previous updates
//                   final String userName = userData['name'] as String? ?? 'User';
//                   final String userEmail = userData['email'] as String? ?? 'No Email';
//                   final String userId = userData['_id'] as String;
//
//                   // Match role ignoring case
//                   if (userRole.toLowerCase() != role.toLowerCase()) {
//                     // Clear session immediately if roles don't match.
//                     await AuthService.clearUserSession();
//                     throw Exception("Logged-in role '$userRole' does not match expected role '$role'. Please select the correct role.");
//                   }
//
//                   // Save the user session with all necessary details
//                   // This is the CRUCIAL step that must happen AFTER successful login
//                   // and before any other authenticated API calls.
//                   await AuthService.saveUserSession(
//                     userToken: token,
//                     userId: userId,
//                     userRole: userRole,
//                   );
//
//                   if (context.mounted) {
//                     showDialog(
//                       context: context,
//                       builder: (_) => AlertDialog(
//                         title: const Text("Success"),
//                         content: Text("Logged in as ${userRole.toUpperCase()}"),
//                         actions: [
//                           TextButton(
//                             onPressed: () {
//                               if (context.mounted) {
//                                 Navigator.pop(context); // Close the dialog
//
//                                 if (userRole.toLowerCase() == "collector") {
//                                   Navigator.pushReplacement(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (_) => CollectorDashboard(
//                                         userName: userName,
//                                         userEmail: userEmail,
//                                         userRole: userRole,
//                                       ),
//                                     ),
//                                   );
//                                 } else if (userRole.toLowerCase() == "landlord") {
//                                   Navigator.pushReplacement(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (_) => LandlordDashboard(
//                                         userName: userName,
//                                         userEmail: userEmail,
//                                         userRole: userRole,
//                                       ),
//                                     ),
//                                   );
//                                 }
//                               }
//                             },
//                             child: const Text("Continue"),
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//                 } catch (e) {
//                   print("Login error: $e"); // For debugging
//
//                   String errorMessage = "An unexpected error occurred.";
//                   if (e is Exception) {
//                     errorMessage = e.toString().replaceFirst('Exception: ', '');
//                   } else {
//                     errorMessage = "Failed to login: ${e.toString()}";
//                   }
//
//                   if (context.mounted) {
//                     showDialog(
//                       context: context,
//                       builder: (_) => AlertDialog(
//                         title: const Text("Login Failed"),
//                         content: Text(errorMessage),
//                       ),
//                     );
//                   }
//                 }
//               },
//               child: const Text("Login"),
//             ),
//
//             TextButton(
//               onPressed: () {
//                 if (context.mounted) {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const SignupScreen(role: '')),
//                   );
//                 }
//               },
//               child: const Text("Don't have an account? Sign up here"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }