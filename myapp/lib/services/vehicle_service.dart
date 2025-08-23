import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/constants.dart';
import 'package:myapp/model/vehicle_model.dart';
import 'package:myapp/security/token_manager.dart';

class VehicleService {
  static final String? baseUrl =
      dotenv.env['BASE_URL'] ?? 'http://localhost:8080';
  static final String vehicleEndpoint = "$baseUrl$BASE_URL_VEHICLE";

  // Create vehicle
  static Future<Vehicle?> createVehicle(Vehicle vehicle) async {
    final url = Uri.parse('$vehicleEndpoint/createVehicle');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'vehicleType': vehicle.vehicleType,
        'vehicleNumber': vehicle.vehicleNumber,
        'model': vehicle.model,
        'userName': vehicle.userName,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Vehicle.fromJson(data);
    } else {
      print('Failed to create vehicle: ${response.body}');
      return null;
    }
  }

  // Fetch all vehicles
  static Future<List<Vehicle>> fetchAllVehicles() async {
    final url = Uri.parse('$vehicleEndpoint/getAllVehicles');
    String? token = await TokenManager.getToken();
    final response = await http.get(url, headers: {'accept': '*/*',
        'Authorization': ?token,
        'Content-Type': 'application/json'
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Vehicle.fromJson(json)).toList();
    } else {
      print('Failed to fetch vehicles: ${response.body}');
      return [];
    }
  }

  // Update vehicle
  static Future<bool> updateVehicle(Vehicle vehicle) async {
    if (vehicle.vehicleId == null) {
      print("Cannot update vehicle without ID");
      return false;
    }

    final url = Uri.parse('$vehicleEndpoint/${vehicle.vehicleId}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(vehicle.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to update vehicle: ${response.body}');
      return false;
    }
  }

  // Delete vehicle
  static Future<bool> deleteVehicle(int? vehicleId) async {
    final url = Uri.parse('$vehicleEndpoint/$vehicleId');
    final response = await http.delete(url, headers: {'accept': '*/*'});

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      print('Failed to delete vehicle: ${response.body}');
      return false;
    }
  }
}
