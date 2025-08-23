import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/constants.dart';

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
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to login: ${response.body}");
    }
  }
}
