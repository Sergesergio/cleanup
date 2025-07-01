import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
// import '../../../services/auth_service.dart'; // If you were using it directly, but not required if ApiService handles token

class ActiveRequestsScreen extends StatefulWidget {
  const ActiveRequestsScreen({Key? key}) : super(key: key);

  @override
  State<ActiveRequestsScreen> createState() => _ActiveRequestsScreenState();
}

class _ActiveRequestsScreenState extends State<ActiveRequestsScreen> {
  // final _storage = const FlutterSecureStorage(); // Removed: AuthService now manages token
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchActiveRequests();
  }

  Future<void> _fetchActiveRequests() async {
    setState(() {
      _isLoading = true; // Show loading when fetching
    });
    try {
      // ApiService now internally gets the token, no need to pass it
      final data = await ApiService.getMyActiveRequests();
      setState(() {
        _requests = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Fetch active requests error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load active requests: ${e.toString()}')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markCollected(String requestId) async {
    try {
      // ApiService now internally gets the token, no need to pass it
      await ApiService.markAsCollected(requestId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Request marked as collected")));
      }
      _fetchActiveRequests(); // refresh list after marking as collected
    } catch (e) {
      print("Error marking collected: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to update status: ${e.toString()}")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Active Requests")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, color: Colors.blueGrey, size: 50),
            const SizedBox(height: 10),
            const Text("No active requests at the moment."),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchActiveRequests,
              child: const Text("Refresh"),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];
          // Provide default values in case keys are missing
          final String location = request["location"] ?? "N/A";
          final String description = request["description"] ?? "No description";
          final String pickupDate = request["date"] != null
              ? (request["date"] as String).substring(0, 10)
              : "N/A"; // Assuming 'date' not 'pickupDate' based on other files

          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              leading: const Icon(Icons.route, color: Colors.orange),
              title: Text(location),
              subtitle: Text("$description\n📅 $pickupDate"),
              trailing: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text("Collected"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                ),
                onPressed: () => _markCollected(request["_id"]),
              ),
            ),
          );
        },
      ),
    );
  }
}