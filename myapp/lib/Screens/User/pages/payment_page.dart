import 'package:flutter/material.dart';
import 'package:myapp/dto/Payment_model.dart';
import 'package:myapp/services/payment_service.dart';
import 'package:upi_pay/upi_pay.dart';

class PaymentPage extends StatefulWidget {
  final PaymentDTO1 payment;

  const PaymentPage({super.key, required this.payment});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Future<List<ApplicationMeta>> _appsFuture;

  @override
  void initState() {
    super.initState();
    _appsFuture = PaymentService.getUPIApps();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select UPI App")),
      body: FutureBuilder<List<ApplicationMeta>>(
        future: _appsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final apps = snapshot.data ?? [];
          if (apps.isEmpty) {
            return const Center(child: Text("No UPI apps found"));
          }

          return ListView.builder(
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];

              return ListTile(
                leading: const Icon(Icons.account_balance_wallet, size: 40),
                title: Text(app.upiApplication.getAppName()),
                onTap: () async {
                  final response = await PaymentService.makePayment(
                    widget.payment,
                    app.upiApplication,
                  );

                  String statusText;
                  switch (response.status.toString().toLowerCase()) {
                    case 'success':
                      statusText = "Payment Successful";
                      break;
                    case 'failure':
                      statusText = "Payment Failed";
                      break;
                    case 'submitted':
                      statusText = "Payment Submitted";
                      break;
                    default:
                      statusText = "Unknown Status";
                  }

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Payment Status: $statusText")),
                  );

                  Navigator.pop(context); // Go back after payment
                },
              );
            },
          );
        },
      ),
    );
  }
}
