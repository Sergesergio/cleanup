import 'package:cleanup/features/landlord/screens/request_history_screen.dart';
import 'package:cleanup/features/landlord/screens/submit_request_screen.dart'; // Ensure this is the correct import for your SubmitRequestScreen
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:cleanup/services/api_service.dart';
import 'package:cleanup/services/auth_service.dart'; // For logout
import 'package:cleanup/widgets/ProfileScreen.dart';

import '../../auth/login.dart'; // Assuming this is your login screen

class LandlordHomeScreen extends StatefulWidget {
  final String userName; // Receive userName from LandlordDashboard
  final String userEmail; // Receive userEmail from LandlordDashboard
  final String userRole; // Receive userRole from LandlordDashboard

  const LandlordHomeScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
  });

  @override
  State<LandlordHomeScreen> createState() => _LandlordHomeScreenState();
}

class _LandlordHomeScreenState extends State<LandlordHomeScreen> {

  Future<List<Map<String, dynamic>>>? _currentRequestsFuture; // Now nullable to indicate initial loading
  Map<String, dynamic>? _nextPickup;
  Map<String, int> _requestCounts = {
    'total': 0,
    'pending': 0,
    'in_progress': 0,
    'collected': 0,
  };

  @override
  void initState() {
    super.initState();
    print('LandlordHomeScreen: initState called. Fetching landlord data...');
    _fetchLandlordData(); // Initial data fetch
  }

