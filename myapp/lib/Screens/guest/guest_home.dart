import 'package:flutter/material.dart';
import 'package:myapp/Screens/User/pages/about_page.dart';
import 'package:myapp/Screens/User/pages/booking_page.dart';
import 'package:myapp/Screens/User/pages/home_page.dart';
import 'package:myapp/Screens/User/pages/queue_page.dart';


class GuestHome extends StatefulWidget {

  @override
  State<GuestHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<GuestHome> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    HomePage(username: " "),
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
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.event_note_outlined), label: 'BOOKING'),
          BottomNavigationBarItem(icon: Icon(Icons.queue_outlined), label: 'QUEUE'),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'ABOUT'),
        ],
      ),
    );
  }

  String _titleForIndex(int i) {
    switch (i) {
      case 0: return 'Home';
      case 1: return 'Booking';
      case 2: return 'Queue';
      case 3: return 'About';
      default: return 'User';
    }
  }
}
