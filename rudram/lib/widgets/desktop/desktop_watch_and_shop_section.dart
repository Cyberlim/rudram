import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../screens/reels_screen.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:carousel_slider/carousel_slider.dart';

class DesktopWatchAndShopSection extends StatelessWidget {
  const DesktopWatchAndShopSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Using the same video URLs from ReelsScreen/WatchAndShopSection
    final reels = [
      {
        'title': 'LISA Bulgari Mediterranea',
        'time': '00:45',
        'videoUrl':
            'https://res.cloudinary.com/ds1wiqrdb/video/upload/v1765563533/LISA_Bulgari_Mediterranea_High_Jewelry_Collection_lnh1ks.mp4',
        'thumbnail':
            'https://res.cloudinary.com/ds1wiqrdb/video/upload/so_0.0/v1765563533/LISA_Bulgari_Mediterranea_High_Jewelry_Collection_lnh1ks.jpg',
      },
      {
        'title': 'Tanishq Diamonds Collection',
        'time': '01:15',
        'videoUrl':
            'https://res.cloudinary.com/ds1wiqrdb/video/upload/v1765563533/Tanishq_Diamonds_Where_Rarity_Meets_Radiance_ruhfu7.mp4',
        'thumbnail':
            'https://res.cloudinary.com/ds1wiqrdb/video/upload/so_0.0/v1765563533/Tanishq_Diamonds_Where_Rarity_Meets_Radiance_ruhfu7.jpg',
      },
      {
        'title': 'Trending Gold Jhumka',
        'time': '00:30',
        'videoUrl':
            'https://res.cloudinary.com/ds1wiqrdb/video/upload/v1765714763/TOP_TRENDING_GOLD_JEWELLERY_EARRINGS_JHUMKA_DESIGN_goldjewellery_jewelry_gold_jewellery_22k_okoq9c.mp4',
        'thumbnail':
            'https://res.cloudinary.com/ds1wiqrdb/video/upload/so_0.0/v1765714763/TOP_TRENDING_GOLD_JEWELLERY_EARRINGS_JHUMKA_DESIGN_goldjewellery_jewelry_gold_jewellery_22k_okoq9c.jpg',
      },
      {
        'title': 'Timeless Kasumala Collection',
        'time': '00:45',
        'videoUrl':
            'https://res.cloudinary.com/ds1wiqrdb/video/upload/v1765714699/The_Timeless_Kasumala_Collection_Rivaah_Wedding_Jewellery_by_Tanishq_ajmdjv.mp4',
        'thumbnail':
            'https://res.cloudinary.com/ds1wiqrdb/video/upload/so_0.0/v1765714699/The_Timeless_Kasumala_Collection_Rivaah_Wedding_Jewellery_by_Tanishq_ajmdjv.jpg',
      },
      {
        'title': 'Anne Hathaway Bulgari',
        'time': '00:50',
        'videoUrl':
            'https://res.cloudinary.com/ds1wiqrdb/video/upload/v1765714691/Anne_Hathaway_Bulgari_Mediterranea_High_Jewelry_Collection_wcgszq.mp4',
        'thumbnail':
            'https://res.cloudinary.com/ds1wiqrdb/video/upload/so_0.0/v1765714691/Anne_Hathaway_Bulgari_Mediterranea_High_Jewelry_Collection_wcgszq.jpg',
      },
      {
        'title': 'Zendaya Bulgari Collection',
        'time': '00:40',
        'videoUrl':
            'https://res.cloudinary.com/ds1wiqrdb/video/upload/v1765714564/Zendaya_Bulgari_Mediterranea_High_Jewelry_Collection_jbwa8d.mp4',
        'thumbnail':
            'https://res.cloudinary.com/ds1wiqrdb/video/upload/so_0.0/v1765714564/Zendaya_Bulgari_Mediterranea_High_Jewelry_Collection_jbwa8d.jpg',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_circle_fill,
                      color: AppColors.primaryOrange,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    "Watch & Shop",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: (Theme.of(context).textTheme.bodyLarge?.color ?? Color(0xFF1E2832)),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReelsScreen(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      "See all",
                      style: TextStyle(
                        color: AppColors.primaryOrange,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.primaryOrange,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 500, // Increased height as requested
          child: CarouselSlider.builder(
            itemCount: reels.length,
            options: CarouselOptions(
              height: 500,
              viewportFraction: 0.2, // Show 5 items at once (1/0.2 = 5)
              enableInfiniteScroll: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              scrollPhysics: const BouncingScrollPhysics(),
            ),
            itemBuilder: (context, index, realIndex) {
              final reel = reels[index];
              return _DesktopVideoCard(reel: reel);
            },
          ),
        ),
      ],
    );
  }
}

class _DesktopVideoCard extends StatefulWidget {
  final Map<String, String> reel;
  const _DesktopVideoCard({required this.reel});

  @override
  State<_DesktopVideoCard> createState() => _DesktopVideoCardState();
}

class _DesktopVideoCardState extends State<_DesktopVideoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReelsScreen()),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          // Width removed to adapt to Carousel viewportFraction
          margin: const EdgeInsets.only(right: 20, bottom: 20),
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -10.0 : 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.3 : 0.15),
                blurRadius: _isHovered ? 20 : 10,
                offset: Offset(0, _isHovered ? 15 : 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  widget.reel['thumbnail']!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: Colors.grey[900]);
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),

                // Play Button
                Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.all(_isHovered ? 16 : 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Theme.of(context).cardColor,
                      size: 32,
                    ),
                  ),
                ),

                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.reel['time']!,
                          style: TextStyle(
                            color: Theme.of(context).cardColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.reel['title']!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).cardColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
