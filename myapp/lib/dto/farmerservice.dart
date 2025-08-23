class Service {
  final int? serviceId;
  final String serviceName;
  final String description;
  final int vehicleId;
  final String? vehicleName;

  Service({
    this.serviceId,
    this.vehicleName,
    required this.serviceName,
    required this.description,
    required this.vehicleId,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      serviceId: json['serviceId'],
      serviceName: json['serviceName'],
      description: json['description'],
      vehicleId: json['vehicleId'],
      vehicleName: json['vehicleName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'description': description,
      'vehicleId': vehicleId,
    };
  }
}
