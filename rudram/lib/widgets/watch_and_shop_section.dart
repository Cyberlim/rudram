import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../screens/reels_screen.dart';

class WatchAndShopSection extends StatelessWidget {
  const WatchAndShopSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Using the same video URLs from ReelsScreen
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.play_circle_fill,
                    color: AppColors.primaryOrange,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Watch & Shop",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
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
                child: const Text(
                  "See all",
                  style: TextStyle(
                    color: AppColors.primaryOrange,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 234, // Height for vertical video cards
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 16),
            scrollDirection: Axis.horizontal,
            // Infinite scroll using modulo
            itemCount: 100, // Large number for infinite feel
            itemBuilder: (context, index) {
              // Use modulo to cycle through reels infinitely
              final reel = reels[index % reels.length];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReelsScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
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
                          reel['thumbnail']!,
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
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  reel['time']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                reel['title']!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
