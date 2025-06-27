import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sayf/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class MyOrdersPage extends StatefulWidget {
  final String customerId;
  const MyOrdersPage({super.key, required this.customerId});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final response = await supabase
          .from('orders')
          .select('*, product:product_id(name, image)')
          .eq('customer_id', widget.customerId)
          .order('start_day', ascending: false);

      setState(() {
        orders = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ في تحميل الطلبات: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('My Order', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),),
        backgroundColor: KprimaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text("No requests."))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final product = order['product'];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            product['image'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(product['name']),
                        subtitle: Text(
                          'From ${DateFormat.yMMMd().format(DateTime.parse(order['start_day']))} '
                          'To ${DateFormat.yMMMd().format(DateTime.parse(order['end_day']))}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${order['total_price']} MAD'),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: order['status'] == 'confirmed'
                                    ? Colors.green
                                    : (order['status'] == 'pending'
                                        ? Colors.orange
                                        : Colors.red),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                order['status'],
                                style: const TextStyle(color: Colors.white, fontSize: 12),
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
