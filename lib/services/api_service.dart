import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cleanup/services/auth_service.dart'; //
import 'dart:io'; // Required for Platform checks
import 'package:flutter/foundation.dart' show kDebugMode; // Required for kDebugMode
import 'package:device_info_plus/device_info_plus.dart'; // Required for device_info_plus

class ApiService {
  static String _baseUrl = ""; // Now mutable

  static Future<void> initializeBaseUrl() async {
    if (_baseUrl.isNotEmpty) return; // Already initialized, prevent re-initialization

    if (kDebugMode) { // Logic applies only in debug mode
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.isPhysicalDevice) {
          // For physical Android device: Use your computer's actual local IP address
          // IMPORTANT: REPLACE 'YOUR_COMPUTER_LOCAL_IP' with the IP you found
          _baseUrl = "http://192.168.43.2:5000/api";
          print("ApiService: Base URL set for Physical Android Device: $_baseUrl");
        } else {
          // For Android emulator: Use the standard emulator IP
          _baseUrl = "http://10.0.2.2:5000/api";
          print("ApiService: Base URL set for Android Emulator: $_baseUrl");
        }
      }
      // You can add Platform.isIOS / iOS simulator/device checks here if needed later
      else {
        // Fallback for other platforms (e.g., iOS simulator, Web, Desktop)
        _baseUrl = "http://localhost:5000/api"; // Default, adjust as needed for other platforms
        print("ApiService: Base URL set for Other Platform/Fallback: $_baseUrl");
      }
    } else {
      // For release mode, use your actual deployed backend URL
      // IMPORTANT: Change this for your production environment!
      _baseUrl = "http://your-production-backend-url.com/api";
      print("ApiService: Base URL set for Release Mode: $_baseUrl");
    }
  }

  // This function now gets the token from AuthService
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await AuthService.getUserToken(); // <--- Get token from AuthService
    final Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    print('ApiService: Generated Auth Headers: $headers');
    return headers;
  }

  // User registration
  static Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    if (_baseUrl.isEmpty) await initializeBaseUrl();
    final url = Uri.parse("$_baseUrl/auth/signup");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "role": role.toLowerCase(),
        }),
      );
      print("ApiService: Register User Status: ${response.statusCode}");
      print("ApiService: Register User Body: ${response.body}");
      return response.statusCode == 201;
    } catch (e) {
      print('ApiService: Network or generic error during registration: $e');
      throw Exception('Failed to register. Please check your internet connection and try again. Error: $e');
    }
  }

  // User login
  static Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    if (_baseUrl.isEmpty) await initializeBaseUrl();
    final url = Uri.parse("$_baseUrl/auth/login");

    print("ApiService: Attempting to log in user: $email");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      print("ApiService: Login response status: ${response.statusCode}");
      print("ApiService: Login response body: ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        final String? token = body['token'];
        final Map<String, dynamic>? user = body['user'];

        if (token != null && user != null && user.containsKey('role') && user.containsKey('_id')) {
          print('ApiService: Login successful. Returning token, role, and ID.');
          return {
            'token': token,
            'role': user['role'],
            '_id': user['_id'],
            'name': user['name'], // Include name for convenience
            'email': user['email'], // Include email for convenience
            'message': body.containsKey('message') ? body['message'] : 'Login successful'
          };
        } else {
          print("ApiService: Error: Backend response for login missing 'token', 'user' object, 'user.role', or 'user._id'.");
          throw Exception("Login response incomplete. Please contact support.");
        }
      } else {
        String errorMessage = "Login failed. Status: ${response.statusCode}";
        try {
          final errorBody = json.decode(response.body);
          if (errorBody is Map && errorBody.containsKey('message')) {
            errorMessage = errorBody['message'] as String;
          }
        } catch (_) {
          errorMessage = "Login failed. Server responded with status: ${response.statusCode}";
        }
        print('ApiService: Error during login: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('ApiService: Network or generic error during login: $e');
      throw Exception('Failed to connect to the server. Please check your internet connection and try again. Error: $e');
    }
  }


  /// Submit a garbage pickup request (Landlord)
  static Future<bool> submitPickupRequest({
    required String location,
    required String description,
    required String pickupDate,
  }) async {
    // Ensure baseUrl is set before using it.
    // This check is important because initializeBaseUrl() might be called late
    // or _baseUrl might revert to an empty string.
    if (_baseUrl.isEmpty || _baseUrl.contains('127.0.0.1') || _baseUrl.contains('localhost')) {
      await initializeBaseUrl();
      // After calling, check again to be sure it's valid for device connection
      if (_baseUrl.isEmpty || _baseUrl.contains('127.0.0.1') || _baseUrl.contains('localhost')) {
        print('ApiService ERROR: Base URL is still not correctly set for device connection: $_baseUrl');
        throw Exception('Base URL not correctly configured for device. Check initializeBaseUrl().');
      }
    }

    final url = Uri.parse("$_baseUrl/requests");
    final headers = await _getAuthHeaders(); // Uses token from AuthService

    print('ApiService: Attempting POST request to URL: $url'); // <-- NEW PRINT
    print('ApiService: Request Headers: $headers'); // <-- NEW PRINT
    print('ApiService: Request Body (raw): ${jsonEncode({"location": location, "description": description, "date": pickupDate})}'); // <-- NEW PRINT

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          "location": location,
          "description": description,
          "date": pickupDate,
        }),
      );
      print("ApiService: Submit Pickup Request Status: ${response.statusCode}");
      print("ApiService: Submit Pickup Request Body: ${response.body}");
      return response.statusCode == 201;
    } catch (e) {
      print('ApiService: Network or generic error during submitPickupRequest: $e');
      // Re-throw with more context to see in UI if caught
      throw Exception('Failed to submit request. Network/Connectivity issue? Error: $e. Tried to reach: $url');
    }
  }
  /// Fetch requests submitted by the logged-in landlord
  static Future<List<Map<String, dynamic>>> getMyRequests() async {
    if (_baseUrl.isEmpty) await initializeBaseUrl();
    final url = Uri.parse("$_baseUrl/requests/my");
    final headers = await _getAuthHeaders(); // Uses token from AuthService

    try {
      final response = await http.get(url, headers: headers);
      print("ApiService: Get My Requests Status: ${response.statusCode}");
      print("ApiService: Get My Requests Body: ${response.body}");

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return [];
        return (jsonDecode(response.body) as List).map((item) => item as Map<String, dynamic>).toList();
      } else {
        String errorMessage = 'Failed to load your pickup requests. Status: ${response.statusCode}';
        try {
          final errorBody = json.decode(response.body);
          if (errorBody is Map && errorBody.containsKey('message')) {
            errorMessage += ' - ${errorBody['message']}';
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('ApiService: Network or generic error during getMyRequests: $e');
      throw Exception('Failed to load your requests. Error: $e');
    }
  }

  /// Fetch all pending requests (for collectors to view)
  static Future<List<Map<String, dynamic>>> getPendingRequests() async {
    if (_baseUrl.isEmpty) await initializeBaseUrl();
    final url = Uri.parse("$_baseUrl/requests?status=Pending");
    final headers = await _getAuthHeaders(); // Uses token from AuthService

    try {
      final response = await http.get(url, headers: headers);
      print("ApiService: Get Pending Requests Status: ${response.statusCode}");
      print("ApiService: Get Pending Requests Body: ${response.body}");

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return [];
        return (jsonDecode(response.body) as List).map((item) => item as Map<String, dynamic>).toList();
      } else {
        String errorMessage = 'Failed to load pending requests. Status: ${response.statusCode}';
        try {
          final errorBody = json.decode(response.body);
          if (errorBody is Map && errorBody.containsKey('message')) {
            errorMessage += ' - ${errorBody['message']}';
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('ApiService: Network or generic error during getPendingRequests: $e');
      throw Exception('Failed to load pending requests. Error: $e');
    }
  }

  /// Collector accepts a request
  static Future<bool> acceptRequest(String requestId) async {
    if (_baseUrl.isEmpty) await initializeBaseUrl();
    final url = Uri.parse("$_baseUrl/requests/$requestId/accept");
    final headers = await _getAuthHeaders(); // Uses token from AuthService

    try {
      final response = await http.put(url, headers: headers);
      print("ApiService: Accept Request Status: ${response.statusCode}");
      print("ApiService: Accept Request Body: ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      print('ApiService: Network or generic error during acceptRequest: $e');
      throw Exception('Failed to accept request. Error: $e');
    }
  }

  /// Get active (in-progress) requests claimed by the collector
  static Future<List<Map<String, dynamic>>> getMyActiveRequests() async {
    if (_baseUrl.isEmpty) await initializeBaseUrl();
    final url = Uri.parse("$_baseUrl/requests/in-progress");
    final headers = await _getAuthHeaders(); // Uses token from AuthService

    try {
      final response = await http.get(url, headers: headers);
      print("ApiService: Get My Active Requests Status: ${response.statusCode}");
      print("ApiService: Get My Active Requests Body: ${response.body}");

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return [];
        return (jsonDecode(response.body) as List).map((item) => item as Map<String, dynamic>).toList();
      } else {
        String errorMessage = 'Failed to load active requests. Status: ${response.statusCode}';
        try {
          final errorBody = json.decode(response.body);
          if (errorBody is Map && errorBody.containsKey('message')) {
            errorMessage += ' - ${errorBody['message']}';
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('ApiService: Network or generic error during getMyActiveRequests: $e');
      throw Exception('Failed to load active requests. Error: $e');
    }
  }

  /// Mark a request as collected (completed)
  static Future<bool> markAsCollected(String requestId) async {
    if (_baseUrl.isEmpty) await initializeBaseUrl();
    final url = Uri.parse("$_baseUrl/requests/$requestId/collected");
    final headers = await _getAuthHeaders(); // Uses token from AuthService

    try {
      final response = await http.put(url, headers: headers);
      print("ApiService: Mark As Collected Status: ${response.statusCode}");
      print("ApiService: Mark As Collected Body: ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      print('ApiService: Network or generic error during markAsCollected: $e');
      throw Exception('Failed to mark request as collected. Error: $e');
    }
  }

  /// Get requests that have been accepted (status = "accepted")
  static Future<List<Map<String, dynamic>>> getAcceptedRequests() async {
    if (_baseUrl.isEmpty) await initializeBaseUrl();
    final url = Uri.parse("$_baseUrl/requests/accepted");
    final headers = await _getAuthHeaders(); // Uses token from AuthService

    try {
      final response = await http.get(url, headers: headers);
      print("ApiService: Get Accepted Requests Status: ${response.statusCode}");
      print("ApiService: Get Accepted Requests Body: ${response.body}");

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return [];
        List data = jsonDecode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        String errorMessage = "Failed to load accepted requests. Status: ${response.statusCode}";
        try {
          final errorBody = json.decode(response.body);
          if (errorBody is Map && errorBody.containsKey('message')) {
            errorMessage += ' - ${errorBody['message']}';
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('ApiService: Network or generic error during getAcceptedRequests: $e');
      throw Exception('Failed to load accepted requests. Error: $e');
    }
  }

  /// Get user profile data
  static Future<Map<String, dynamic>> getUserProfile() async {
    if (_baseUrl.isEmpty) await initializeBaseUrl();
    final url = Uri.parse("$_baseUrl/auth/profile");
    final headers = await _getAuthHeaders(); // Uses token from AuthService

    try {
      final response = await http.get(url, headers: headers);
      print("ApiService: Get User Profile Status: ${response.statusCode}");
      print("ApiService: Get User Profile Body: ${response.body}");

      if (response.statusCode == 200) {
        if (response.body.isEmpty) throw Exception('User profile data is empty.');
        return Map<String, dynamic>.from(jsonDecode(response.body));
      } else {
        String errorMessage = 'Failed to load user profile. Status: ${response.statusCode}';
        try {
          final errorBody = json.decode(response.body);
          if (errorBody is Map && errorBody.containsKey('message')) {
            errorMessage += ' - ${errorBody['message']}';
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('ApiService: Network or generic error during getUserProfile: $e');
      throw Exception('Failed to load user profile. Error: $e');
    }
  }

  // get available requests for collectors (UPDATED)
  static Future<List<Map<String, dynamic>>> getAvailableRequests() async {
    if (_baseUrl.isEmpty) await initializeBaseUrl();
    final url = Uri.parse('$_baseUrl/requests/available');
    print('ApiService: Attempting to fetch available requests from: $url');

    try {
      final headers = await _getAuthHeaders(); // Uses token from AuthService
      final response = await http.get(url, headers: headers);

      print('ApiService: Response status for available requests: ${response.statusCode}');
      print('ApiService: Response body for available requests: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print('ApiService: Response body is empty for available requests. Returning empty list.');
          return [];
        }
        try {
          final List<dynamic> requests = json.decode(response.body);
          print('ApiService: Successfully decoded ${requests.length} available requests.');
          return requests.map((item) => item as Map<String, dynamic>).toList();
        } catch (e) {
          print('ApiService: JSON parsing error for available requests: $e');
          throw Exception('Failed to parse available requests data: $e');
        }
      } else {
        String errorMessage = 'Failed to load available requests. Status: ${response.statusCode}';
        try {
          final errorBody = json.decode(response.body);
          if (errorBody is Map && errorBody.containsKey('message')) {
            errorMessage += ' - ${errorBody['message']}';
          } else {
            errorMessage += ' - ${response.body}';
          }
        } catch (_) {
          errorMessage += ' - ${response.body}';
        }
        print('ApiService: Error response from backend: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('ApiService: Network or generic error during request: $e');
      throw Exception('Network or server connection error: $e');
    }
  }
}