import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sayf/constants.dart';
import 'package:sayf/models/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductPage extends StatefulWidget {
  final Product product;
  const ProductPage({super.key, required this.product});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String ownerName = '';
  String ownerImage = '';

  @override
  void initState() {
    super.initState();
    fetchOwner();
  }

  Future<void> fetchOwner() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('users')
        .select('name, image')
        .eq('id', widget.product.idTenant)
        .single();

    setState(() {
      ownerName = response['name'] ?? 'Unknown';
      ownerImage = response['image'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(product.name, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: KprimaryColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white, size: 23),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🖼️ Image
          SizedBox(
            height: 250,
            width: double.infinity,
            child: Image.network(
              product.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Center(child: Icon(Icons.broken_image, size: 60)),
            ),
          ),

          // 📦 Contenu
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // 🏷️ Nom
                  Text(
                    product.name,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 💰 Prix + /day
                  Row(
                    children: [
                      Text(
                        'MAD ${product.price.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          color: KaccentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text("/day", style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 📍 Adresse
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: Colors.red, size: 20),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          product.address,
                          style: const TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 👤 Mol Produit
                  if (ownerName.isNotEmpty)
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: ownerImage.isNotEmpty
                              ? NetworkImage(ownerImage)
                              : const AssetImage('assets/avatar.jpg') as ImageProvider,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          ownerName,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // 📄 Description
                  Text(
                    product.description,
                    style: GoogleFonts.roboto(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          // 🛒 Order Now
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.shopping_cart),
                label: const Text("Order Now"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: KprimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("🛒 Order placed successfully!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
