import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  const Homepage({super.key, required this.person});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int selectedCategoryIndex = 0;
  String searchQuery = '';

  List<Map<String, dynamic>> categories = [];
  bool isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final supabase = Supabase.instance.client;
    final response = await supabase.from('category').select('id, name').order('name');

    if (mounted && response is List) {
      setState(() {
        categories = List<Map<String, dynamic>>.from(response);
        isLoadingCategories = false;
      });
    }
  }

  Future<List<dynamic>> fetchProducts({
    required int selectedCategoryIndex,
    required String searchQuery,
  }) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final queryBuilder = supabase
        .from('products')
        .select('*')
        .neq('tenant_id', userId)
        .eq('is_active', true);

    var query = queryBuilder;

    if (selectedCategoryIndex != 0 && selectedCategoryIndex - 1 < categories.length) {
      final selectedCategory = categories[selectedCategoryIndex - 1];
      final categoryId = selectedCategory['id'];
      query = query.eq('category_id', categoryId);
    }

    if (searchQuery.isNotEmpty) {
      query = query.filter('name', 'ilike', '%$searchQuery%')
             .filter('address', 'ilike', '%$searchQuery%');
    }

    final response = await query.order('created_at', ascending: false);
      print('Fetched products: $response');
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
            fontSize: 17,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
                  : const AssetImage('assets/avatar.jpg') as ImageProvider,
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
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(top: 12),
                      border: InputBorder.none,
                      hintText: 'Search Here',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(LucideIcons.search),
                    ),
                    onChanged: (value) => setState(() => searchQuery = value),
                  ),
                ),
                const SizedBox(height: 15),
                isLoadingCategories
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length + 1,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final name = index == 0 ? 'All' : categories[index - 1]['name'];
                            return _buildCategoryChip(index, name);
                          },
                        ),
                      ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: fetchProducts(
                selectedCategoryIndex: selectedCategoryIndex,
                searchQuery: searchQuery,
              ),
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
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: \${snapshot.error}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    });
                    return const SizedBox();
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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