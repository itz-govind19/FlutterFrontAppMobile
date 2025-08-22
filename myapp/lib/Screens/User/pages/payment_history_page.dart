import 'package:flutter/material.dart';

class PaymentHistoryPage extends StatelessWidget {
  const PaymentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment History"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "Payment History Page",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
