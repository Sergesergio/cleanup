import 'package:flutter/material.dart';
import '../../common/widgets/custom_navbar.dart';
import '../screens/landlord_home.dart';
import '../screens/landlord_profile.dart';
import '../screens/landlord_requests.dart';


class LandlordDashboard extends StatefulWidget {
  const LandlordDashboard({super.key});

  @override
  State<LandlordDashboard> createState() => _LandlordDashboardState();
}

class _LandlordDashboardState extends State<LandlordDashboard> {
  int _selectedIndex = 0;

  final _screens = const [
    LandlordHomeScreen(),
    LandlordRequestsScreen(),
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
