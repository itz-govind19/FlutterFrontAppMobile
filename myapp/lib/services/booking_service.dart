import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/constants.dart';
import 'package:myapp/dto/Booking_model.dart';
import 'package:myapp/dto/rate_model.dart';

class BookingService {
  static final String? baseUrl =
      dotenv.env['BASE_URL'] ?? 'http://localhost:8080';
  static final String bookingEndpoint = "$baseUrl$BASE_URL_BOOKING";

  /// Fetch all bookings
  static Future<List<RateDTO>> fetchAllBookings() async {
    final response = await http.get(Uri.parse(bookingEndpoint));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => RateDTO.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load bookings');
    }
  }

  /// Create a new bookings
  static Future<BookingDTO?> createBooking(CreateBookingDTO bookings) async {
    final response = await http.post(
      Uri.parse(bookingEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bookings.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return BookingDTO.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  /// Update an existing bookings
  static Future<bool> updateBooking(CreateRateDTO service, int? rateId) async {
    final response = await http.put(
      Uri.parse('$bookingEndpoint/${rateId}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(service.toJson()),
    );

    return response.statusCode == 200;
  }

  /// Delete a booking
  static Future<bool> deleteBooking(int? id) async {
    final response = await http.delete(Uri.parse('$bookingEndpoint/$id'));
    return response.statusCode == 200;
  }
}
