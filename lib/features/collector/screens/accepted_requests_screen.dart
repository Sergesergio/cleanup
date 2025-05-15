import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../services/api_service.dart';

class AcceptedRequestsScreen extends StatefulWidget {
  const AcceptedRequestsScreen({Key? key}) : super(key: key);

  @override
  State<AcceptedRequestsScreen> createState() => _AcceptedRequestsScreenState();
}

class _AcceptedRequestsScreenState extends State<AcceptedRequestsScreen> {
  final _storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> _acceptedRequests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAcceptedRequests();
  }

  Future<void> _loadAcceptedRequests() async {
    final token = await _storage.read(key: "token");
    if (token != null) {
      try {
        final data = await ApiService.getAcceptedRequests(token);
        setState(() {
          _acceptedRequests = data;
          _loading = false;
        });
      } catch (e) {
        print(e);
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _markCollected(String id) async {
    final token = await _storage.read(key: "token");
    if (token != null) {
      final success = await ApiService.markAsCollected(id, token);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Marked as collected"),
        ));
        _loadAcceptedRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to update"),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Accepted Requests")),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _acceptedRequests.isEmpty
          ? Center(child: Text("No accepted requests."))
          : ListView.builder(
        itemCount: _acceptedRequests.length,
        itemBuilder: (context, index) {
          final req = _acceptedRequests[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(req["location"]),
              subtitle: Text("Date: ${req["pickupDate"]}"),
              trailing: ElevatedButton.icon(
                icon: Icon(Icons.check),
                label: Text("Collected"),
                onPressed: () => _markCollected(req["_id"]),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
