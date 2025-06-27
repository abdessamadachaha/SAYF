import 'package:flutter/material.dart';
import 'package:sayf/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<void> deleteProduct(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer ce produit ?"),
        content: const Text("Cette action est irréversible."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await supabase.from('products').delete().eq('id', id);
      fetchProducts();
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
                            return Card(
                              color: KbackgroundColor,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: KaccentColor.withOpacity(0.2)),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: product['image'] != null
                                      ? Image.network(
                                          product['image'],
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(Icons.image_not_supported, size: 40),
                                ),
                                title: Text(
                                  product['name'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text("Prix : ${product['price']} DH"),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => deleteProduct(product['id']),
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
