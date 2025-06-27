import 'package:flutter/material.dart';

class AdminDrawer extends StatelessWidget {
  final Function(int) onTap;
  const AdminDrawer({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.purple),
            child: Text('Admin Panel', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(title: const Text("Utilisateurs"), onTap: () => onTap(0)),
          ListTile(title: const Text("Produits"), onTap: () => onTap(1)),
          ListTile(title: const Text("Commandes"), onTap: () => onTap(2)),
          ListTile(title: const Text("Mon Profil"), onTap: () => onTap(3)),
        ],
      ),
    );
  }
}
