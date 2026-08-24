import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class DesktopHeroSection extends StatefulWidget {
  const DesktopHeroSection({super.key});

  @override
  State<DesktopHeroSection> createState() => _DesktopHeroSectionState();
}

class _DesktopHeroSectionState extends State<DesktopHeroSection>
    with TickerProviderStateMixin {
  int _currentSlide = 0;
  late AnimationController _cardAnimationController;
  final List<bool> _isCardHovered = [false, false, false, false];

  final List<Map<String, dynamic>> _carouselItems = [
    {
      'image':
          'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766772771/Gemini_Generated_Image_fc6eesfc6eesfc6e_p6vjtu.png',
    },
    {
      'image':
          'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766772766/Gemini_Generated_Image_6v06r16v06r16v06_hky38x.png',
    },
    {
      'image':
          'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766772769/Gemini_Generated_Image_6wnqjh6wnqjh6wnq_prum6f.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate dimensions to ensure equal height
          // Width available for the row (taking into account the container padding is handled by LayoutBuilder constraints if placed correctly,
          // but here LayoutBuilder is CHILD of Container, so constraints.maxWidth IS the available width inside padding)
          final availableWidth = constraints.maxWidth;

          // Row has spacing of 10 and 10. Total 20.
          // Flex: 60 (Left), 20 (Mid), 20 (Right)

          const double gap = 10.0;
          final double rightColWidth = (availableWidth - (2 * gap)) * 0.20;

          // Right column has 2 cards vertically with spacing 10
          // Each card has aspect ratio 1.3
          final double cardHeight = rightColWidth / 1.3;
          final double totalHeight = (cardHeight * 2) + 10.0;

          return SizedBox(
            height: totalHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left - Main Banner Carousel (60% width)
                Expanded(
                  flex: 60,
                  child: _buildMainBanner(height: totalHeight),
                ),

                const SizedBox(width: 10),
                // Right - Column 1 (20% width)
                Expanded(
                  flex: 20,
                  child: Column(
                    children: [
                      Expanded(
                        child: _buildEnhancedCard(
                          index: 0,
                          imageUrl: '',
                          bgImageUrl:
                              'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766773995/8512716e33d20cac2f4019e1a59ce41f_kuyugk.jpg',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: _buildEnhancedCard(
                          index: 1,
                          imageUrl: '',
                          bgImageUrl:
                              'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766773994/8f2249c31350c4cb0f69dd74de9f8878_ztxcyd.jpg',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),
                // Right - Column 2 (20% width)
                Expanded(
                  flex: 20,
                  child: Column(
                    children: [
                      Expanded(
                        child: _buildEnhancedCard(
                          index: 2,
                          imageUrl: '',
                          bgImageUrl:
                              'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766773994/d9d4b96415c4c99a2cd17c53e1e15fde_efwks7.jpg',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: _buildEnhancedCard(
                          index: 3,
                          imageUrl: '',
                          bgImageUrl:
                              'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766773994/97ce300ef56c4bcee8f351a3a037916f_bbqex9.jpg',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedCard({
    required int index,
    required String imageUrl,
    String? bgImageUrl,
  }) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isCardHovered[index] = true),
      onExit: (_) => setState(() => _isCardHovered[index] = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()
          ..translate(0.0, _isCardHovered[index] ? -8.0 : 0.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 
                _isCardHovered[index] ? 0.15 : 0.05,
              ),
              blurRadius: _isCardHovered[index] ? 20 : 10,
              offset: Offset(0, _isCardHovered[index] ? 10 : 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (bgImageUrl != null)
              Positioned.fill(
                child: bgImageUrl.startsWith('http')
                    ? Image.network(bgImageUrl, fit: BoxFit.cover)
                    : Image.asset(bgImageUrl, fit: BoxFit.cover),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              top: 0,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 300),
                scale: _isCardHovered[index] ? 1.05 : 1.0,
                child: imageUrl.isEmpty
                    ? const SizedBox()
                    : imageUrl.startsWith('http')
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(),
                      )
                    : Image.asset(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainBanner({required double height}) {
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: height,
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.easeInOutCubic,
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              setState(() => _currentSlide = index);
            },
          ),
          items: _carouselItems.map((item) {
            return TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.95 + (value * 0.05),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: item['image'].startsWith('http')
                          ? Image.network(
                              item['image'],
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF4F46E5),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(Icons.image_outlined, size: 40),
                                  ),
                            )
                          : Image.asset(
                              item['image'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox(),
                            ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        // Enhanced Indicators
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_carouselItems.length, (index) {
              final isActive = _currentSlide == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: isActive ? 32 : 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Theme.of(context).cardColor.withValues(alpha: 0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// Custom painter for dot pattern background
class DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    const dotRadius = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CategoryItem {
  final String name;
  final IconData icon;
  final Color color;

  CategoryItem(this.name, this.icon, this.color);
}
