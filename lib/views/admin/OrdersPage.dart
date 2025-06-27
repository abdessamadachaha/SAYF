import 'package:flutter/material.dart';
import 'package:sayf/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});
  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final response = await supabase
        .from('orders')
        .select('*, users(name, image), products(name, image)');
    setState(() {
      orders = response;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KbackgroundColor,
      body: isLoading
          ?  Center(child: CircularProgressIndicator(color: KprimaryColor))
          : orders.isEmpty
              ? const Center(child: Text("Aucune commande trouvée"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: orders.length,
                  itemBuilder: (_, i) {
                    final order = orders[i];
                    final product = order['products'];
                    final user = order['users'];

                    return Card(
                      color: KbackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: KaccentColor.withOpacity(0.2)),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: product['image'] != null
                              ? Image.network(product['image'], width: 50, height: 50, fit: BoxFit.cover)
                              : const Icon(Icons.image_not_supported, size: 40),
                        ),
                        title: Text(
                          product['name'] ?? 'Produit inconnu',
                          style:  TextStyle(fontWeight: FontWeight.bold, color: KtextColor),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text("👤 Client: ${user['name'] ?? 'Inconnu'}"),
                            const SizedBox(height: 4),
                            Text("🗓 Date: ${order['created_at'].toString().split('T')[0]}"),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("💰 Montant", style: TextStyle(fontSize: 12)),
                            Text(
                              "${order['totale_price']} DH",
                              style:  TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: KaccentColor,
                              ),
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
