import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../services/api_service.dart';

class RequestHistoryScreen extends StatefulWidget {
  const RequestHistoryScreen({Key? key}) : super(key: key);

  @override
  State<RequestHistoryScreen> createState() => _RequestHistoryScreenState();
}

class _RequestHistoryScreenState extends State<RequestHistoryScreen> {
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
        final data = await ApiService.getMyRequests(token);
        setState(() {
          _requests = data;
          _isLoading = false;
        });
      } catch (e) {
        print('Error fetching requests: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Pickup Requests"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _requests.isEmpty
          ? Center(child: Text("No requests yet"))
          : ListView.builder(
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];
          return Card(
            margin: EdgeInsets.all(12),
            child: ListTile(
              leading: Icon(Icons.location_on, color: Colors.green),
              title: Text(request["location"] ?? "Unknown location"),
              subtitle: Text(
                "${request["description"] ?? ""}\n📅 ${request["pickupDate"]?.substring(0, 10) ?? ""}",
              ),
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
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status ?? "Pending",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
