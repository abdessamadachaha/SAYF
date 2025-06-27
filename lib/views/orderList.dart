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
        SnackBar(content: Text("Error loading orders: $e")),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // ✅ No back arrow
        title: Text(
          'My Orders',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: KprimaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8F8F8),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? Center(
                  child: Text("No orders found.",
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final product = order['product'];
                    final String imageUrl = product['image'];
                    final String name = product['name'];
                    final String status = order['status'];
                    final DateTime start = DateTime.parse(order['start_day']);
                    final DateTime end = DateTime.parse(order['end_day']);
                    final double price = (order['total_price'] as num).toDouble();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(name,
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'From ${DateFormat.yMMMd().format(start)} to ${DateFormat.yMMMd().format(end)}',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total: ${price.toStringAsFixed(2)} MAD',
                              style: GoogleFonts.poppins(
                                  fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status,
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
