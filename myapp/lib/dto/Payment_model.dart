class PaymentDTO1 {
  final String referenceId; // Booking reference
  final double amount; // in INR
  final String upiId; // UPI ID of receiver
  final String payeeName; // Name of receiver

  PaymentDTO1({
    required this.referenceId,
    required this.amount,
    required this.upiId,
    required this.payeeName,
  });

  Map<String, dynamic> toJson() {
    return {
      "referenceId": referenceId,
      "amount": amount,
      "upiId": upiId,
      "payeeName": payeeName,
    };
  }
}
