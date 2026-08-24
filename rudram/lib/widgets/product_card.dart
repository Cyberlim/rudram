import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/data_models.dart';
import '../providers/wishlist_provider.dart';
import '../screens/product_details_screen.dart';

class ProductCard extends StatelessWidget {
  final ProductItem product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(product: product),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Box
              Expanded(
                child: Container(
                  color: product.bgColor,
                  child: Stack(
                    children: [
                      // Image
                      Positioned.fill(
                        child: product.image.isNotEmpty
                            ? Image.network(
                                    product.image,
                                    fit: BoxFit.cover,
                                    cacheWidth: 400, // Optimize memory for smoother web scrolling
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                                  )
                            : Center(
                                child: Icon(Icons.diamond, size: 50, color: Colors.white.withValues(alpha: 0.9)),
                              ),
                      ),

                      // Discount Badge
                      if (product.discount.isNotEmpty)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              product.discount,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      // Wishlist Icon
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Consumer<WishlistProvider>(
                          builder: (context, wishlist, child) {
                            final isWishlisted = wishlist.isInWishlist(product);
                            return GestureDetector(
                              onTap: () {
                                wishlist.toggleWishlist(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(!isWishlisted ? 'Added to wishlist!' : 'Removed from wishlist!'),
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: !isWishlisted ? Colors.pink : Colors.grey,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                                  size: 16,
                                  color: isWishlisted ? Colors.red : Colors.black54,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Text Details Below
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start, // Align to top
                    children: [
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6), // Replaced Spacer with fixed gap
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              "₹${product.currentPrice.toInt()}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          if (product.oldPrice > 0 && product.oldPrice > product.currentPrice) ...[
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                "₹${product.oldPrice.toInt()}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
