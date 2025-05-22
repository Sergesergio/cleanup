import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = "http://10.0.2.2:5000/api";

  /// Submit a garbage pickup request (Landlord)
  static Future<bool> submitPickupRequest({
    required String token,
    required String location,
    required String description,
    required String pickupDate,
  }) async {
    final url = Uri.parse("$_baseUrl/requests");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "location": location,
        "description": description,
        "pickupDate": pickupDate,
      }),
    );

    return response.statusCode == 201;
  }

  /// Fetch requests submitted by the logged-in landlord
  static Future<List<Map<String, dynamic>>> getMyRequests(String token) async {
    final url = Uri.parse("$_baseUrl/my-requests");

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load your pickup requests');
    }
  }

  /// Fetch all pending requests (for collectors to view)
  static Future<List<Map<String, dynamic>>> getPendingRequests(String token) async {
    final url = Uri.parse("$_baseUrl/requests");

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load pending requests');
    }
  }

  /// Collector accepts a request
  static Future<bool> acceptRequest(String requestId, String token) async {
    final url = Uri.parse("$_baseUrl/requests/$requestId/accept");

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }

  /// Get active (in-progress) requests claimed by the collector
  static Future<List<Map<String, dynamic>>> getMyActiveRequests(String token) async {
    final url = Uri.parse("$_baseUrl/requests/in-progress");

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load active requests');
    }
  }

  /// Mark a request as collected (completed)
  static Future<bool> markAsCollected(String token, String requestId) async {
    final url = Uri.parse("$_baseUrl/requests/$requestId/collected");

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }


  /// Get requests that have been accepted (status = "accepted")
  static Future<List<Map<String, dynamic>>> getAcceptedRequests(String token) async {
    final url = Uri.parse("$_baseUrl/requests");

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data
          .where((r) => r['status'] == 'accepted')
          .cast<Map<String, dynamic>>()
          .toList();
    } else {
      throw Exception("Failed to load accepted requests");
    }
  }
  //user registration
  static Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse("$_baseUrl/auth/register");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "role": role.toLowerCase(), // either "landlord" or "collector"
      }),
    );

    return response.statusCode == 201;
  }

//user login
  static Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$_baseUrl/auth/login");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return {
        'token': body['token'],
        'role': body['role'],
      };
    } else {
      return null;
    }
  }


}
