import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../../../services/api_service.dart';

class AvailableRequestsScreen extends StatefulWidget {
  const AvailableRequestsScreen({super.key});

  @override
  State<AvailableRequestsScreen> createState() => _AvailableRequestsScreenState();
}

class _AvailableRequestsScreenState extends State<AvailableRequestsScreen> {
  // Use a Future<List<dynamic>> to hold the data from the API
  late Future<List<dynamic>> _availableRequests;

  @override
  void initState() {
    super.initState();
    _fetchAvailableRequests(); // Initial fetch when the screen loads
  }

  // Method to fetch requests from the API
  Future<void> _fetchAvailableRequests() async {
    setState(() {
      _availableRequests = ApiService.getAvailableRequests();
    });
  }

  // Method to handle accepting a request
  Future<void> _acceptRequest(String requestId) async {
    try {
      final success = await ApiService.acceptRequest(requestId);
      if (success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request accepted!')),
          );
        }
        // Refresh the list after a successful acceptance
        _fetchAvailableRequests();
        // You could also navigate to the Accepted Requests screen if desired
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AcceptedRequestsScreen()));
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to accept request. Please try again.')),
          );
        }
      }
    } catch (e) {
      print('Error accepting request: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Pickup Requests"),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _availableRequests, // Use the Future from the API call
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Available Requests Error: ${snapshot.error}'); // Log the actual error
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 50),
                    const SizedBox(height: 10),
                    Text(
                      "Error fetching available requests: ${snapshot.error.toString()}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _fetchAvailableRequests, // Retry button
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, color: Colors.blueGrey, size: 50),
                  const SizedBox(height: 10),
                  const Text("No available requests at the moment.", textAlign: TextAlign.center,),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: _fetchAvailableRequests, // Refresh button
                      child: const Text("Refresh")
                  )
                ],
              ),
            );
          }

          final requests = snapshot.data!;
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final String requestId = request['_id'] ?? '';
              final String landlordName = request['landlord'] != null
                  ? (request['landlord']['name'] ?? 'N/A')
                  : 'N/A';
              final String description = request['description'] ?? 'No description';
              final String location = request['location'] ?? 'N/A';
              // Assuming 'date' is the pickup date, format it
              final String pickupDate = request['date'] != null
                  ? DateFormat.yMMMd().format(DateTime.parse(request['date']))
                  : 'N/A';
              final String status = request['status'] ?? 'N/A'; // For display, optional

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Landlord: $landlordName",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: status == 'Pending' ? Colors.orange.shade100 : Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: status == 'Pending' ? Colors.orange.shade800 : Colors.blue.shade800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("Description: $description", style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text("Location: $location", style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text("Pickup Date: $pickupDate", style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => _acceptRequest(requestId),
                          icon: const Icon(Icons.check_circle_outline, size: 20),
                          label: const Text("Accept", style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}