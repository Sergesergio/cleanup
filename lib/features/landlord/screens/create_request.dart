import 'package:flutter/material.dart';
import 'package:cleanup/services/api_service.dart'; // Make sure this path is correct
import 'package:intl/intl.dart'; // Import for date formatting

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;

  // Added a boolean to manage loading state for the button
  bool _isLoading = false;

  Future<void> _submitRequest() async { // Made async
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields and select a date")),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      final String location = _locationController.text.trim();
      final String description = _descriptionController.text.trim();
      final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);


      // --- CALL THE API SERVICE HERE ---
      final bool success = await ApiService.submitPickupRequest(
        location: location,
        description: description,
        pickupDate: formattedDate,
      );

      if (context.mounted) {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Pickup request submitted successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          // Optionally clear fields or navigate back
          _locationController.clear();
          _descriptionController.clear();
          setState(() {
            _selectedDate = null;
          });
          print('CreateRequestScreen: Request submitted, popping back with true.');
          // Go back to the previous screen (e.g., LandlordHomeScreen)
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to submit pickup request. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
        print("Error submitting request from UI: $e"); // Log for debugging
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An error occurred: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.green[700], // Header background color
            colorScheme: ColorScheme.light(primary: Colors.green[700]!),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Pickup"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: "Pickup Location",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) =>
                value!.isEmpty ? "Location is required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Description (e.g. type of waste)",
                  alignLabelWithHint: true, // Aligns label to the top for multiline
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) =>
                value!.isEmpty ? "Description is required" : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_month, color: Colors.green), // Themed icon
                title: Text(
                  _selectedDate == null
                      ? "Select Pickup Date"
                      : "Pickup Date: ${DateFormat('EEE, MMM d, yyyy').format(_selectedDate!)}", // More user-friendly date format
                  style: TextStyle(color: _selectedDate == null ? Colors.grey : Colors.black),
                ),
                trailing: ElevatedButton(
                  onPressed: () => _pickDate(context), // Correct!
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white, // Text color for button
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Pick Date"),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitRequest, // Disable button while loading
                icon: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Icon(Icons.send),
                label: Text(_isLoading ? "Submitting..." : "Submit Request"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}