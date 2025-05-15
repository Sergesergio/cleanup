import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../services/api_service.dart';


class RequestPickupScreen extends StatefulWidget {
  const RequestPickupScreen({super.key});

  @override
  State<RequestPickupScreen> createState() => _RequestPickupScreenState();
}

class _RequestPickupScreenState extends State<RequestPickupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  DateTime? _selectedDate;
  bool _isSubmitting = false;

  void _pickDate() async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      setState(() => _isSubmitting = true);

      final token = await _storage.read(key: "token");
      if (token == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login required')),
          );
        }
        setState(() => _isSubmitting = false);
        return;
      }

      final success = await ApiService.submitPickupRequest(
        token: token,
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        pickupDate: _selectedDate!.toIso8601String(),
      );

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pickup request submitted!')),
          );
          _formKey.currentState?.reset();
          _locationController.clear();
          _descriptionController.clear();
          setState(() => _selectedDate = null);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Submission failed. Try again.')),
          );
        }
      }

      setState(() => _isSubmitting = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Garbage Pickup"),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Location Input
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Pickup Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter a location' : null,
              ),
              const SizedBox(height: 16),
              // Description Input
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Short Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter a description' : null,
              ),
              const SizedBox(height: 16),
              // Date Picker
              ListTile(
                title: Text(
                  _selectedDate == null
                      ? "Choose Pickup Date"
                      : "Pickup Date: ${DateFormat.yMMMd().format(_selectedDate!)}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),
              // Submit Button
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitForm,
                icon: const Icon(Icons.send),
                label: _isSubmitting
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text("Submit Request"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
