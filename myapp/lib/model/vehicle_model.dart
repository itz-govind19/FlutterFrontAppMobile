class Vehicle {
  final int? vehicleId;
  final String vehicleType;
  final String vehicleNumber;
  final String model;
  final String userName;

  Vehicle({
    required this.vehicleId,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.model,
    required this.userName,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vehicleId: json['vehicleId'],
      vehicleType: json['vehicleType'],
      vehicleNumber: json['vehicleNumber'],
      model: json['model'],
      userName: json['userName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'model': model,
      'userName': userName,
    };
  }
}
