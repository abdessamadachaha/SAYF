import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sayf/constants.dart';
import 'package:sayf/models/product.dart';
import 'package:sayf/provider/favorite_provider.dart';
import 'package:sayf/views/product_page.dart';

Widget buildProductCard(BuildContext context, Map<String, dynamic> product) {
  final productObj = Product.fromMap(product);
  final provider = FavoriteProvider.of(context);
  final bool isFavorite = provider.favorites.any((item) => item.id == productObj.id);

  return GestureDetector(
    onTap: () {
       Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductPage(
           product: productObj,
          ),
        ),
      );
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
                child: StatefulBuilder(
                  builder: (context, setStateFav) => IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color: isFavorite ? Colors.red : const Color.fromARGB(255, 193, 192, 192),
                      size: 25,
                    ),
                    onPressed: () async {
                      final provider = FavoriteProvider.of(context, listen: false);

                      if (isFavorite) {
                        await provider.removeFromDatabase(productObj);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('${productObj.name} removed from favorites'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      } else {
                        await provider.addToDatabase(productObj);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text('${productObj.name} added to favorites'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }

                      setStateFav(() {});
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            productObj.name,
            style: GoogleFonts.poppins(
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
            style: GoogleFonts.poppins(
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
