import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class PendingRequestsScreen extends StatefulWidget {
  const PendingRequestsScreen({Key? key}) : super(key: key);

  @override
  State<PendingRequestsScreen> createState() => _PendingRequestsScreenState();
}

class _PendingRequestsScreenState extends State<PendingRequestsScreen> {
  // final _storage = const FlutterSecureStorage(); // Removed
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // ApiService now internally gets the token, no need to pass it
      final data = await ApiService.getPendingRequests();
      setState(() {
        _requests = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching pending requests: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load pending requests: ${e.toString()}')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptRequest(String requestId) async {
    try {
      // ApiService now internally gets the token, no need to pass it
      await ApiService.acceptRequest(requestId); // Removed token parameter
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Request accepted")));
      }
      _fetchRequests(); // refresh list
    } catch (e) {
      print("Accept error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to accept request: ${e.toString()}")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pending Requests")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, color: Colors.blueGrey, size: 50),
            const SizedBox(height: 10),
            const Text("No pending requests at the moment."),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchRequests,
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
          // Assuming 'date' not 'pickupDate' based on other files, or adjust based on your API response
          final String pickupDate = request["date"] != null
              ? (request["date"] as String).substring(0, 10)
              : "N/A";

          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              leading: const Icon(Icons.map, color: Colors.green),
              title: Text(location),
              subtitle: Text("$description\n📅 $pickupDate"),
              trailing: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text("Accept"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () => _acceptRequest(request["_id"]),
              ),
            ),
          );
        },
      ),
    );
  }
}