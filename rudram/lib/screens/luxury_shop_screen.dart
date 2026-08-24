import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'luxury_product_details_screen.dart';

class LuxuryShopScreen extends StatefulWidget {
  const LuxuryShopScreen({super.key});

  @override
  State<LuxuryShopScreen> createState() => _LuxuryShopScreenState();
}

class _LuxuryShopScreenState extends State<LuxuryShopScreen> {
  final List<String> _categories = [
    "All",
    "Necklaces",
    "Rings",
    "Bridal",
    "Watches",
    "Men's",
  ];
  int _selectedCategory = 0;

  List<Map<String, dynamic>> _allProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('luxury_products')
          .where('active', isEqualTo: true)
          .get();
      
      if (mounted) {
        setState(() {
          _allProducts = snapshot.docs.map((doc) => {
            'id': doc.id,
            ...doc.data(),
          }).toList();
          
          // Sort by order
          _allProducts.sort((a, b) => (a['order'] as num? ?? 0).compareTo(b['order'] as num? ?? 0));
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching luxury products: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> get _filteredProducts {
    if (_selectedCategory == 0) return _allProducts; // 'All' category
    final selectedCatStr = _categories[_selectedCategory];
    return _allProducts.where((p) {
      final pCat = p['category'] as String? ?? '';
      return pCat.toLowerCase() == selectedCatStr.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "THE COLLECTION",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Playfair Display',
                      fontSize: 24,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.tune, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Categories
            SizedBox(
              height: 40,
              child: ListView.builder(
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedCategory == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFD4AF37)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.grey[800]!,
                        ),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Text(
                        _categories[index],
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Products Grid
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
                : _filteredProducts.isEmpty
                  ? const Center(child: Text("No products found in this category", style: TextStyle(color: Colors.white70)))
                  : GridView.builder(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 24,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    LuxuryProductDetailsScreen(product: product),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      product['image'] ?? '',
                                      fit: BoxFit.cover,
                                      cacheWidth: 400, // Optimize memory for web scrolling
                                      errorBuilder: (ctx, err, stack) => Container(color: Colors.grey[900]),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.favorite_border,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                product['title'] ?? 'Luxury Item',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Playfair Display',
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product['price']?.toString() ?? '₹ 0',
                                style: const TextStyle(
                                  color: Color(0xFFD4AF37),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