  // This method now fetches data AND updates the derived state variables
  void _fetchLandlordData() {
    print('LandlordHomeScreen: _fetchLandlordData initiated.'); // Added log
    final future = ApiService.getMyRequests();

    setState(() {
      _currentRequestsFuture = future;
    });

    // Handle the result of the future once it completes (success or error)
    future.then((requests) {
      // These setState calls are safe because they occur after the Future completes
      // and Flutter will schedule a new build cycle.
      if (mounted) {
        setState(() {
          _calculateRequestCountsInternal(requests); // Updated name to indicate internal call
          _findNextPickupInternal(requests);        // Updated name to indicate internal call
          print('LandlordHomeScreen: Data fetched and state updated.'); // Added log
        });
      }
    }).catchError((e) {
      print("LandlordHomeScreen: Error fetching landlord requests: $e");
      if (mounted) {
        // You might want to reset counts/nextPickup on error as well
        setState(() {
          _requestCounts = {'total': 0, 'pending': 0, 'in_progress': 0, 'collected': 0};
          _nextPickup = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load dashboard data: ${e.toString()}')),
        );
      }
    });
  }

  // Renamed and modified to not call setState directly
  void _calculateRequestCountsInternal(List<Map<String, dynamic>> requests) {
    int total = requests.length;
    int pending = requests.where((r) => r['status'] == 'Pending').length;
    int inProgress = requests.where((r) => r['status'] == 'In Progress').length;
    int collected = requests.where((r) => r['status'] == 'Collected').length;

    // Update the local map directly, setState is called by the caller (_fetchLandlordData)
    _requestCounts = {
      'total': total,
      'pending': pending,
      'in_progress': inProgress,
      'collected': collected,
    };
  }

  // Renamed and modified to not call setState directly
  void _findNextPickupInternal(List<Map<String, dynamic>> requests) {
    final activeRequests = requests.where((r) => r['status'] == 'Pending' || r['status'] == 'In Progress').toList();

    if (activeRequests.isEmpty) {
      _nextPickup = null;
      return;
    }

    activeRequests.sort((a, b) {
      final dateA = DateTime.parse(a['date']);
      final dateB = DateTime.parse(b['date']);
      return dateA.compareTo(dateB);
    });

    final now = DateTime.now();
    Map<String, dynamic>? foundPickup;
    for (var request in activeRequests) {
      final pickupDate = DateTime.parse(request['date']);
      // Check for upcoming or today's date (at the start of the day)
      final startOfToday = DateTime(now.year, now.month, now.day);
      if (pickupDate.isAfter(startOfToday) || pickupDate.isAtSameMomentAs(startOfToday)) {
        foundPickup = request;
        break; // Found the next upcoming, so break
      }
    }
    // If no future/today, pick the first one (might be past due but still active)
    _nextPickup = foundPickup ?? (activeRequests.isNotEmpty ? activeRequests.first : null);
  }

  Future<void> _logout() async {
    print('LandlordHomeScreen: Initiating logout...'); // Added log
    await AuthService.clearUserSession();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen(role: 'landlord')),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('LandlordHomeScreen: build called.'); // Added log
    return Scaffold(
      appBar: AppBar(
        title: const Text('Landlord Dashboard'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(widget.userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              accountEmail: Text(widget.userEmail),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
                  style: TextStyle(fontSize: 40.0, color: Theme.of(context).primaryColor),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.green[700],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                _fetchLandlordData(); // Refresh home data explicitly
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle),
              title: const Text('Submit New Request'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Push and listen for the result when SubmitRequestScreen is popped
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SubmitRequestScreen()),
                ).then((result) {
                  // This callback is executed when the pushed route (SubmitRequestScreen) is popped
                  if (result == true) { // If SubmitRequestScreen popped with 'true' (success)
                    print('LandlordHomeScreen: Returned from SubmitRequestScreen with success, refreshing data...'); // Added log
                    _fetchLandlordData(); // Re-fetch data to update the dashboard
                  } else {
                    print('LandlordHomeScreen: Returned from SubmitRequestScreen without success, no refresh.'); // Added log
                  }
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Request History'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RequestHistoryScreen()),
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
          _fetchLandlordData(); // This will set _currentRequestsFuture and trigger a new fetch
          await _currentRequestsFuture; // Ensure the Future completes before RefreshIndicator finishes
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
                      const Icon(Icons.waving_hand, size: 40, color: Colors.green),
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
                            "Manage your waste pickups efficiently.",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Next Pickup Info
              const Text("Next Scheduled Pickup", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              // Use the _currentRequestsFuture to show loading/error states for the whole dashboard data
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _currentRequestsFuture, // Use the state variable future
                builder: (context, snapshot) {
                  // Only show indicator/error if the main data fetch is not done
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error loading requests: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {

                    return const Center(child: Text("You have no pickup requests yet."));
                  } else {
                    return Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _nextPickup == null
                            ? const Center(child: Text("No upcoming pickups scheduled."))
                            : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Location: ${_nextPickup!['location']}", style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 5),
                            Text("Description: ${_nextPickup!['description']}", style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 5),
                            Text("Date: ${DateTime.parse(_nextPickup!['date']).toLocal().toShortDate()}", style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 5),
                            Text("Status: ${_nextPickup!['status']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            if (_nextPickup!['collector'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Text(
                                  _nextPickup!['collector'] is Map && (_nextPickup!['collector'] as Map<String, dynamic>).containsKey('name')
                                      ? "Assigned Collector: ${(_nextPickup!['collector'] as Map<String, dynamic>)['name']}"
                                      : "Assigned Collector ID: ${(_nextPickup!['collector']).toString()}",
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),

              // Request Counts (These use the _requestCounts state variable, updated by _fetchLandlordData)
              const Text("Request Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildCountCard("Total", _requestCounts['total']!, Icons.list, Colors.blue),
                  _buildCountCard("Pending", _requestCounts['pending']!, Icons.hourglass_empty, Colors.orange),
                  _buildCountCard("In Progress", _requestCounts['in_progress']!, Icons.check_circle_outline, Colors.lightGreen),
                  _buildCountCard("Collected", _requestCounts['collected']!, Icons.done_all, Colors.green),
                ],
              ),
              const SizedBox(height: 20),

              // Quick Actions Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SubmitRequestScreen()),
                    ).then((result) { // <-- ADDED THIS .then() BLOCK
                      if (result == true) { // Check if the result from pop was true (indicating success)
                        print('LandlordHomeScreen: Returned from SubmitRequestScreen with success, refreshing data...');
                        _fetchLandlordData(); // Re-fetch data to update the dashboard
                      } else {
                        print('LandlordHomeScreen: Returned from SubmitRequestScreen without success, no refresh needed or operation cancelled.');
                      }
                    });
                  },
                  icon: const Icon(Icons.add_circle),
                  label: const Text("Submit New Pickup Request"),
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
                      MaterialPageRoute(builder: (context) => const RequestHistoryScreen()),
                    );
                  },
                  icon: const Icon(Icons.history),
                  label: const Text("View All My Requests"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
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

// Extension to format DateTime for display
extension DateTimeExtension on DateTime {
  String toShortDate() {
    // Formats date as DD/MM/YY
    return DateFormat('dd/MM/yy').format(this);
  }
}