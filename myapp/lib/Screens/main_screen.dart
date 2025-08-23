import 'package:flutter/material.dart';
import 'package:myapp/Screens/Admin/pages/expenses_page.dart';
import 'package:myapp/Screens/Admin/pages/notification_page.dart';
import 'package:myapp/Screens/Admin/pages/payment_settlement_page.dart';
import 'package:myapp/Screens/Admin/pages/payment_view_page.dart';
import 'package:myapp/Screens/Admin/pages/queue_admin_page.dart';
import 'package:myapp/Screens/Admin/pages/rate_page.dart';
import 'package:myapp/Screens/Admin/pages/service_rate_page.dart';
import 'package:myapp/Screens/Admin/pages/vehicle_detail_page.dart';
import 'package:myapp/Screens/User/pages/about_page.dart';
import 'package:myapp/Screens/User/pages/booking_page.dart';
import 'package:myapp/Screens/User/pages/home_page.dart';
import 'package:myapp/Screens/User/pages/queue_page.dart';

class MainScreen extends StatefulWidget {
  final String role; // "guest", "admin", "user"
  final String username; // required for HomePage

  const MainScreen({
    Key? key,
    required this.role,
    required this.username,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  String get username => widget.username;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // BottomNavigationBar pages (use widget.username here)
    final List<Widget> bottomPages = [
      HomePage(username: widget.username),
      const BookingPage(),
      const QueuePage(),
      const AboutPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.role.toUpperCase()} Dashboard"),
      ),

      // Drawer only if role != guest
      drawer: widget.role == "guest"
          ? null
          : Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Menu",
                  style: TextStyle(color: Colors.white, fontSize: 22)),
            ),

            // Admin full menu
            if (widget.role == "admin") ...[
              _buildDrawerItem("Vehicle Detail", VehicleDetailPage(userName: username)),
              _buildDrawerItem("Services", const ServiceRatePage()),
              _buildDrawerItem("Rates Per Service", RatePage()),
              _buildDrawerItem("View Payment", const PaymentViewPage()),
              _buildDrawerItem("Expenses", const ExpensesPage()),
              _buildDrawerItem("Payment Settlement", const PaymentSettlementPage()),
              _buildDrawerItem("Notification", const NotificationPage()),
              _buildDrawerItem("Queue (Change Order)", const QueueAdminPage()),
            ],

            // Normal User limited menu
            if (widget.role == "user") ...[
              _buildDrawerItem("View Payment", const PaymentViewPage()),
              _buildDrawerItem("Booking History", const BookingPage()),
            ],
          ],
        ),
      ),

      body: bottomPages[_selectedIndex],

      // Bottom Nav always there
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book_online), label: "Booking"),
          BottomNavigationBarItem(icon: Icon(Icons.queue), label: "Queue"),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "About"),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildDrawerItem(String title, Widget page) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}