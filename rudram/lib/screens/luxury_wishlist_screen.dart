import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/cart_provider.dart';

class LuxuryWishlistScreen extends StatelessWidget {
  const LuxuryWishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Consumer<WishlistProvider>(
          builder: (context, wishlist, child) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "YOUR CURATION",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Playfair Display',
                          fontSize: 28,
                        ),
                      ),
                      Text(
                        "${wishlist.items.length} ITEMS",
                        style: TextStyle(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.8),
                          letterSpacing: 2,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: wishlist.items.isEmpty
                      ? const Center(
                          child: Text(
                            "No items in curation.",
                            style: TextStyle(
                              color: Colors.white54,
                              fontFamily: 'Playfair Display',
                              fontSize: 18,
                            ),
                          ),
                        )
                      : GridView.builder(
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: wishlist.items.length,
                          itemBuilder: (context, index) {
                            final product = wishlist.items[index];
                            return Column(
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      Image.network(
                                        product.image,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () {
                                            wishlist.toggleWishlist(product);
                                          },
                                          child: const Icon(
                                            Icons.favorite,
                                            color: Color(0xFFD4AF37),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  product.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Playfair Display',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "₹ ${product.currentPrice}",
                                  style: const TextStyle(color: Color(0xFFD4AF37)),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton(
                                  onPressed: () {
                                    context.read<CartProvider>().addItem(product);
                                    wishlist.removeItem(product);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("${product.title} moved to bag"),
                                        backgroundColor: const Color(0xFFD4AF37),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.grey),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 0,
                                    ),
                                    minimumSize: const Size(0, 32),
                                  ),
                                  child: const Text(
                                    "Move to Bag",
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
