import 'package:flutter/material.dart';
import 'package:sayf/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> allProducts = [];
  List<dynamic> filteredProducts = [];
  String searchQuery = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() => isLoading = true);
    final response = await supabase.from('products').select();
    setState(() {
      allProducts = response;
      filteredProducts = response;
      isLoading = false;
    });
  }

  void filterProducts(String query) {
    setState(() {
      searchQuery = query;
      filteredProducts = allProducts.where((product) {
        final name = product['name']?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> toggleProductStatus(String id, bool currentStatus) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(currentStatus ? "Désactiver ce produit ?" : "Restaurer ce produit ?"),
        content: Text(currentStatus
            ? "Il ne sera plus visible, mais les données resteront."
            : "Le produit sera de nouveau visible."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: currentStatus ? Colors.red : Colors.green,
            ),
            child: Text(currentStatus ? "Désactiver" : "Restaurer"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await supabase.from('products').update({'is_active': !currentStatus}).eq('id', id);
      await fetchProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(currentStatus
              ? "Produit désactivé avec succès."
              : "Produit restauré avec succès."),
        ),
      );
    } catch (e) {
      debugPrint("Erreur suppression : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : \${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KbackgroundColor,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: KaccentColor))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Rechercher un produit...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: filterProducts,
                  ),
                ),
                Expanded(
                  child: filteredProducts.isEmpty
                      ? const Center(child: Text("Aucun produit trouvé"))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: filteredProducts.length,
                          itemBuilder: (_, i) {
                            final product = filteredProducts[i];
                            final isActive = product['is_active'] == true;

                            return InkWell(
                              onTap: () => showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                ),
                                builder: (_) {
                                  return DraggableScrollableSheet(
                                    expand: false,
                                    initialChildSize: 0.6,
                                    maxChildSize: 0.9,
                                    builder: (context, scrollController) {
                                      return SingleChildScrollView(
                                        controller: scrollController,
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Center(
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(16),
                                                child: product['image'] != null
                                                    ? Image.network(product['image'],
                                                        height: 180, fit: BoxFit.cover)
                                                    : Container(
                                                        height: 180,
                                                        width: double.infinity,
                                                        color: Colors.grey[300],
                                                        child: const Icon(Icons.image_not_supported, size: 80),
                                                      ),
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            Text(
                                              product['name'] ?? '',
                                              style: GoogleFonts.poppins(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              product['description'] ?? 'Aucune description',
                                              style: GoogleFonts.poppins(fontSize: 15),
                                            ),
                                            const Divider(height: 24),
                                            Row(
                                              children: [
                                                const Icon(Icons.local_activity, size: 20),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "Adresse : ${product['address'] ?? 'Inconnue'}",
                                                  style: GoogleFonts.poppins(fontSize: 14),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(Icons.price_change_outlined, size: 20),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "Prix : ${product['price']} DH",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.teal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              child: Card(
                                color: Colors.white,
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(color: KaccentColor.withOpacity(0.2)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: product['image'] != null
                                            ? Image.network(
                                                product['image'],
                                                width: 70,
                                                height: 70,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                width: 70,
                                                height: 70,
                                                color: Colors.grey.shade300,
                                                child: const Icon(Icons.image_not_supported, size: 30),
                                              ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product['name'] ?? '',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "${product['price']} DH",
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.indigo,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          isActive ? Icons.block : Icons.check_circle_outline,
                                          color: isActive ? Colors.red : Colors.green,
                                        ),
                                        tooltip: isActive ? "Désactiver" : "Restaurer",
                                        onPressed: () => toggleProductStatus(product['id'], isActive),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}