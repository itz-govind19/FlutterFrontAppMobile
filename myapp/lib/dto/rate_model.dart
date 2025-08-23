class CreateRateDTO {
  String unitType;
  String subUnitType;
  double rateAmount; // Dart's equivalent of BigDecimal is double
  int serviceId;

  CreateRateDTO({
    required this.unitType,
    required this.subUnitType,
    required this.rateAmount,
    required this.serviceId,
  });

  // You can add a factory method to convert from JSON if needed
  factory CreateRateDTO.fromJson(Map<String, dynamic> json) {
    return CreateRateDTO(
      unitType: json['unitType'],
      subUnitType: json['subUnitType'],
      rateAmount: json['rateAmount'].toDouble(),
      serviceId: json['serviceId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unitType': unitType,
      'subUnitType': subUnitType,
      'rateAmount': rateAmount,
      'serviceId': serviceId,
    };
  }
}

class RateDTO {
  final int? rateId;
  final String unitType;
  final String subUnit;
  final double rateAmount;
  final int serviceId;
  final String? serviceName;

  RateDTO({
    this.rateId,
    required this.unitType,
    required this.subUnit,
    required this.rateAmount,
    required this.serviceId,
    this.serviceName,
  });

  // Factory constructor for creating a new RateDTO instance from JSON
  factory RateDTO.fromJson(Map<String, dynamic> json) {
    return RateDTO(
      rateId: json['rateId'],
      unitType: json['unitType'],
      subUnit: json['subUnit'],
      rateAmount: (json['rateAmount'] as num).toDouble(),
      serviceId: json['serviceId'],
      serviceName: json['serviceName'],
    );
  }

  // Convert RateDTO instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'rateId': rateId,
      'unitType': unitType,
      'subUnit': subUnit,
      'rateAmount': rateAmount,
      'serviceId': serviceId,
    };
  }
}

