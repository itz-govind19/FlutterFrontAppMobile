import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const _tokenKey = 'auth_token';

  // Save the token to SharedPreferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_tokenKey, token);
  }

  // Retrieve the token from SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Clear the token from SharedPreferences
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_tokenKey);
  }
}