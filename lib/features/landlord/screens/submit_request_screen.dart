import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/api_service.dart';

class SubmitRequestScreen extends StatefulWidget { // Assuming this is the correct class name
  const SubmitRequestScreen({Key? key}) : super(key: key);

  @override
  State<SubmitRequestScreen> createState() => _SubmitRequestScreenState();
}

class _SubmitRequestScreenState extends State<SubmitRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDate;
  bool _loading = false;

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      setState(() => _loading = true);

      try {
        final success = await ApiService.submitPickupRequest(
          location: _locationController.text.trim(),
          description: _descController.text.trim(),
          pickupDate: DateFormat("yyyy-MM-dd").format(_selectedDate!),
        );

        print("SubmitRequestScreen: ApiService.submitPickupRequest returned: $success");

        if (context.mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Pickup request submitted successfully."),
            ));
            _locationController.clear();
            _descController.clear();
            setState(() => _selectedDate = null);

            // --- IMPORTANT: POP THE SCREEN OFF THE NAVIGATION STACK ---
            // Pass 'true' as a result to indicate success to the previous screen (LandlordHomeScreen)
            Navigator.pop(context, true); // This will return to LandlordHomeScreen

          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Failed to submit request: API service returned false."),
            ));
            // If API returns false, you might choose to pop with false, or stay on screen
            // Navigator.pop(context, false); // Example: Pop with 'false' on non-successful API response
          }
        }
      } catch (e) {
        print("Submit request error caught in SubmitRequestScreen: $e");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to submit request: ${e.toString()}")),
          );
          // If an error occurred, you might choose to pop with false, or stay on screen
          // Navigator.pop(context, false); // Example: Pop with 'false' on error
        }
      } finally {
        setState(() => _loading = false);
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete all fields (location, description, and date)')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // No changes here from your snippet
    return Scaffold(
      appBar: AppBar(title: const Text("Submit Pickup Request")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: "Pickup Location"),
                validator: (value) =>
                value!.isEmpty ? "Enter location" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration:
                const InputDecoration(labelText: "Short Description"),
                maxLines: 3,
                validator: (value) =>
                value!.isEmpty ? "Enter description" : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_selectedDate == null
                    ? "Select Pickup Date"
                    : DateFormat("yyyy-MM-dd").format(_selectedDate!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text("Submit Request"),
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