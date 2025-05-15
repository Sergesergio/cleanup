import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../services/api_service.dart';

class ActiveRequestsScreen extends StatefulWidget {
  const ActiveRequestsScreen({Key? key}) : super(key: key);

  @override
  State<ActiveRequestsScreen> createState() => _ActiveRequestsScreenState();
}

class _ActiveRequestsScreenState extends State<ActiveRequestsScreen> {
  final _storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchActiveRequests();
  }

  Future<void> _fetchActiveRequests() async {
    final token = await _storage.read(key: "token");
    if (token != null) {
      try {
        final data = await ApiService.getMyActiveRequests(token);
        setState(() {
          _requests = data;
          _isLoading = false;
        });
      } catch (e) {
        print('Fetch error: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _markCollected(String requestId) async {
    final token = await _storage.read(key: "token");
    if (token != null) {
      try {
        await ApiService.markAsCollected(token, requestId);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Marked as collected")));
        _fetchActiveRequests(); // refresh list
      } catch (e) {
        print("Error marking collected: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update status")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Active Requests")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _requests.isEmpty
          ? Center(child: Text("No active requests"))
          : ListView.builder(
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];
          return Card(
            margin: EdgeInsets.all(12),
            child: ListTile(
              leading: Icon(Icons.route, color: Colors.orange),
              title: Text(request["location"] ?? ""),
              subtitle: Text(
                "${request["description"] ?? ""}\n📅 ${request["pickupDate"]?.substring(0, 10) ?? ""}",
              ),
              trailing: ElevatedButton.icon(
                icon: Icon(Icons.check_circle),
                label: Text("Collected"),
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
