import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/constants.dart';
import 'package:myapp/dto/services_model.dart';

class FarmerService {
  static final String? baseUrl =
      dotenv.env['BASE_URL'] ?? 'http://localhost:8080';
  static final String serviceEndpoint = "$baseUrl$BASE_URL_SERVICES";

  /// Fetch all services
  static Future<List<Service>> fetchAllServices() async {
    final response = await http.get(Uri.parse(serviceEndpoint));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Service.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load services');
    }
  }

  /// Create a new service
  static Future<Service?> createService(Service service) async {
    final response = await http.post(
      Uri.parse(serviceEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(service.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Service.fromJson(jsonDecode(response.body));
    }else if(response.statusCode==500){
      response.body;
    }
    else {
      return null;
    }
  }

  /// Update an existing service
  static Future<bool> updateService(Service service) async {
    final response = await http.put(
      Uri.parse('$serviceEndpoint/${service.serviceId}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(service.toJson()),
    );

    return response.statusCode == 200;
  }

  /// Delete a service
  static Future<bool> deleteService(int id) async {
    final response = await http.delete(Uri.parse('$serviceEndpoint/$id'));
    return response.statusCode == 200;
  }
}
