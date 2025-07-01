import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final String role;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final isLandlord = role == 'landlord';

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed, // Allows 4+ items
      selectedItemColor: Colors.green[800],
      unselectedItemColor: Colors.grey,
      items: isLandlord
          ? const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home), label: 'Home'),
        // BottomNavigationBarItem(
        //     icon: Icon(Icons.add_box), label: 'New Request'),
        BottomNavigationBarItem(
            icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person), label: 'Profile'),
      ]
          : const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.assignment), label: 'Available'),
        BottomNavigationBarItem(
            icon: Icon(Icons.check_circle), label: 'Accepted'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
