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
    final response = await supabase
        .from('users')
        .select('id, name, email, is_ban, role, image')
        .order('created_at', ascending: false);
    setState(() {
      users = response;
      isLoading = false;
    });
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
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: isBanned ? Colors.red : KaccentColor.withOpacity(0.2)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundImage: user['image'] != null
                              ? NetworkImage(user['image'])
                              : const AssetImage('assets/default-avatar.png') as ImageProvider,
                          radius: 24,
                        ),
                        title: Text(user['name'] ?? 'Sans nom',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user['email'] ?? ''),
                            Text("Rôle: ${user['role']}", style: const TextStyle(fontSize: 13)),
                            if (isBanned)
                              const Text(
                                '🚫 Banni',
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              )
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isBanned ? Icons.lock_open : Icons.block,
                            color: isBanned ? Colors.green : Colors.red,
                          ),
                          tooltip: isBanned ? "Débloquer l'utilisateur" : "Bannir l'utilisateur",
                          onPressed: () => toggleBan(user['id'], isBanned),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
