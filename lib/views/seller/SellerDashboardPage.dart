import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sayf/constants.dart';

final supabase = Supabase.instance.client;

class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  int productCount = 0;
  int orderCount = 0;
  double totalRevenue = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
  try {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() => isLoading = false);
      return;
    }

    // ✅ Correction : from('product') au lieu de 'products'
    final productRes = await supabase
        .from('products')
        .select('id')
        .eq('tenant_id', userId);

    final ids = productRes.map((p) => p['id'] as String).toList();
    productCount = ids.length;

    if (ids.isEmpty) {
      setState(() {
        orderCount = 0;
        totalRevenue = 0.0;
        isLoading = false;
      });
      return;
    }

    final ordersRes = await supabase
        .from('orders')
        .select('total_price')
        // .eq('customer_id', userId)
        .filter('product_id', 'in', '(${ids.join(",")})');

    orderCount = ordersRes.length;
    totalRevenue = ordersRes.fold(0.0, (sum, order) {
      return sum + (order['total_price'] ?? 0.0);
    });

    setState(() => isLoading = false);
  } catch (e) {
    print('Dashboard Error: $e');
    setState(() => isLoading = false);
  }
}



@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF7F9FC), // Light gray background
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Text(
                  '📊 Dashboard',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: KprimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome back, Seller 👋',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 30),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 1,
                  childAspectRatio: 3.5,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 20,
                  children: [
                    buildStatCard(
                      title: 'Total Products',
                      value: '$productCount',
                      icon: Icons.inventory_2_rounded,
                      color: KaccentColor,
                    ),
                    buildStatCard(
                      title: 'Total Orders',
                      value: '$orderCount',
                      icon: Icons.shopping_bag_rounded,
                      color: Colors.orangeAccent,
                    ),
                    buildStatCard(
                      title: 'Revenue',
                      value: '${totalRevenue.toStringAsFixed(2)} MAD',
                      icon: Icons.attach_money_rounded,
                      color: Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
  );
}
  Widget buildStatCard({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.1),
          spreadRadius: 2,
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    padding: const EdgeInsets.all(20),
    child: Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Icon(icon, size: 30, color: color),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
}