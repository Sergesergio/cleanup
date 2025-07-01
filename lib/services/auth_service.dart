import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Keys for SharedPreferences
  static const String _userTokenKey = 'userToken';
  static const String _userIdKey = 'userId';
  static const String _userRoleKey = 'userRole';

  // Save user session data
  static Future<void> saveUserSession({
    required String userToken,
    required String userId,
    required String userRole,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userTokenKey, userToken);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userRoleKey, userRole);
    print('AuthService: User session saved to SharedPreferences.');
    print('AuthService: Token: $userToken');
    print('AuthService: User ID: $userId');
    print('AuthService: User Role: $userRole');
  }

  // Retrieve the user token
  static Future<String?> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_userTokenKey);
    print('AuthService: Retrieved token from SharedPreferences: ${token != null ? "found" : "not found"}');
    return token;
  }

  // Retrieve the logged-in user's ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Retrieve the logged-in user's role
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  // Clear user session data (logout)
  static Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userRoleKey);
    print('AuthService: User session cleared from SharedPreferences.');
  }

  // Check if a user is currently logged in (based on token presence)
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userTokenKey) && prefs.getString(_userTokenKey) != null;
  }
}