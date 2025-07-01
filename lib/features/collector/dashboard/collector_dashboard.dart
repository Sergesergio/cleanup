import 'package:flutter/material.dart';
import 'package:cleanup/widgets/ProfileScreen.dart'; // Ensure this path is correct
import 'package:cleanup/features/collector/screens/accepted_requests_screen.dart'; // Ensure this path is correct
import 'package:cleanup/features/collector/screens/available_requests_screen.dart'; // Ensure this path is correct
import 'package:cleanup/features/collector/screens/collector_home.dart'; // Ensure this path is correct
import 'package:cleanup/services/auth_service.dart'; // For logout functionality
import 'package:cleanup/features/auth/login.dart';
import 'package:cleanup/features/auth/role_selector.dart';


import '../../common/widgets/custom_navbar.dart'; // For redirecting to login

class CollectorDashboard extends StatefulWidget {
  final String userName; // <--- ADD THIS LINE
  final String userEmail; // <--- ADD THIS LINE
  final String userRole; // <--- ADD THIS LINE

  const CollectorDashboard({
    super.key,
    required this.userName, // <--- AND THIS TO THE CONSTRUCTOR
    required this.userEmail, // <--- AND THIS TO THE CONSTRUCTOR
    required this.userRole, // <--- AND THIS TO THE CONSTRUCTOR
  });

  @override
  State<CollectorDashboard> createState() => _CollectorDashboardState();
}

class _CollectorDashboardState extends State<CollectorDashboard> {
  int _selectedIndex = 0;

  // Use late final for _screens as it depends on widget properties
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      CollectorHomeScreen(
        userName: widget.userName,
        userEmail: widget.userEmail, // <--- Make sure this is passed
        userRole: widget.userRole,   // <--- Make sure this is passed
      ),
      const AvailableRequestsScreen(),
      const AcceptedRequestsScreen(),
      ProfileScreen(
        name: widget.userName,
        email: widget.userEmail,
        role: widget.userRole,
      ),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    await AuthService.clearUserSession();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const RoleSelectorScreen()), // Redirect to login
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Collector Dashboard"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Hide default back button
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        role: 'collector',
      ),
    );
  }
}