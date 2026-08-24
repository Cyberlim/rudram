import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/data_models.dart';

class QuickViewDialog extends StatefulWidget {
  final ProductItem product;

  const QuickViewDialog({super.key, required this.product});

  @override
  State<QuickViewDialog> createState() => _QuickViewDialogState();
}

class _QuickViewDialogState extends State<QuickViewDialog> {
  int _currentProductIndex = 0;
  int _selectedTab = 0;
  int _selectedImageIndex = 0;

  // Mock related products
  late List<ProductItem> _relatedProducts;

  // Mock gallery images
  late List<String> _galleryImages;

  @override
  void initState() {
    super.initState();

    // Initialize gallery images
    _galleryImages = [
      widget.product.image,
      widget.product.image, // In real app, these would be different images
      widget.product.image,
      widget.product.image,
    ];

    // Generate mock related products
    _relatedProducts = [
      widget.product,
      ProductItem(
        title: "Nike Air Zoom Pegasus",
        currentPrice: 8999.00,
        oldPrice: 12999.00,
        discount: "-30%",
        image:
            "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500",
        bgColor: const Color(0xFFF5F5F5),
      ),
      ProductItem(
        title: "Adidas Ultraboost",
        currentPrice: 15999.00,
        oldPrice: 18999.00,
        discount: "-15%",
        image:
            "https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=500",
        bgColor: const Color(0xFFF5F5F5),
      ),
      ProductItem(
        title: "Puma RS-X",
        currentPrice: 7499.00,
        oldPrice: 9999.00,
        discount: "-25%",
        image:
            "https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=500",
        bgColor: const Color(0xFFF5F5F5),
      ),
    ];
  }

  void _navigateToProduct(int index) {
    if (index >= 0 && index < _relatedProducts.length) {
      setState(() {
        _currentProductIndex = index;
        _selectedImageIndex = 0;
        // Update gallery images for new product
        _galleryImages = [
          _relatedProducts[index].image,
          _relatedProducts[index].image,
          _relatedProducts[index].image,
          _relatedProducts[index].image,
        ];
      });
    }
  }

