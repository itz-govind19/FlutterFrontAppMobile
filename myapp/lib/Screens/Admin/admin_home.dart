import 'package:flutter/material.dart';
import 'pages/vehicle_detail_page.dart';
import 'pages/service_rate_page.dart';
import 'pages/payment_view_page.dart';
import 'pages/expenses_page.dart';
import 'pages/payment_settlement_page.dart';
import 'pages/notification_page.dart';
import 'pages/queue_admin_page.dart';

class AdminHome extends StatefulWidget {
  final String username;
  const AdminHome({Key? key, required this.username}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Vehicle Detail', 'icon': Icons.directions_car, 'page': const VehicleDetailPage()},
    {'title': 'Service + Rate', 'icon': Icons.home_repair_service, 'page': const ServiceRatePage()},
    {'title': 'View Payment', 'icon': Icons.payment, 'page': const PaymentViewPage()},
    {'title': 'Expenses', 'icon': Icons.money_off, 'page': const ExpensesPage()},
    {'title': 'Payment Settlement', 'icon': Icons.account_balance_wallet, 'page': const PaymentSettlementPage()},
    {'title': 'Notification', 'icon': Icons.notifications, 'page': const NotificationPage()},
    {'title': 'Queue (Change Order)', 'icon': Icons.queue_play_next, 'page': const QueueAdminPage()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_menuItems[_selectedIndex]['title']),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.username),
              accountEmail: const Text("Admin"),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.admin_panel_settings, size: 32),
              ),
            ),
            ..._menuItems.asMap().entries.map((entry) {
              int idx = entry.key;
              var item = entry.value;
              return ListTile(
                leading: Icon(item['icon']),
                title: Text(item['title']),
                selected: idx == _selectedIndex,
                onTap: () {
                  setState(() => _selectedIndex = idx);
                  Navigator.pop(context); // close drawer
                },
              );
            }),
          ],
        ),
      ),
      body: _menuItems[_selectedIndex]['page'],
    );
  }
}
