import 'package:flutter/material.dart';
import '../../common/widgets/custom_navbar.dart';
import '../screens/accepted_requests_screen.dart';
import '../screens/available_requests_screen.dart';
import '../screens/collector_home.dart';
import '../screens/collector_profile.dart';

class CollectorDashboard extends StatefulWidget {
  const CollectorDashboard({super.key});

  @override
  State<CollectorDashboard> createState() => _CollectorDashboardState();
}

class _CollectorDashboardState extends State<CollectorDashboard> {
  int _selectedIndex = 0;

  final _screens = [
    const CollectorHomeScreen(),
    const AvailableRequestsScreen(),  // Add this file in your screens
    const AcceptedRequestsScreen(),   // Add this file in your screens
    CollectorProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        role: 'collector',
      ),
    );
  }
}
