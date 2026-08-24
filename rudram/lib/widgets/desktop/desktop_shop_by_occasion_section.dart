import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class DesktopShopByOccasionSection extends StatefulWidget {
  const DesktopShopByOccasionSection({super.key});

  @override
  State<DesktopShopByOccasionSection> createState() =>
      _DesktopShopByOccasionSectionState();
}

class _DesktopShopByOccasionSectionState
    extends State<DesktopShopByOccasionSection> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _current = 0;

  final List<Map<String, String>> occasions = [
    {
      'title': 'Wedding Bliss',
      'subtitle': 'Timeless jewelry for your most precious day',
      'image':
          'https://images.weserv.nl/?url=https://i.pinimg.com/736x/c2/26/c5/c226c52a37a7bdc54e3e2d7198e63d38.jpg',
      'fallback':
          'https://images.unsplash.com/photo-1519741497674-611481863552?w=600',
    },
    {
      'title': 'Office Elegance',
      'subtitle': 'Sophisticated pieces for the modern professional',
      'image':
          'https://images.weserv.nl/?url=https://i.pinimg.com/736x/32/18/5a/32185add0e18326767babc35989ca597.jpg',
      'fallback':
          'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=600',
    },
    {
      'title': 'Festive Glamour',
      'subtitle': 'Sparkle bright at every celebration',
      'image':
          'https://images.weserv.nl/?url=https://i.pinimg.com/736x/e9/f2/9b/e9f29b0d985c7ca6b6f20511208c70ba.jpg',
      'fallback':
          'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=600',
    },
    {
      'title': 'Daily Radiance',
      'subtitle': 'Effortless styles for everyday shine',
      'image':
          'https://images.weserv.nl/?url=https://i.pinimg.com/736x/61/33/01/613301a1c0d852afbc11ebdd05378ffa.jpg',
      'fallback':
          'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=600',
    },
    {
      'title': 'Romantic Evenings',
      'subtitle': 'Captivating pieces for a night to remember',
      'image':
          'https://images.weserv.nl/?url=https://i.pinimg.com/736x/4f/85/0a/4f850a1ee846ce2aed611b34af7936e0.jpg',
      'fallback':
          'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=600',
    },
    {
      'title': 'Special Celebrations',
      'subtitle': 'Celebrate life milestones with elegance',
      'image':
          'https://images.weserv.nl/?url=https://i.pinimg.com/736x/7c/e0/1a/7ce01ad769397f179b6285de920fe351.jpg',
      'fallback':
          'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=600',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 10),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Shop by Occasion",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: (Theme.of(context).textTheme.bodyLarge?.color ?? Color(0xFF1E2832)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Find the perfect jewelry for every moment",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
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

          // Carousel showing 4 items at once
          CarouselSlider.builder(
            carouselController: _carouselController,
            itemCount: (occasions.length / 4).ceil(),
            options: CarouselOptions(
              height: 450,
              viewportFraction: 1.0,
              enableInfiniteScroll: true,
              autoPlay: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              },
            ),
            itemBuilder: (context, pageIndex, realIndex) {
              final startIdx = pageIndex * 4;
              final itemsInPage = <Map<String, String>>[];

              for (int i = 0; i < 4 && startIdx + i < occasions.length; i++) {
                itemsInPage.add(occasions[startIdx + i]);
              }

              return Row(
                children: [
                  ...itemsInPage.map((occasion) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: _OccasionCard(occasion: occasion),
                      ),
                    );
                  }),
                  // Spacer for last page if items < 4
                  if (itemsInPage.length < 4)
                    ...List.generate(
                      4 - itemsInPage.length,
                      (index) => const Expanded(child: SizedBox()),
                    ),
                ],
              );
            },
          ),

          const SizedBox(height: 30),

          // Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate((occasions.length / 4).ceil(), (index) {
              return GestureDetector(
                onTap: () => _carouselController.animateToPage(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _current == index ? 32 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _current == index
                        ? const Color(0xFF4F46E5)
                        : Colors.grey.shade300,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
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

class _OccasionCard extends StatefulWidget {
  final Map<String, String> occasion;

  const _OccasionCard({required this.occasion});

  @override
  State<_OccasionCard> createState() => _OccasionCardState();
}

class _OccasionCardState extends State<_OccasionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -15.0 : 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.15 : 0.05),
              blurRadius: _isHovered ? 30 : 15,
              offset: Offset(0, _isHovered ? 20 : 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              Image.network(
                widget.occasion['image']!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(
                    widget.occasion['fallback']!,
                    fit: BoxFit.cover,
                  );
                },
              ),

              // Gradient Overlay
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: _isHovered ? 0.75 : 0.4),
                    ],
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.occasion['title']!,
                      style: TextStyle(
                        color: Theme.of(context).cardColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _isHovered ? 1.0 : 0.8,
                      child: Text(
                        widget.occasion['subtitle']!,
                        style: TextStyle(
                          color: Theme.of(context).cardColor.withValues(alpha: 0.9),
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildExploreButton(),
                  ],
                ),
              ),

              // Tap Effect
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  splashColor: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExploreButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isHovered ? 120 : 0,
      height: 36,
      child: _isHovered
          ? ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                foregroundColor: Colors.black,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              child: const Text(
                "EXPLORE",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 1.0,
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
