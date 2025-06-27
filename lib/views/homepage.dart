import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sayf/constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sayf/models/person.dart';
import 'package:sayf/views/home.dart';
import 'package:sayf/views/profile_screen.dart';
import 'package:sayf/views/widgets/ProductCart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class Homepage extends StatefulWidget {
  final Person person;
  Homepage({super.key, required this.person});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int selectedCategoryIndex = 0;
  String searchQuery = '';

  Future<List<dynamic>> fetchProducts() async {
    final supabase = Supabase.instance.client;
    var query = supabase.from('products').select();

    if (selectedCategoryIndex != 0) {
      final categoryName = Kcategories[selectedCategoryIndex];
      final categoryId = KcategoryMap[categoryName];
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
    }

    if (searchQuery.isNotEmpty) {
  query = query.or('name.ilike.%$searchQuery%,address.ilike.%$searchQuery%');
}


    final response = await query;
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: KprimaryColor,
        title: Text(
          widget.person.name,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17
          ),
        ),
        leading: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: GestureDetector(
            onTap: () => Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => Home(person: widget.person, initialIndex: 3),
  ),
),


            child: CircleAvatar(
              radius: 40,
              backgroundImage: widget.person.image != null
                            ? NetworkImage(widget.person.image!)
                            : AssetImage('assets/avatar.jpg'),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: KprimaryColor,
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(top: 12),
                      border: InputBorder.none,
                      hintText: 'Search Here',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(LucideIcons.search),
                    ),
                    onChanged: (value) => setState(() => searchQuery = value),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: Kcategories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return _buildCategoryChip(index, Kcategories[index]);
                    },
                  ),
                ),
              ],
            ),
          ),

          /// ✅ Ce `Expanded` maintenant contient **seulement** le `FutureBuilder`
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: fetchProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading products',
                      style: TextStyle(color: Colors.red[400]),
                    ),
                  );
                }

                final products = snapshot.data ?? [];
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 16, left: 10),
                  child: GridView.builder(
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          mainAxisExtent: 280,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                    itemBuilder: (context, index) {
                      return buildProductCard(context, products[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(int index, String name) {
    final isSelected = index == selectedCategoryIndex;
    return GestureDetector(
      onTap: () => setState(() => selectedCategoryIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? KaccentColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
          ),
        ),
        child: Text(
          name,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
