import 'package:flutter/material.dart';
import 'package:sayf/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});
  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
  setState(() => isLoading = true);
  try {
    final response = await supabase
        .from('users')
        .select('id, name, email, is_ban, role, image')
        .not('role', 'eq', 'admin') // ⛔ Exclure les admins
        .order('created_at', ascending: false);

    setState(() {
      users = response;
      isLoading = false;
    });
  } catch (e) {
    print('Erreur lors du chargement des utilisateurs : $e');
    setState(() => isLoading = false);
  }
}


  Future<void> toggleBan(String userId, bool currentBan) async {
    await supabase.from('users').update({'is_ban': !currentBan}).eq('id', userId);
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KbackgroundColor,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: KaccentColor))
          : users.isEmpty
              ? const Center(child: Text('Aucun utilisateur trouvé'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: users.length,
                  itemBuilder: (_, i) {
                    final user = users[i];
                    final isBanned = user['is_ban'] ?? false;
                    return Card(
  elevation: 4,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: BorderSide(
      color: isBanned ? Colors.red.withOpacity(0.5) : KaccentColor.withOpacity(0.15),
      width: 1,
    ),
  ),
  child: Padding(
    padding: const EdgeInsets.all(12),
    child: Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: user['image'] != null && user['image'].toString().isNotEmpty
              ? NetworkImage(user['image'])
              : const AssetImage('assets/default-avatar.png') as ImageProvider,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user['name'] ?? 'Sans nom',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user['email'] ?? '',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Rôle: ${user['role']}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isBanned)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '🚫 Banni',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            isBanned ? Icons.lock_open : Icons.block,
            color: isBanned ? Colors.green : Colors.red,
            size: 28,
          ),
          tooltip: isBanned ? "Débloquer l'utilisateur" : "Bannir l'utilisateur",
          onPressed: () => toggleBan(user['id'], isBanned),
        ),
      ],
    ),
  ),
);

                  },
                ),
    );
  }
}
