import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sayf/constants.dart';
import 'package:sayf/models/person.dart';
import 'package:sayf/views/favorite.dart';
import 'package:sayf/views/homepage.dart';
import 'package:sayf/views/orderList.dart';
import 'package:sayf/views/profile_screen.dart';

class Home extends StatefulWidget {
   final Person person;
  final int initialIndex;

  const Home({super.key, required this.person, this.initialIndex = 0});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late int _selectedIndex;

   @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }



  @override
  Widget build(BuildContext context) {
      final pages = [Homepage(person: widget.person), FavoriteScreen(), MyOrdersPage(customerId: widget.person.id), ProfileScreen(person: widget.person)];

    return Scaffold(
      // Your body content here
      body: pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: KprimaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.house, size: 25),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.heart, size: 25),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.listOrdered, size: 25),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.user, size: 25),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
