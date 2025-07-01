import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:cleanup/services/api_service.dart';
import 'package:cleanup/services/auth_service.dart'; // For logout
import 'package:cleanup/features/auth/login.dart'; // For logout redirect
import 'package:cleanup/features/collector/screens/available_requests_screen.dart'; // Example navigation target
import 'package:cleanup/features/collector/screens/accepted_requests_screen.dart'; // Example navigation target
import 'package:cleanup/widgets/ProfileScreen.dart'; // Assuming this is your profile screen


class CollectorHomeScreen extends StatefulWidget {
  final String userName; // <--- ADD THIS LINE
  final String userEmail; // <--- ADD THIS LINE (for drawer if needed)
  final String userRole; // <--- ADD THIS LINE (for drawer if needed)

  const CollectorHomeScreen({
    super.key,
    required this.userName, // <--- ADD THIS TO THE CONSTRUCTOR
    this.userEmail = 'collector@example.com', // Provide default or require from Dashboard
    this.userRole = 'collector', // Provide default or require from Dashboard
  });

  @override
  State<CollectorHomeScreen> createState() => _CollectorHomeScreenState();
}

class _CollectorHomeScreenState extends State<CollectorHomeScreen> {
  late Future<List<Map<String, dynamic>>> _availableRequestsFuture;
  late Future<List<Map<String, dynamic>>> _myActiveRequestsFuture;
  Map<String, int> _requestCounts = {
    'available': 0,
    'in_progress': 0,
    'completed_today': 0, // Dummy for now
  };

  @override
  void initState() {
    super.initState();
    _fetchCollectorData();
  }

  void _fetchCollectorData() {
    setState(() {
      _availableRequestsFuture = ApiService.getAvailableRequests();
      _myActiveRequestsFuture = ApiService.getMyActiveRequests(); // Requests assigned to this collector

      _availableRequestsFuture.then((requests) {
        if (mounted) {
          setState(() {
            _requestCounts['available'] = requests.length;
          });
        }
      }).catchError((e) {
        print("CollectorHomeScreen: Error fetching available requests: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load available requests: ${e.toString()}')),
          );
        }
      });

      _myActiveRequestsFuture.then((requests) {
        if (mounted) {
          setState(() {
            _requestCounts['in_progress'] = requests.length;
          });
        }
      }).catchError((e) {
        print("CollectorHomeScreen: Error fetching active requests: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load active requests: ${e.toString()}')),
          );
        }
      });
    });
  }

  Future<void> _logout() async {
    await AuthService.clearUserSession();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen(role: 'collector')), // Redirect to login
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collector Dashboard'),
        backgroundColor: Colors.blue[700], // Changed color for collector
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(widget.userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              accountEmail: Text(widget.userEmail), // Using userEmail from widget
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
                  style: TextStyle(fontSize: 40.0, color: Theme.of(context).primaryColor),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue[700], // Changed color for collector
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                _fetchCollectorData(); // Refresh home data
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping),
              title: const Text('Available Pickups'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AvailableRequestsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('My Accepted Pickups'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AcceptedRequestsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen(
                    name: widget.userName,
                    email: widget.userEmail,
                    role: widget.userRole,
                  )),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchCollectorData();
          await Future.wait([_availableRequestsFuture, _myActiveRequestsFuture]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 40, color: Colors.blue), // Changed icon/color
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello, ${widget.userName}!",
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Ready to make a difference today?",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Overview of Requests
              const Text("Pickup Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildCountCard("Available", _requestCounts['available']!, Icons.list, Colors.blue),
                  _buildCountCard("In Progress", _requestCounts['in_progress']!, Icons.pending_actions, Colors.orange),
                  _buildCountCard("Completed Today", _requestCounts['completed_today']!, Icons.done_all, Colors.green),
                  // You might add a 'Total Completed' or 'Rejected' count here
                ],
              ),
              const SizedBox(height: 20),

              // Quick Actions
              const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AvailableRequestsScreen()),
                    );
                  },
                  icon: const Icon(Icons.search),
                  label: const Text("View Available Pickups"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AcceptedRequestsScreen()),
                    );
                  },
                  icon: const Icon(Icons.assignment),
                  label: const Text("View My Accepted Pickups"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              // You might add other actions like "Report an Issue" or "Update Status"
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountCard(String title, int count, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// Extension to format DateTime for display (retained for consistency, though not used in this specific content yet)
extension DateTimeExtension on DateTime {
  String toShortDate() {
    return DateFormat('dd/MM/yy').format(this);
  }
}