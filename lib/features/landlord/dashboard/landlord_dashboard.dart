import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/ProfileScreen.dart';
import '../../auth/login.dart';
import '../../common/widgets/custom_navbar.dart';
import '../screens/landlord_home.dart'; // Ensure this points to the updated LandlordHomeScreen
import '../screens/request_history_screen.dart'; //// Assuming this is your request history screen
import 'package:cleanup/features/auth/role_selector.dart'; // <--- Adjust path if needed
// ... other imports

class LandlordDashboard extends StatefulWidget {
  final String userName;   // <--- ADD THIS
  final String userEmail;  // <--- ADD THIS
  final String userRole;   // <--- ADD THIS

  const LandlordDashboard({
    super.key,
    required this.userName,    // <--- ADD THIS
    required this.userEmail,   // <--- ADD THIS
    required this.userRole,    // <--- ADD THIS
  });

  @override
  State<LandlordDashboard> createState() => _LandlordDashboardState();
}

class _LandlordDashboardState extends State<LandlordDashboard> {
  int _selectedIndex = 0;

  late final List<Widget> _screens; // Use late final as it depends on widget properties

  @override
  void initState() {
    super.initState();
    _screens = [
      LandlordHomeScreen( // <--- Pass all user details to LandlordHomeScreen
        userName: widget.userName,
        userEmail: widget.userEmail,
        userRole: widget.userRole,
      ),
      // const CreateRequestScreen(),
      const RequestHistoryScreen(),
      ProfileScreen( // <--- Pass all user details to ProfileScreen
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // AppBar can be handled by individual screens or the dashboard itself
        title: const Text("Landlord Dashboard"),
        automaticallyImplyLeading: false, // Hide default back button
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.clearUserSession(); // Use the logout service
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const RoleSelectorScreen()), // Redirect to login
                      (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        role: 'landlord',
      ),
    );
  }
}
