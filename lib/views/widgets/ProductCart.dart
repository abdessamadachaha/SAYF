// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:sayf/constants.dart';
// import 'package:sayf/models/product.dart';
// import 'package:sayf/provider/favorite_provider.dart';

// Widget buildProductCard(BuildContext context, Map<String, dynamic> product) {

//   return GestureDetector(
//     onTap: () {
//       // Navigate to product details
//     },
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Stack(
//           children: [
//             ClipRRect(
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//               ),
//               child: Container(
//                 height: 200,
//                 width: double.infinity,
//                 color: Colors.grey[200],
//                 child: product['image'] != null
//                     ? Image.network(
//                         product['image'],
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) => Center(
//                           child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
//                         ),
//                       )
//                     : Center(child: Icon(Icons.photo, color: Colors.grey[400])),
//               ),
//             ),
//             Positioned(
//               top: 8,
//               right: 8,
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.9),
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 4,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: IconButton(
//                   icon: Icon(
//                     Icons.favorite,
//                     color: Colors.red,
//                     size: 25,
//                   ),
//                   onPressed: () async {
//                     final provider = FavoriteProvider.of(context, listen: false);
//                     final isAlreadyInFavorites = provider.favorites.any((item) => item.id == product['id']);

//                     if (!isAlreadyInFavorites) {
//                       await provider.addToDatabase(product);
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text('${product['name']} ✅ Added to favorites'),
//                           duration: Duration(seconds: 2),
//                         ),
//                       );
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text('${product['name']} Already in favourites'),
//                           duration: Duration(seconds: 2),
//                         ),
//                       );
//                     }
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//           child: Text(
//             product['name'] ?? 'Product Name',
//             style: const TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.bold,
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 6),
//           child: Text(
//             'MAD ${product['price'] ?? '0'}',
//             style: GoogleFonts.montserrat(
//               color: KaccentColor,
//               fontSize: 17,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//       ],
//     ),
//   );
// }
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sayf/constants.dart';
import 'package:sayf/models/product.dart';
import 'package:sayf/provider/favorite_provider.dart';

Widget buildProductCard(BuildContext context, Map<String, dynamic> product) {
  final productObj = Product.fromMap(product); // تحويل الـ Map إلى كائن Product

  return GestureDetector(
    onTap: () {
      // Navigate to product details
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[200],
                child: productObj.image.isNotEmpty
                    ? Image.network(
                        productObj.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
                        ),
                      )
                    : Center(child: Icon(Icons.photo, color: Colors.grey[400])),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 25,
                  ),
                  onPressed: () async {
                    final provider = FavoriteProvider.of(context, listen: false);
                    final isAlreadyInFavorites = provider.favorites.any((item) => item.id == productObj.id);

                    if (!isAlreadyInFavorites) {
                      await provider.addToDatabase(productObj);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.green,
                          content: Text('${productObj.name} Added to favorites'),
                          duration: const Duration(seconds: 2),
                          
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('${productObj.name} Already in favourites'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            productObj.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            'MAD ${productObj.price.toStringAsFixed(2)}',
            style: GoogleFonts.montserrat(
              color: KaccentColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    ),
  );
}
