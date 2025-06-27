import 'package:flutter/material.dart';
import 'package:sayf/constants.dart';
import 'package:sayf/views/seller/MyProductsPage.dart';
import 'package:sayf/views/seller/OrdersPage.dart';
import 'package:sayf/views/seller/SellerDashboardPage.dart';
import 'package:sayf/views/seller/SellerProfilePage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SellerPage extends StatefulWidget {
  const SellerPage({super.key});

  @override
  State<SellerPage> createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {
  int _selectedPageIndex = 0;

  final List<Widget> _pages = [
     SellerDashboardPage(),
     MyProductsPage(),
     OrdersPage(),
     SellerProfilePage(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'My Products',
    'Orders',
    'Profile',
  ];

  void _onSelectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
    Navigator.pop(context);
  }

  void _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KbackgroundColor,
      appBar: AppBar(
        title: Text(
          _titles[_selectedPageIndex],
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: KprimaryColor,
      ),
      drawer: Drawer(
        backgroundColor: KprimaryColor,
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: KprimaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.storefront, color: Colors.white, size: 50),
                  SizedBox(height: 10),
                  Text('Seller Menu',
                      style: TextStyle(color: Colors.white, fontSize: 22)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard, color: KaccentColor),
              title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
              onTap: () => _onSelectPage(0),
            ),
            ListTile(
              leading: Icon(Icons.inventory, color: KaccentColor),
              title: const Text('My Products', style: TextStyle(color: Colors.white)),
              onTap: () => _onSelectPage(1),
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag, color: KaccentColor),
              title: const Text('Orders', style: TextStyle(color: Colors.white)),
              onTap: () => _onSelectPage(2),
            ),
            ListTile(
              leading: Icon(Icons.person, color: KaccentColor),
              title: const Text('Profile', style: TextStyle(color: Colors.white)),
              onTap: () => _onSelectPage(3),
            ),
            const Divider(color: Colors.white54),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _pages[_selectedPageIndex],
    );
  }
}
