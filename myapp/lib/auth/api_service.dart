import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/constants.dart';
import 'package:myapp/dto/sign_up_model.dart';

class ApiService {
  static final String? baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080';
  static final String authEndpoint = "$baseUrl$BASE_URL_AUTH";

  static Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse("$authEndpoint/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      // Success: return parsed JSON
      return jsonDecode(response.body);
    } else if (response.statusCode == 404 || response.statusCode == 401) {
      // Handle specific error responses like 404 or 401
      return jsonDecode(response.body);
    } else {
      // Fallback for other status codes
      throw Exception("Failed to login: ${response.statusCode} ${response.body}");
    }
  }

  static Future<Map<String, dynamic>> register(SignUpRequest request) async {
    final url = Uri.parse("$authEndpoint/register");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to register: ${response.statusCode} ${response.body}");
    }
  }
}
