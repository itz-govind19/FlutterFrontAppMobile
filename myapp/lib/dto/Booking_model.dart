import 'dart:ffi';

class CreateBookingDTO {
  DateTime expectedDate;
  String farmerName;
  String farmerPhone;
  int serviceId;
  int vehicleId;
  double acres;
  double guntas;
  int hours;
  int minutes;
  double kilometers;
  double meters;


  CreateBookingDTO({
    required this.expectedDate,
    required this.farmerName,
    required this.farmerPhone,
    required this.serviceId,
    required this.vehicleId,
    required this.acres,
    required this.guntas,
    required this.hours,
    required this.minutes,
    required this.kilometers,
    required this.meters,
  });

  factory CreateBookingDTO.fromJson(Map<String, dynamic> json) {
    return CreateBookingDTO(
      expectedDate: DateTime.parse(json['expectedDate']),
      farmerName: json['farmerName'],
      farmerPhone: json['farmerPhone'],
      serviceId: json['serviceId'],
      vehicleId: json['vehicleId'],
      acres: json['acres'].toDouble(),
      guntas: json['guntas'].toDouble(),
      hours: json['hours'],
      minutes: json['minutes'],
      kilometers: json['kilometers'],
      meters: json['meters'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expectedDate': expectedDate.toIso8601String(),
      'farmerName': farmerName,
      'farmerPhone': farmerPhone,
      'serviceId': serviceId,
      'vehicleId': vehicleId,
      'acres': acres,
      'guntas': guntas,
      'hours': hours,
      'minutes': minutes,
      'kilometers': kilometers,
      'meters': meters,
    };
  }
}

class BookingDTO {
  final int? bookingId;
  final DateTime? expectedDate;
  final String? farmerName;
  final String? farmerPhone;
  final String? status;
  final int? serviceId;
  final int? vehicleId;
  final double? acres;
  final double? guntas;
  final int? hours;
  final int? minutes;
  final double? kilometers;
  final double? meters;
  final String referenceId;
  final double totalAmount;

  BookingDTO({
    this.bookingId,
    this.expectedDate,
    this.farmerName,
    this.farmerPhone,
    this.status,
    this.serviceId,
    this.vehicleId,
    this.acres,
    this.guntas,
    this.hours,
    this.minutes,
    this.kilometers,
    this.meters,
    required this.referenceId,
    required this.totalAmount,
  });

  factory BookingDTO.fromJson(Map<String, dynamic> json) => BookingDTO(
    bookingId: json['bookingId'] as int?,
    expectedDate: json['expectedDate'] != null
        ? DateTime.parse(json['expectedDate'])
        : null,
    farmerName: json['farmerName'] as String?,
    farmerPhone: json['farmerPhone'] as String?,
    status: json['status'] as String?,
    serviceId: json['serviceId'] as int?,
    vehicleId: json['vehicleId'] as int?,
    acres: (json['acres'] != null) ? (json['acres'] as num).toDouble() : null,
    guntas: (json['guntas'] != null) ? (json['guntas'] as num).toDouble() : null,
    hours: json['hours'] as int?,
    minutes: json['minutes'] as int?,
    kilometers: (json['kilometers'] != null) ? (json['kilometers'] as num).toDouble() : null,
    meters: (json['meters'] != null) ? (json['meters'] as num).toDouble() : null,
    referenceId: json['referenceId'] as String,
    totalAmount: (json['totalAmount'] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'bookingId': bookingId,
    'expectedDate': expectedDate?.toIso8601String(),
    'farmerName': farmerName,
    'farmerPhone': farmerPhone,
    'status': status,
    'serviceId': serviceId,
    'vehicleId': vehicleId,
    'acres': acres,
    'guntas': guntas,
    'hours': hours,
    'minutes': minutes,
    'kilometers': kilometers,
    'meters': meters,
    'referenceId': referenceId,
    'totalAmount': totalAmount,
  };
}
