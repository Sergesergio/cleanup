import 'package:flutter/material.dart';
import '../features/auth/login.dart'; // Adjust the path if needed

class ProfileScreen extends StatelessWidget {
  final String name;
  final String email;
  final String role;

  const ProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // 📸 Drawer Header with Profile Info
            UserAccountsDrawerHeader(
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.grey),
              ),
              accountName: Text(name),
              accountEmail: Text(email),
            ),

            // 🧾 Menu Items
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("User Information"),
              subtitle: Text("Role: $role"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("Notifications"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("About"),
              onTap: () {},
            ),

            const Spacer(),

            // 🚪 Logout Button
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {
                // Navigate back to login screen
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(role: role),
                  ),
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),

      // 🏠 Main Body Placeholder
      body: Center(
        child: Text(
          "Welcome, $name!",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
