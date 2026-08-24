import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../models/data_models.dart';
import '../../screens/desktop/desktop_product_detail_page.dart';

class DesktopPerfectMatchSection extends StatefulWidget {
  const DesktopPerfectMatchSection({super.key});

  @override
  State<DesktopPerfectMatchSection> createState() =>
      _DesktopPerfectMatchSectionState();
}

class _DesktopPerfectMatchSectionState
    extends State<DesktopPerfectMatchSection> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  final List<ProductItem> products = [
    ProductItem(
      title: "Royal Emerald Diamond Set",
      currentPrice: 85000.00,
      oldPrice: 125000.00,
      discount: "-32%",
      image:
          "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/6a/55/96/6a55960bc89259fa0cc11bf784e1d28c.jpg",
    ),
    ProductItem(
      title: "Sapphire Drop Earrings",
      currentPrice: 42000.00,
      oldPrice: 55000.00,
      discount: "-25%",
      image:
          "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/f4/05/41/f4054166dccbf42baf55d8501074b012.jpg",
    ),
    ProductItem(
      title: "Infinity Gold Bracelet",
      currentPrice: 35000.00,
      oldPrice: 45000.00,
      discount: "-22%",
      image:
          "https://images.weserv.nl/?url=https://i.pinimg.com/736x/c3/8e/3e/c38e3e93d6d993c115314b20274943fa.jpg",
    ),
    ProductItem(
      title: "Classic Solitaire Ring",
      currentPrice: 95000.00,
      oldPrice: 110000.00,
      discount: "-15%",
      image:
          "https://images.weserv.nl/?url=https://i.pinimg.com/736x/0f/5f/1a/0f5f1a0cc6a898a8b23e72fb2b1a087f.jpg",
    ),
    ProductItem(
      title: "Rose Gold Pendant",
      currentPrice: 28000.00,
      oldPrice: 35000.00,
      discount: "-20%",
      image:
          "https://images.weserv.nl/?url=https://i.pinimg.com/736x/36/dc/71/36dc71af1ca7f5c4a8fdfe73bbb688b1.jpg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(bottom: 30, left: 15, right: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Perfect Match for You",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: (Theme.of(context).textTheme.bodyLarge?.color ?? Color(0xFF1E2832)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.stars, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              "AI Recommended",
                              style: TextStyle(
                                color: Theme.of(context).cardColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Curated specially based on your taste in luxury",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildNavButton(
                    icon: Icons.chevron_left,
                    onTap: () => _carouselController.previousPage(),
                  ),
                  const SizedBox(width: 10),
                  _buildNavButton(
                    icon: Icons.chevron_right,
                    onTap: () => _carouselController.nextPage(),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Carousel content
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculate item width based on 5 items per row with 20px spacing (4 gaps = 80px total)
            final double itemWidth = (constraints.maxWidth - 80) / 5;
            // Height = Image height (aspect ratio 1) + Text area (approx 100px + extra buffer)
            final double dynamicHeight = itemWidth + 110;

            return CarouselSlider.builder(
              carouselController: _carouselController,
              itemCount: (products.length / 5).ceil(),
              options: CarouselOptions(
                height: dynamicHeight,
                viewportFraction: 1.0,
                enableInfiniteScroll: true,
                autoPlay: false,
              ),
              itemBuilder: (context, index, realIndex) {
                final int start = index * 5;
                return Row(
                  children: List.generate(5, (i) {
                    final int currentIdx = start + i;
                    if (currentIdx < products.length) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i == 4 ? 0 : 20),
                          child: _MatchCard(product: products[currentIdx]),
                        ),
                      );
                    } else {
                      return const Expanded(child: SizedBox());
                    }
                  }),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon, color: (Theme.of(context).textTheme.bodyLarge?.color ?? Color(0xFF1E2832)), size: 20),
      ),
    );
  }
}

class _MatchCard extends StatefulWidget {
  final ProductItem product;

  const _MatchCard({required this.product});

  @override
  State<_MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<_MatchCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DesktopProductDetailPage(product: widget.product),
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            children: [
              // Image Box
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Image.network(
                        widget.product.image,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(Icons.image_outlined, size: 40),
                            ),
                      ),
                      if (_isHovered)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Product Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  children: [
                    Text(
                      widget.product.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "₹${widget.product.currentPrice.toInt()}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color ?? Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.product.discount,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4F46E5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "₹${widget.product.oldPrice.toInt()}",
                          style: const TextStyle(
                            fontSize: 13,
                            decoration: TextDecoration.lineThrough,
                            color: Color(0xFFBDBDBD),
                          ),
                        ),
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
