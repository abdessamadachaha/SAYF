import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
  setState(() => isLoading = true);

  try {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    // On filtre les commandes du propriétaire directement via tenant_id
    final allOrders = await supabase
        .from('orders')
        .select('''
          id, start_day, end_day, total_price, address, status,
          product:product_id(id, name, image, price),
          user:customer_id(id, name, email, image, phone)
        ''')
        .eq('tenant_id', userId) // ✅ Filtrage ici
        .order('created_at', ascending: false);

    setState(() {
      orders = allOrders;
      isLoading = false;
    });
  } catch (e) {
    print('Erreur récupération commandes : $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
    );
    setState(() => isLoading = false);
  }
}

  Future<void> updateOrderStatus(String orderId, String status) async {
    await supabase.from('orders').update({'status': status}).eq('id', orderId);
    fetchOrders();
  }

  void showOrderDialog(BuildContext context, dynamic user, String orderId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  title: Row(
    children: const [
      Icon(Icons.person, color: Colors.teal),
      SizedBox(width: 8),
      Text(
        "Détails du client",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
  content: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Center(
        child: CircleAvatar(
          radius: 40,
          backgroundImage: (user['image'] != null && user['image'] != '')
              ? NetworkImage(user['image'])
              : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        "👤 Nom: ${user['name'] ?? 'Inconnu'}",
        style: const TextStyle(fontSize: 16),
      ),
      const SizedBox(height: 6),
      Text(
        "📧 Email: ${user['email'] ?? 'Non fourni'}",
        style: const TextStyle(fontSize: 16),
      ),
      const SizedBox(height: 6),
      Text(
        "📞 Téléphone: ${user['phone'] ?? 'Non fourni'}",
        style: const TextStyle(fontSize: 16),
      ),
    ],
  ),
  actionsAlignment: MainAxisAlignment.spaceBetween,
  actions: [
    TextButton.icon(
      onPressed: () {
        Navigator.pop(context);
        updateOrderStatus(orderId, 'canceled');
      },
      icon: const Icon(Icons.cancel, color: Colors.red),
      label: const Text("Annuler", style: TextStyle(color: Colors.red)),
    ),
    ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        Navigator.pop(context);
        updateOrderStatus(orderId, 'confirmed');
      },
      icon: const Icon(Icons.check_circle),
      label: const Text("Confirmer"),
    ),
  ],
),
    );
  }

  String formatDate(String? date) {
    if (date == null) return '...';
    return DateFormat('dd/MM/yyyy').format(DateTime.parse(date));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text("Aucune commande trouvée"))
              : ListView.builder(
                  itemCount: orders.length,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final product = order['product'];
                    final user = order['user'];
                    final status = order['status'] ?? 'pending';

                    return InkWell(
  onTap: () => showOrderDialog(context, user, order['id']),
  child: Card(
    elevation: 6,
    shadowColor: Colors.black26,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image produit
                product?['image'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          product['image'],
                          width: 85,
                          height: 85,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        width: 85,
                        height: 85,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.image_not_supported, size: 36, color: Colors.grey),
                      ),
                const SizedBox(width: 14),

                // Détails commande
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product?['name'] ?? 'Produit inconnu',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              order['address'] ?? '',
                              style: const TextStyle(fontSize: 13, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'Du ${formatDate(order['start_day'])} au ${formatDate(order['end_day'])}',
                            style: const TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.monetization_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${order['total_price']} DH',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          const Text("Statut: "),
                          Text(
                            status,
                            style: TextStyle(
                              color: status == 'confirmed'
                                  ? Colors.green
                                  : status == 'canceled'
                                      ? Colors.red
                                      : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Client
                if (user != null)
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: user['image'] != null && user['image'] != ''
                            ? NetworkImage(user['image'])
                            : null,
                        child: user['image'] == null || user['image'] == ''
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                        backgroundColor: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user['name'] ?? '',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );

                  },
                ),
    );
  }
}
