import 'package:flutter/material.dart';
import 'package:myapp/Screens/Admin/pages/rate_page.dart';
import 'package:myapp/Screens/Admin/pages/vehicle_detail_page.dart';
import 'package:myapp/Screens/Admin/pages/service_rate_page.dart';
import 'package:myapp/Screens/Admin/pages/payment_view_page.dart';
import 'package:myapp/Screens/Admin/pages/expenses_page.dart';
import 'package:myapp/Screens/Admin/pages/payment_settlement_page.dart';
import 'package:myapp/Screens/Admin/pages/notification_page.dart';
import 'package:myapp/Screens/Admin/pages/queue_admin_page.dart';

import 'package:myapp/Screens/User/pages/about_page.dart';
import 'package:myapp/Screens/User/pages/booking_page.dart';
import 'package:myapp/Screens/User/pages/queue_page.dart';
import 'package:myapp/Screens/User/pages/home_page.dart';

class AdminHome extends StatefulWidget {
  final String username;
  const AdminHome({Key? key, required this.username}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    HomePage(username: widget.username),
    const BookingPage(),
    const QueuePage(),
    const AboutPage(),
  ];

  // ✅ Build drawer items at runtime so we can pass widget.username
  List<Map<String, dynamic>> buildDrawerItems() {
    return [
      {
        'title': 'Vehicle Detail',
        'icon': Icons.directions_car,
        'page': VehicleDetailPage(userName: widget.username), // removed const
      },
      {
        'title': 'Service',
        'icon': Icons.home_repair_service,
        'page': const ServiceRatePage(),
      },
      {
        'title': 'Rates Per Service',
        'icon': Icons.home_repair_service,
        'page': const RatePage(),
      },
      {
        'title': 'View Payment',
        'icon': Icons.payment,
        'page': const PaymentViewPage(),
      },
      {
        'title': 'Expenses',
        'icon': Icons.money_off,
        'page': const ExpensesPage(),
      },
      {
        'title': 'Payment Settlement',
        'icon': Icons.account_balance_wallet,
        'page': const PaymentSettlementPage(),
      },
      {
        'title': 'Notification',
        'icon': Icons.notifications,
        'page': const NotificationPage(),
      },
      {
        'title': 'Queue (Change Order)',
        'icon': Icons.queue_play_next,
        'page': const QueueAdminPage(),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForIndex(_currentIndex)),
        centerTitle: true,
      ),

      // ✅ Admin Drawer
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.username),
              accountEmail: const Text("ADMIN"),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.admin_panel_settings),
              ),
            ),
            ...buildDrawerItems().map((item) => ListTile(
              leading: Icon(item['icon']),
              title: Text(item['title']),
              onTap: () {
                Navigator.pop(context); // close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item['page']),
                );
              },
            )),
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
      case 0:
        return 'Home';
      case 1:
        return 'Booking';
      case 2:
        return 'Queue';
      case 3:
        return 'About';
      default:
        return 'Admin';
    }
  }
}