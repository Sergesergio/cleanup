import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../services/api_service.dart';
import 'package:intl/intl.dart';

class SubmitRequestScreen extends StatefulWidget {
  const SubmitRequestScreen({Key? key}) : super(key: key);

  @override
  State<SubmitRequestScreen> createState() => _SubmitRequestScreenState();
}

class _SubmitRequestScreenState extends State<SubmitRequestScreen> {
  final _storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDate;
  bool _loading = false;

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      setState(() => _loading = true);
      final token = await _storage.read(key: "token");

      final success = await ApiService.submitPickupRequest(
        token: token!,
        location: _locationController.text.trim(),
        description: _descController.text.trim(),
        pickupDate: DateFormat("yyyy-MM-dd").format(_selectedDate!),
      );

      setState(() => _loading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Pickup request submitted successfully."),
        ));
        _locationController.clear();
        _descController.clear();
        _selectedDate = null;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to submit request."),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Submit Pickup Request")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: "Pickup Location"),
                validator: (value) =>
                value!.isEmpty ? "Enter location" : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration:
                InputDecoration(labelText: "Short Description"),
                maxLines: 3,
                validator: (value) =>
                value!.isEmpty ? "Enter description" : null,
              ),
              SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_selectedDate == null
                    ? "Select Pickup Date"
                    : DateFormat("yyyy-MM-dd").format(_selectedDate!)),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 30)),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(Icons.send),
                label: Text("Submit Request"),
                onPressed: _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
