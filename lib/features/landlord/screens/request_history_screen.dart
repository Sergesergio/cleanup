import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class RequestHistoryScreen extends StatefulWidget {
  const RequestHistoryScreen({Key? key}) : super(key: key);

  @override
  State<RequestHistoryScreen> createState() => _RequestHistoryScreenState();
}

class _RequestHistoryScreenState extends State<RequestHistoryScreen> {
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
      final data = await ApiService.getMyRequests(); // No token passed
      setState(() {
        _requests = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching requests history: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load request history: ${e.toString()}')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Pickup Requests"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, color: Colors.blueGrey, size: 50),
            const SizedBox(height: 10),
            const Text("No requests yet.", textAlign: TextAlign.center,),
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
          final String location = request["location"] ?? "Unknown location";
          final String description = request["description"] ?? "No description";
          final String pickupDate = request["date"] != null
              ? (request["date"] as String).substring(0, 10)
              : "N/A"; // Assuming 'date' not 'pickupDate' based on other files

          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              leading: const Icon(Icons.location_on, color: Colors.green),
              title: Text(location),
              subtitle: Text("$description\n📅 $pickupDate"),
              trailing: _buildStatusBadge(request["status"]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color badgeColor;
    switch (status) {
      case "In Progress":
        badgeColor = Colors.orange;
        break;
      case "Collected":
        badgeColor = Colors.green;
        break;
      default:
        badgeColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status ?? "Pending",
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}