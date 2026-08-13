import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import 'clients_screens.dart';
import 'dashboard_screen.dart';
import 'more_screens.dart';
import 'orders_screens.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;
  int refreshToken = 0;

  void refresh() => setState(() => refreshToken++);

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(key: ValueKey('dashboard-$refreshToken'), onDataChanged: refresh),
      ClientsScreen(key: ValueKey('clients-$refreshToken'), onDataChanged: refresh),
      OrdersScreen(key: ValueKey('orders-$refreshToken'), onDataChanged: refresh),
      DeliveriesScreen(key: ValueKey('deliveries-$refreshToken'), onDataChanged: refresh),
      const MoreScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        height: 68,
        backgroundColor: Colors.white,
        indicatorColor: CoutelyaColors.purpleSoft,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people_rounded), label: 'Clients'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long_rounded), label: 'Commandes'),
          NavigationDestination(icon: Icon(Icons.local_shipping_outlined), selectedIcon: Icon(Icons.local_shipping_rounded), label: 'Livraisons'),
          NavigationDestination(icon: Icon(Icons.grid_view_rounded), selectedIcon: Icon(Icons.grid_view_rounded), label: 'Plus'),
        ],
      ),
    );
  }
}
