import 'package:flutter/material.dart';
import '../../common/widgets/custom_navbar.dart';
import '../screens/create_request.dart';
import '../screens/landlord_home.dart';
import '../screens/landlord_profile.dart';
import '../screens/request_history_screen.dart'; // Request history

class LandlordDashboard extends StatefulWidget {
  const LandlordDashboard({super.key});

  @override
  State<LandlordDashboard> createState() => _LandlordDashboardState();
}

class _LandlordDashboardState extends State<LandlordDashboard> {
  int _selectedIndex = 0;

  final _screens = [
    const LandlordHomeScreen(),
    const CreateRequestScreen(),     // Add this file in your screens
    const RequestHistoryScreen(),    // Add this file in your screens
    LandlordProfileScreen(),
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
        role: 'landlord',
      ),
    );
  }
}
