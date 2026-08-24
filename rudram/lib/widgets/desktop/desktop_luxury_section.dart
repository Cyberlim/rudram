import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../utils/app_colors.dart';
import '../../screens/desktop/desktop_luxury_products_page.dart';

class DesktopLuxurySection extends StatefulWidget {
  const DesktopLuxurySection({super.key});

  @override
  State<DesktopLuxurySection> createState() => _DesktopLuxurySectionState();
}

class _DesktopLuxurySectionState extends State<DesktopLuxurySection> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _currentIndex = 0;

  final List<LuxuryItemData> _items = [
    LuxuryItemData(
      image:
          'https://images.weserv.nl/?url=https://i.pinimg.com/736x/54/26/f3/5426f37ee3738c45aa2e07091c6ea709.jpg',
      headline: 'Bridal Heritage\nmeets Modern Fine Art',
      description:
          'Elevate your presence with our most exclusive masterpiece collection. Each piece is handcrafted over hundreds of hours by master artisans, using only the finest ethically sourced diamonds and 22K gold.',
      features: [
        LuxuryFeature(Icons.auto_awesome, "Master Artisan Crafted"),
        LuxuryFeature(Icons.verified_user, "Lifetime Authenticity Guarantee"),
        LuxuryFeature(Icons.diamond, "Certified Pre-Selected Gems"),
      ],
    ),
    LuxuryItemData(
      image:
          'https://images.weserv.nl/?url=https://i.pinimg.com/736x/0f/5f/1a/0f5f1a0cc6a898a8b23e72fb2b1a087f.jpg',
      headline: 'Timeless Elegance\nin Every Sparkle',
      description:
          'Discover the purity of perfect solitaires. Ethically sourced and precisely cut to maximize brilliance. A symbol of everlasting love and sophisticated taste.',
      features: [
        LuxuryFeature(Icons.star_border, "GIA Certified Diamonds"),
        LuxuryFeature(Icons.eco_outlined, "Sustainable Sourcing"),
        LuxuryFeature(Icons.design_services, "Custom Bespoke Design"),
      ],
    ),
    LuxuryItemData(
      image:
          'https://images.weserv.nl/?url=https://i.pinimg.com/1200x/6a/55/96/6a55960bc89259fa0cc11bf784e1d28c.jpg',
      headline: 'Royal Traditions\nReimagined for You',
      description:
          'Intricate temple jewellery designs that tell a story of ancient royalty and divine beauty. Preserving the art of traditional craftsmanship for the modern era.',
      features: [
        LuxuryFeature(Icons.balance, "22K Hallmark Gold"),
        LuxuryFeature(Icons.history_edu, "Antique Finish"),
        LuxuryFeature(Icons.workspace_premium, "Heirloom Quality"),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxWidth < 1000;
        final double sectionHeight = isSmallScreen ? 1100 : 760;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Column(
            children: [
              CarouselSlider.builder(
                carouselController: _controller,
                itemCount: _items.length,
                options: CarouselOptions(
                  height: sectionHeight,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 6),
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                itemBuilder: (context, index, realIndex) {
                  return _buildLuxuryItem(
                    context,
                    _items[index],
                    isSmallScreen,
                  );
                },
              ),
              // Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _items.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => _controller.animateToPage(entry.key),
                    child: Container(
                      width: 12.0,
                      height: 12.0,
                      margin: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 4.0,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black)
                                .withOpacity(
                                  _currentIndex == entry.key ? 0.9 : 0.4,
                                ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLuxuryItem(
    BuildContext context,
    LuxuryItemData item,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 40 : 80,
        horizontal: isSmallScreen ? 20 : 80,
      ),
      child: isSmallScreen
          ? Column(
              children: [
                // Image Top
                SizedBox(
                  height: 400,
                  width: double.infinity,
                  child: _LuxuryImage(imageUrl: item.image),
                ),
                const SizedBox(height: 40),
                // Content Bottom
                _LuxuryContent(item: item),
              ],
            )
          : Row(
              children: [
                // Image Left
                Expanded(
                  flex: 6,
                  child: SizedBox(
                    height: 600,
                    child: _LuxuryImage(imageUrl: item.image),
                  ),
                ),
                const SizedBox(width: 80),
                // Content Right
                Expanded(flex: 5, child: _LuxuryContent(item: item)),
              ],
            ),
    );
  }
}

class _LuxuryImage extends StatefulWidget {
  final String imageUrl;
  const _LuxuryImage({required this.imageUrl});

  @override
  State<_LuxuryImage> createState() => _LuxuryImageState();
}

class _LuxuryImageState extends State<_LuxuryImage> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutQuart,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.25 : 0.1),
              blurRadius: _isHovered ? 40 : 20,
              offset: Offset(0, _isHovered ? 20 : 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Main Image
              AnimatedScale(
                duration: const Duration(milliseconds: 1000),
                scale: _isHovered ? 1.05 : 1.0,
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 80),
                  ),
                ),
              ),

              // Elegant Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                  ),
                ),
              ),

              // Rare Badge
              Positioned(
                top: 30,
                left: 30,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Text(
                    "RARE COLLECTION",
                    style: TextStyle(
                      color: (Theme.of(context).textTheme.bodyLarge?.color ?? Color(0xFF1E2832)),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LuxuryContent extends StatelessWidget {
  final LuxuryItemData item;
  const _LuxuryContent({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'THE LUXURY EXPERIENCE',
          style: TextStyle(
            color: AppColors.primaryOrange,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          item.headline,
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.bold,
            color: (Theme.of(context).textTheme.bodyLarge?.color ?? Color(0xFF1E2832)),
            height: 1.1,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          item.description,
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[700],
            height: 1.7,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 30),

        // Feature List
        ...item.features.map(
          (f) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildLuxuryFeature(
              context, f.icon, f.text),
          ),
        ),

        const SizedBox(height: 30),

        Wrap(
          spacing: 25,
          runSpacing: 20,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DesktopLuxuryProductsPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: (Theme.of(context).textTheme.bodyLarge?.color ?? Color(0xFF1E2832)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 45,
                  vertical: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: Text(
                'EXPLORE ELITE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLuxuryFeature(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryOrange.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryOrange, size: 20),
        ),
        const SizedBox(width: 15),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: (Theme.of(context).textTheme.bodyLarge?.color ?? Color(0xFF1E2832)),
          ),
        ),
      ],
    );
  }
}

class LuxuryItemData {
  final String image;
  final String headline;
  final String description;
  final List<LuxuryFeature> features;

  LuxuryItemData({
    required this.image,
    required this.headline,
    required this.description,
    required this.features,
  });
}

class LuxuryFeature {
  final IconData icon;
  final String text;

  LuxuryFeature(this.icon, this.text);
}
