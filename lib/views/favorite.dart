import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:sayf/constants.dart';
import 'package:sayf/models/product.dart';
import 'package:sayf/provider/favorite_provider.dart';
import 'package:google_fonts/google_fonts.dart';



class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final provider = FavoriteProvider.of(context, listen: false);
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      await provider.fetchFavorites();
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل تحميل قائمة التفضيلات';
      });
      debugPrint('Error loading favorites: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeItem(Product item, int index) async {
    final provider = FavoriteProvider.of(context, listen: false);
    try {
      await provider.removeFromDatabase(item);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في حذف العنصر')),
      );
      debugPrint('Error removing favorite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = FavoriteProvider.of(context);
    final favorites = provider.favorites;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: KprimaryColor,
        elevation: 0,
        title: Text('My Wishlist',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold

            ),),
        centerTitle: true,
        actions: [
          if (!_isLoading && favorites.isNotEmpty)
            IconButton(
              icon: const Icon(LucideIcons.refresh_ccw),
              onPressed: _loadFavorites,
              tooltip: 'Upload',
            ),
        ],
      ),
      body: _buildBody(provider, favorites),
    );
  }

  Widget _buildBody(FavoriteProvider provider, List<Product> favorites) {
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.circle_alert, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 18, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFavorites,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.heart, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'القائمة فارغة',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              'اضغط على أيقونة القلب لإضافة عناصر',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: RefreshIndicator(
        onRefresh: _loadFavorites,
        child: ListView.separated(
          itemCount: favorites.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = favorites[index];
            return _buildFavoriteItem(item, index);
          },
        ),
      ),
    );
  }

  Widget _buildFavoriteItem(Product item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                item.image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(LucideIcons.image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  '${item.price.toStringAsFixed(2)} MAD',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                IconButton(
                  onPressed: () => _removeItem(item, index),
                  icon: const Icon(LucideIcons.trash_2),
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
