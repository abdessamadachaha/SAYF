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
    setState(() => isLoading = true);

    final response = await supabase
        .from('orders')
        .select('''
          id, created_at, total_price, start_day, end_day,
          products(id, name, image, tenant_id),
          users:customer_id(id, name, image)
        ''')
        .order('created_at', ascending: false);

    setState(() {
      orders = response;
      isLoading = false;
    });
  }

  void showOrderDetails(dynamic order) async {
    final product = order['products'];
    final customer = order['users'];

    final tenantId = product['tenant_id'];
    final seller = await supabase
        .from('users')
        .select('name, email, phone, image')
        .eq('id', tenantId)
        .single();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text("🧾 Détails de la commande",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: product['image'] != null
                      ? Image.network(product['image'], width: 60, height: 60, fit: BoxFit.cover)
                      : Container(width: 60, height: 60, color: Colors.grey[300], child: const Icon(Icons.image)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product['name'] ?? "Produit",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text("💵 Prix : ${order['total_price']} DH",
                          style: TextStyle(color: Colors.teal, fontSize: 14)),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.date_range, size: 18),
                const SizedBox(width: 8),
                Text("Du ${order['start_day']} au ${order['end_day']}",
                    style: TextStyle(fontSize: 15, color: Colors.grey[800]))
              ],
            ),
            const Divider(height: 35),
            Text("👤 Client", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(radius: 25, backgroundImage: NetworkImage(customer['image'] ?? '')),
              title: Text(customer['name'] ?? 'Nom inconnu'),
            ),
            const Divider(height: 30),
            Text("🏪 Vendeur", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(radius: 25, backgroundImage: NetworkImage(seller['image'] ?? '')),
              title: Text(seller['name'] ?? ''),
              subtitle: Text(seller['email'] ?? ''),
              trailing: Text(seller['phone'] ?? '', style: TextStyle(color: Colors.blueGrey)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KbackgroundColor,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: KprimaryColor))
          : orders.isEmpty
              ? const Center(child: Text("Aucune commande trouvée"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: orders.length,
                  itemBuilder: (_, i) {
                    final order = orders[i];
                    final product = order['products'] ?? {};
                    final user = order['users'] ?? {};

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: KaccentColor.withOpacity(0.15)),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        onTap: () => showOrderDetails(order),
                        contentPadding: const EdgeInsets.all(16),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: product['image'] != null
                              ? Image.network(product['image'], width: 60, height: 60, fit: BoxFit.cover)
                              : const Icon(Icons.image_not_supported, size: 40),
                        ),
                        title: Text(
                          product['name'] ?? 'Produit inconnu',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text("👤 Client: ${user['name'] ?? 'Inconnu'}"),
                            Text("📅 Date: ${order['created_at'].toString().split('T').first}"),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("💰 Montant", style: TextStyle(fontSize: 12)),
                            Text(
                              "${order['total_price']} DH",
                              style: TextStyle(
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