  ProductItem get _currentProduct => _relatedProducts[_currentProductIndex];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1400, maxHeight: 800),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 50,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey.shade800.withOpacity(0.95),
                        Colors.grey.shade900.withOpacity(0.95),
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              Row(
                children: [
                  // Left: Related Products Sidebar
                  _buildRelatedProductsSidebar()
                      .animate()
                      .slideX(begin: -0.3, duration: 600.ms)
                      .fadeIn(duration: 500.ms),

                  // Center & Right: Gallery, Details, and Tabs
                  Expanded(
                    child: _buildCenterContent()
                        .animate(key: ValueKey(_currentProductIndex))
                        .fadeIn(duration: 300.ms)
                        .scale(
                          begin: const Offset(0.95, 0.95),
                          duration: 400.ms,
                        ),
                  ),
                ],
              ),

              // Close button
              Positioned(
                top: 20,
                right: 20,
                child:
                    IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 28,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.5),
                            shape: const CircleBorder(),
                          ),
                        )
                        .animate()
                        .scale(
                          begin: const Offset(0, 0),
                          delay: 300.ms,
                          duration: 400.ms,
                        )
                        .fadeIn(delay: 300.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelatedProductsSidebar() {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "RELATED",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${_currentProductIndex + 1} / ${_relatedProducts.length}",
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _relatedProducts.length,
              itemBuilder: (context, index) {
                final isSelected = index == _currentProductIndex;
                return GestureDetector(
                  onTap: () => _navigateToProduct(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE91E63).withOpacity(0.3)
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFE91E63)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _relatedProducts[index].image,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterContent() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          // Product Title
          Text(
            _currentProduct.title.toUpperCase(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 30),

          // Gallery Section
          Expanded(
            child: Row(
              children: [
                // Thumbnail column
                Container(
                  width: 100,
                  child: ListView.builder(
                    itemCount: _galleryImages.length,
                    itemBuilder: (context, index) {
                      final isSelected = index == _selectedImageIndex;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedImageIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFE91E63)
                                  : Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _galleryImages[index],
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 20),

                // Main image with navigation
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      // Main image
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withOpacity(0.05),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child:
                              Image.network(
                                    _galleryImages[_selectedImageIndex],
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                  )
                                  .animate(key: ValueKey(_selectedImageIndex))
                                  .fadeIn(duration: 200.ms)
                                  .scale(
                                    begin: const Offset(0.95, 0.95),
                                    duration: 300.ms,
                                  ),
                        ),
                      ),

                      // Navigation arrows
                      if (_currentProductIndex > 0)
                        Positioned(
                          left: 10,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: IconButton(
                              onPressed: () =>
                                  _navigateToProduct(_currentProductIndex - 1),
                              icon: const Icon(
                                Icons.chevron_left,
                                color: Colors.white,
                                size: 32,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black.withOpacity(0.5),
                                shape: const CircleBorder(),
                              ),
                            ),
                          ),
                        ),

                      if (_currentProductIndex < _relatedProducts.length - 1)
                        Positioned(
                          right: 10,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: IconButton(
                              onPressed: () =>
                                  _navigateToProduct(_currentProductIndex + 1),
                              icon: const Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                                size: 32,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black.withOpacity(0.5),
                                shape: const CircleBorder(),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                // Tabs Section
                Expanded(child: _buildTabsSection()),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Pricing and CTA in Center
          _buildPricingSection(),
        ],
      ),
    );
  }

  Widget _buildTabsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tabs
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTab("Details", 0),
              _buildTab("Reviews", 1),
              _buildTab("Features", 2),
              _buildTab("Description", 3),
            ],
          ),

          const SizedBox(height: 20),

          // Tab content
          Expanded(
            child: SingleChildScrollView(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildTabContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE91E63)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0: // Details
        return Column(
          key: const ValueKey(0),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Brand", "Premium"),
            _buildDetailRow("Model", _currentProduct.title),
            _buildDetailRow("Color", "Multi-Color"),
            _buildDetailRow("Material", "Premium Quality"),
            _buildDetailRow("Stock", "In Stock"),
          ],
        );
      case 1: // Reviews
        return Column(
          key: const ValueKey(1),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 18),
                const Icon(Icons.star, color: Colors.orange, size: 18),
                const Icon(Icons.star, color: Colors.orange, size: 18),
                const Icon(Icons.star, color: Colors.orange, size: 18),
                const Icon(Icons.star_half, color: Colors.orange, size: 18),
                const SizedBox(width: 8),
                Text(
                  "4.5/5.0",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Based on 1,234+ reviews",
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "\"Excellent product! Highly recommended for anyone looking for quality.\"",
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        );
      case 2: // Features
        return Column(
          key: const ValueKey(2),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeatureItem("✓ Premium quality materials"),
            _buildFeatureItem("✓ Durable and long-lasting"),
            _buildFeatureItem("✓ Modern design"),
            _buildFeatureItem("✓ Easy to maintain"),
            _buildFeatureItem("✓ Satisfaction guaranteed"),
          ],
        );
      case 3: // Description
        return Text(
          key: const ValueKey(3),
          "${_currentProduct.title} is crafted with premium materials and attention to detail. Perfect for those who appreciate quality and style. This product combines functionality with aesthetic appeal, making it a perfect addition to your collection.",
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 13,
            height: 1.6,
          ),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        feature,
        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
      ),
    );
  }

  Widget _buildPricingSection() {
    return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFE91E63).withOpacity(0.2),
                const Color(0xFF9C27B0).withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE91E63).withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Pricing
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "PRICE",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "₹${_currentProduct.currentPrice.toStringAsFixed(0)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "₹${_currentProduct.oldPrice.toStringAsFixed(0)}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 16,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE91E63),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _currentProduct.discount,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              // CTA Buttons
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.favorite_border),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text("ADD TO CART"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .slideY(begin: 0.3, delay: 400.ms, duration: 500.ms)
        .fadeIn(delay: 400.ms);
  }
}

void showQuickViewDialog(BuildContext context, ProductItem product) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Quick View",
    barrierColor: Colors.black.withOpacity(0.7),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) {
      return QuickViewDialog(product: product);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: child,
        ),
      );
    },
  );
}
