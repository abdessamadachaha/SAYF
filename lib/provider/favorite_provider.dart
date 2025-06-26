import 'package:flutter/material.dart';
import 'package:sayf/models/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

// class FavoriteProvider extends ChangeNotifier {
//   final List<Product> _favorites = [];
//   List<Product> get favorites => _favorites;

//   final SupabaseClient _supabase = Supabase.instance.client;
//   String? get customerId => _supabase.auth.currentUser?.id;

//   // Add this initialization method
//   Future<void> initialize() async {
//     if (customerId != null) {
//       await fetchFavorites();
//     }
//     _supabase.auth.onAuthStateChange.listen((event) async {
//       if (customerId != null) {
//         await fetchFavorites();
//       } else {
//         _favorites.clear();
//         notifyListeners();
//       }
//     });
//   }

//   Future<void> fetchFavorites() async {
//     try {
//       final response = await _supabase
//           .from('favorite')
//           .select('''
//             product_id,
//             product:product_id (*)
//           ''')
//           .eq('customer_id', customerId!);

//       _favorites.clear();
      
//       for (final item in response) {
//       if (item['product'] != null) {
//         final productData = item['product'] as Map<String, dynamic>;
//         final product = Product(
//           id: productData['id'],
//           name: productData['name'],
//           description: productData['description'],
//           price: productData['price'],
//           image: productData['image'],
//           idTenant: productData['tenant_id'],
//           is_active: productData['is_active']
//           // other fields...
//         );
//         _favorites.add(product);
//       }
//     }
      
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error fetching favorites: $e');
//     }
//   }

//   void toggleProduct(Map<String, dynamic> productMap) async {
//   final product = Product.fromMap(productMap); // تحويل الـ Map إلى كائن Product

//   if (_favorites.any((p) => p.id == product.id)) {
//     await removeFromDatabase(product);
//     _favorites.removeWhere((p) => p.id == product.id);
//   } else {
//     await addToDatabase(product);
//     _favorites.add(product);
//   }

//   notifyListeners();
// }



//   bool isExist(Product product) {
//     return _favorites.any((p) => p.id == product.id);
//   }

//   Future<void> addToDatabase(Map<String, dynamic> product) async {
//   final supabase = Supabase.instance.client;
//   final userId = supabase.auth.currentUser?.id;

//   if (userId == null) throw Exception('User not logged in');

//   await supabase.from('favorite').insert({
//     'user_id': userId,
//     'product_id': product['id'],
//     'name': product['name'],
//     'price': product['price'],
//     'image': product['image'],
//     'description': product['description'],
//   });

//   // نزيدوه للـ List المحلية
//   favorites.add(Product(
//     id: product['id'],
//     name: product['name'],
//     price: double.tryParse(product['price'].toString()) ?? 0.0,
//     image: product['image'],
//     description: product['description'] ?? '',
//     idTenant: product['tenant_id'],
//     is_active: product['is_active']
//   ));
//   notifyListeners();
// }


//  Future<void> removeFromDatabase(dynamic product) async {
//   final productId = product is Product ? product.id : product['id'];

//   await _supabase.from('favorite').delete().match({
//     'customer_id': customerId!,
//     'product_id': productId,
//   });
// }

//   static FavoriteProvider of(BuildContext context, {bool listen = true}) {
//     return Provider.of<FavoriteProvider>(context, listen: listen);
//   }
// }

class FavoriteProvider extends ChangeNotifier {
  final List<Product> _favorites = [];
  List<Product> get favorites => _favorites;

  final SupabaseClient _supabase = Supabase.instance.client;
  String? get customerId => _supabase.auth.currentUser?.id;

  Future<void> initialize() async {
    if (customerId != null) await fetchFavorites();
    _supabase.auth.onAuthStateChange.listen((event) async {
      if (customerId != null) {
        await fetchFavorites();
      } else {
        _favorites.clear();
        notifyListeners();
      }
    });
  }

  Future<void> fetchFavorites() async {
    try {
      final response = await _supabase
          .from('favorite')
          .select('product_id, product:product_id(*)')
          .eq('customer_id', customerId!);

      _favorites.clear();

      for (final item in response) {
        if (item['product'] != null) {
          _favorites.add(Product.fromMap(item['product']));
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching favorites: $e');
    }
  }

  void toggleProduct(Product product) async {
    if (_favorites.any((p) => p.id == product.id)) {
      await removeFromDatabase(product);
    } else {
      await addToDatabase(product);
    }
    notifyListeners();
  }

  Future<void> addToDatabase(Product product) async {
    final userId = customerId;
    if (userId == null) throw Exception('User not logged in');
    await _supabase.from('favorite').insert({
      'customer_id': userId,
      'product_id': product.id,
    });
    _favorites.add(product);
  }

  Future<void> removeFromDatabase(Product product) async {
    await _supabase.from('favorite').delete().match({
      'customer_id': customerId!,
      'product_id': product.id,
    });
    _favorites.removeWhere((p) => p.id == product.id);
  }

  bool isExist(Product product) {
    return _favorites.any((p) => p.id == product.id);
  }

  static FavoriteProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<FavoriteProvider>(context, listen: listen);
  }
}
