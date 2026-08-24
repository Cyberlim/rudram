import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../utils/app_colors.dart';

class ShopByOccasionSection extends StatefulWidget {
  const ShopByOccasionSection({super.key});

  @override
  State<ShopByOccasionSection> createState() => _ShopByOccasionSectionState();
}

class _ShopByOccasionSectionState extends State<ShopByOccasionSection> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _current = 0;

  final occasions = [
    {
      'title': 'Wedding',
      'icon': Icons.favorite,
      'image':
          'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=400',
      'color': const Color(0xFFFFE4E1),
    },
    {
      'title': 'Anniversary',
      'icon': Icons.cake,
      'image':
          'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=400',
      'color': const Color(0xFFE6E6FA),
    },
    {
      'title': 'Birthday',
      'icon': Icons.celebration,
      'image':
          'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=400',
      'color': const Color(0xFFFFF0F5),
    },
    {
      'title': 'Festive',
      'icon': Icons.auto_awesome,
      'image':
          'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=400',
      'color': const Color(0xFFFFEFD5),
    },
    {
      'title': 'Casual',
      'icon': Icons.local_cafe,
      'image':
          'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=400',
      'color': const Color(0xFFE0F7FA),
    },
    {
      'title': 'Formal',
      'icon': Icons.business_center,
      'image':
          'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=400',
      'color': const Color(0xFFFFF9C4),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Shop by Occasion",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, size: 18),
                    onPressed: () => _carouselController.previousPage(),
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios, size: 18),
                    onPressed: () => _carouselController.nextPage(),
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Carousel
        CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: occasions.length,
          options: CarouselOptions(
            height: 200,
            viewportFraction: 0.45,
            enableInfiniteScroll: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            enlargeFactor: 0.2,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
          itemBuilder: (context, index, realIndex) {
            final occasion = occasions[index];
            return _buildOccasionCard(occasion);
          },
        ),

        const SizedBox(height: 16),

        // Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: occasions.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _carouselController.animateToPage(entry.key),
              child: Container(
                width: _current == entry.key ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _current == entry.key
                      ? AppColors.primaryOrange
                      : Colors.grey.shade300,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOccasionCard(Map<String, dynamic> occasion) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              occasion['image'] as String,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: occasion['color'] as Color);
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    occasion['icon'] as IconData,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    occasion['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
