import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../services/api_service.dart';

class AvailableRequestsScreen extends StatefulWidget {
  const AvailableRequestsScreen({Key? key}) : super(key: key);

  @override
  State<AvailableRequestsScreen> createState() =>
      _AvailableRequestsScreenState();
}

class _AvailableRequestsScreenState extends State<AvailableRequestsScreen> {
  final _storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final token = await _storage.read(key: "token");
    if (token != null) {
      try {
        final data = await ApiService.getPendingRequests(token);
        setState(() {
          _requests = data;
          _loading = false;
        });
      } catch (e) {
        print(e);
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _acceptRequest(String id) async {
    final token = await _storage.read(key: "token");
    if (token != null) {
      final success = await ApiService.acceptRequest(id, token);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Request accepted!")),
        );
        _loadRequests(); // Refresh
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Available Requests")),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _requests.isEmpty
          ? Center(child: Text("No pickup requests available."))
          : ListView.builder(
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final req = _requests[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              leading: Icon(Icons.location_on, color: Colors.teal),
              title: Text(req["location"]),
              subtitle: Text(req["description"]),
              trailing: ElevatedButton(
                onPressed: () => _acceptRequest(req["_id"]),
                child: Text("Accept"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
