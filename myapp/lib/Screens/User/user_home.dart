import 'package:flutter/material.dart';
import 'package:myapp/Screens/User/pages/booking_history_page.dart';
import 'package:myapp/Screens/User/pages/payment_history_page.dart';
import 'pages/home_page.dart';
import 'pages/booking_page.dart';
import 'pages/queue_page.dart';
import 'pages/about_page.dart';
// Add your extra pages


class UserHome extends StatefulWidget {
  final String username;

  const UserHome({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    HomePage(username: widget.username),
    const BookingPage(),
    const QueuePage(),
    const AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForIndex(_currentIndex)),
        centerTitle: true,
      ),

      // ✅ Drawer only for USER
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.username),
              accountEmail: const Text("USER"),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text("Payment"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaymentHistoryPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Booking History"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookingHistoryPage()),
                );
              },
            ),
          ],
        ),
      ),

      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'HOME'),
          BottomNavigationBarItem(
              icon: Icon(Icons.event_note_outlined), label: 'BOOKING'),
          BottomNavigationBarItem(
              icon: Icon(Icons.queue_outlined), label: 'QUEUE'),
          BottomNavigationBarItem(
              icon: Icon(Icons.info_outline), label: 'ABOUT'),
        ],
      ),
    );
  }

  String _titleForIndex(int i) {
    switch (i) {
      case 0:
        return 'Home';
      case 1:
        return 'Booking';
      case 2:
        return 'Queue';
      case 3:
        return 'About';
      default:
        return 'User';
    }
  }
}