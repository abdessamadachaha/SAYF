import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sayf/constants.dart';
import 'package:sayf/views/homepage.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  final pages = [Homepage(), Homepage(), Homepage()];



  @override
  Widget build(BuildContext context) {
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
            icon: Icon(LucideIcons.user, size: 25),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
