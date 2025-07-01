// import 'package:flutter/material.dart';
//
// import '../../auth/login.dart';
//
// class ProfileScreen extends StatelessWidget {
//   final String name;
//   final String email;
//   final String role;
//
//   const ProfileScreen({
//     super.key,
//     required this.name,
//     required this.email,
//     required this.role,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Profile"),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // 🧑 Profile Picture Placeholder
//             CircleAvatar(
//               radius: 50,
//               backgroundColor: Colors.grey[300],
//               child: const Icon(Icons.person, size: 50, color: Colors.white),
//             ),
//             const SizedBox(height: 10),
//
//             // 👤 Name and Email
//             Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             Text(email, style: const TextStyle(color: Colors.grey)),
//
//             const SizedBox(height: 30),
//
//             // 📋 Menu Options (Non-functional)
//             ListTile(
//               leading: const Icon(Icons.info),
//               title: const Text("User Information"),
//               subtitle: Text("Role: $role"),
//             ),
//             const Divider(),
//
//             ListTile(
//               leading: const Icon(Icons.settings),
//               title: const Text("Settings"),
//               onTap: () {}, // Placeholder
//             ),
//             ListTile(
//               leading: const Icon(Icons.notifications),
//               title: const Text("Notifications"),
//               onTap: () {}, // Placeholder
//             ),
//             ListTile(
//               leading: const Icon(Icons.info_outline),
//               title: const Text("About"),
//               onTap: () {}, // Placeholder
//             ),
//
//             const Spacer(),
//
//             // 🔓 Logout Button
//             ElevatedButton.icon(
//               onPressed: () {
//                 // Clear token/session if needed
//
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (_) => LoginScreen(role: role)),
//                       (route) => false,
//                 );
//               },
//               icon: const Icon(Icons.logout),
//               label: const Text("Logout"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
