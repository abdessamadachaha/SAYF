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

      final response = await supabase
          .from('orders')
          .select('''
            id, strart_day, end_day, total_price,
            products(id, name, image, price),
            users(id, name, image)
          ''')
          .eq('customer_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        orders = response;
        isLoading = false;
      });
    } catch (e) {
      print('Erreur lors de la récupération des commandes : $e');
      setState(() => isLoading = false);
    }
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
                    final product = order['products'];
                    final user = order['users'];

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Product image
                            product['image'] != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      product['image'],
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Container(
                                    width: 70,
                                    height: 70,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image, size: 40),
                                  ),
                            const SizedBox(width: 12),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product['name'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(
                                      '📅 Du ${formatDate(order['strart_day'])} au ${formatDate(order['end_day'])}'),
                                  Text('💰 ${order['total_price']} DH'),
                                ],
                              ),
                            ),
                            // Seller avatar
                            if (user != null)
                              Column(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundImage:
                                        user['image'] != null && user['image'] != ''
                                            ? NetworkImage(user['image'])
                                            : null,
                                    child: user['image'] == null
                                        ? const Icon(Icons.person)
                                        : null,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(user['name'] ?? '',
                                      style: const TextStyle(fontSize: 12)),
                                ],
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
