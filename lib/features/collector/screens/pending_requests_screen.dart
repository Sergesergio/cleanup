import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../services/api_service.dart';

class PendingRequestsScreen extends StatefulWidget {
  const PendingRequestsScreen({Key? key}) : super(key: key);

  @override
  State<PendingRequestsScreen> createState() => _PendingRequestsScreenState();
}

class _PendingRequestsScreenState extends State<PendingRequestsScreen> {
  final _storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    final token = await _storage.read(key: "token");
    if (token != null) {
      try {
        final data = await ApiService.getPendingRequests(token);
        setState(() {
          _requests = data;
          _isLoading = false;
        });
      } catch (e) {
        print('Error fetching pending requests: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _acceptRequest(String requestId) async {
    final token = await _storage.read(key: "token");
    if (token != null) {
      try {
        await ApiService.acceptRequest(token, requestId);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Request accepted")));
        _fetchRequests(); // refresh
      } catch (e) {
        print("Accept error: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to accept request")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pending Requests")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _requests.isEmpty
          ? Center(child: Text("No pending requests"))
          : ListView.builder(
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];
          return Card(
            margin: EdgeInsets.all(12),
            child: ListTile(
              leading: Icon(Icons.map, color: Colors.green),
              title: Text(request["location"] ?? ""),
              subtitle: Text(
                "${request["description"] ?? ""}\n📅 ${request["pickupDate"]?.substring(0, 10) ?? ""}",
              ),
              trailing: ElevatedButton.icon(
                icon: Icon(Icons.check),
                label: Text("Accept"),
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
