import 'package:flutter/material.dart';

class PaymentViewPage extends StatelessWidget {
  const PaymentViewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "View Payment Page",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
