import 'package:flutter/material.dart';

class BookingHistoryPage extends StatelessWidget {
  const BookingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking History"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "Booking History Page",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}