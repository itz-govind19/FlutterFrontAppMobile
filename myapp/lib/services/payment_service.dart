import 'package:upi_pay/upi_pay.dart';
import 'package:myapp/dto/Payment_model.dart';

class PaymentService {
  /// Fetch installed UPI apps
  static Future<List<ApplicationMeta>> getUPIApps() async {
    final upiPay = UpiPay();
    final apps = await upiPay.getInstalledUpiApplications();

    if (apps.isEmpty) {
      print("⚠️ No UPI apps found. Make sure supported apps are installed.");
    } else {
      for (var app in apps) {
        print("✅ Found UPI app: ${app.upiApplication.appName} (${app.packageName})");
      }
    }

    return apps;
  }
  /// Launch UPI payment
  static Future<UpiTransactionResponse> makePayment(
      PaymentDTO1 payment,
      UpiApplication app,
      ) async {
    final txnRef = DateTime.now().millisecondsSinceEpoch.toString();
    final upiPay = UpiPay();

    return await upiPay.initiateTransaction(
      amount: payment.amount.toStringAsFixed(2),
      app: app, // ✅ FIXED: no need for .upiApplication
      receiverName: payment.payeeName,
      receiverUpiAddress: payment.upiId,
      transactionRef: txnRef,
      transactionNote: "Booking Payment - ${payment.referenceId}",
    );
  }
}