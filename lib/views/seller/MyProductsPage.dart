import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'AddEditProductPage.dart';

final supabase = Supabase.instance.client;

class MyProductsPage extends StatefulWidget {
  const MyProductsPage({super.key});

  @override
  State<MyProductsPage> createState() => _MyProductsPageState();
}

class _MyProductsPageState extends State<MyProductsPage> {
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() => isLoading = true);
    try {
      final userId = supabase.auth.currentUser!.id;
      
      final response = await supabase
      .from('products')
      .select('id, name, description, price, image')
      .eq('tenant_id', userId) // ✅ IMPORTANT
      .order('created_at', ascending: false);

      setState(() {
        products = response;
        isLoading = false;
      });
    } catch (error) {
      print('Erreur: $error');
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteProduct(String id) async {
    await supabase.from('products').delete().eq('id', id);
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text('Aucun produit trouvé'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: product['image'] != null
                            ? Image.network(product['image'], width: 50, height: 50)
                            : const Icon(Icons.image, size: 40),
                        title: Text(product['name'] ?? ''),
                        subtitle: Text('${product['price']} DH'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEditProductPage(product: product),
                                  ),
                                );
                                fetchProducts();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteProduct(product['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditProductPage()),
          );
          fetchProducts();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
