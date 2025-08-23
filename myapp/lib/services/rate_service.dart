import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/constants.dart';
import 'package:myapp/dto/rate_model.dart';

class RateService {
  static final String? baseUrl =
      dotenv.env['BASE_URL'] ?? 'http://localhost:8080';
  static final String serviceEndpoint = "$baseUrl$BASE_URL_RATE";

  /// Fetch all services
  static Future<List<RateDTO>> fetchAllRates() async {
    final response = await http.get(Uri.parse(serviceEndpoint));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => RateDTO.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load services');
    }
  }

  /// Create a new service
  static Future<RateDTO?> createService(CreateRateDTO service) async {
    final response = await http.post(
      Uri.parse(serviceEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(service.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return RateDTO.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  /// Update an existing service
  static Future<bool> updateService(CreateRateDTO service, int? rateId) async {
    final response = await http.put(
      Uri.parse('$serviceEndpoint/${rateId}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(service.toJson()),
    );

    return response.statusCode == 200;
  }

  /// Delete a service
  static Future<bool> deleteService(int? id) async {
    final response = await http.delete(Uri.parse('$serviceEndpoint/$id'));
    return response.statusCode == 200;
  }

  /// Fetch rate by serviceId
  static Future<List<RateDTO>> fetchRateByServiceId(int serviceId) async {
    final response =
    await http.get(Uri.parse("$serviceEndpoint/service/$serviceId"));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => RateDTO.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load services');
    }
  }
}
