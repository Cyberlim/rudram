import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'reels_screen.dart';

class WatchAndShopScreen extends StatelessWidget {
  const WatchAndShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // All 6 actual reels with their data
    final List<ReelData> allReels = [
      ReelData(
        title: 'LISA Bulgari Mediterranea',
        thumbnail:
            'https://res.cloudinary.com/ds1wiqrdb/video/upload/so_0.0/v1765563533/LISA_Bulgari_Mediterranea_High_Jewelry_Collection_lnh1ks.jpg',
        index: 0,
      ),
      ReelData(
        title: 'Tanishq Diamonds Collection',
        thumbnail:
            'https://res.cloudinary.com/ds1wiqrdb/video/upload/so_0.0/v1765563533/Tanishq_Diamonds_Where_Rarity_Meets_Radiance_ruhfu7.jpg',
        index: 1,
      ),
      ReelData(
        title: 'Trending Gold Jhumka',
        thumbnail:
            'https://res.cloudinary.com/ds1wiqrdb/video/upload/so_0.0/v1765714763/TOP_TRENDING_GOLD_JEWELLERY_EARRINGS_JHUMKA_DESIGN_goldjewellery_jewelry_gold_jewellery_22k_okoq9c.jpg',
        index: 2,
      ),
      ReelData(
        title: 'Timeless Kasumala Collection',
        thumbnail:
            'https://res.cloudinary.com/ds1wiqrdb/video/upload/so_0.0/v1765714699/The_Timeless_Kasumala_Collection_Rivaah_Wedding_Jewellery_by_Tanishq_ajmdjv.jpg',
        index: 3,
      ),
      ReelData(
        title: 'Anne Hathaway Bulgari',
        thumbnail:
            'https://res.cloudinary.com/ds1wiqrdb/video/upload/so_0.0/v1765714691/Anne_Hathaway_Bulgari_Mediterranea_High_Jewelry_Collection_wcgszq.jpg',
        index: 4,
      ),
      ReelData(
        title: 'Zendaya Bulgari Collection',
        thumbnail:
            'https://res.cloudinary.com/ds1wiqrdb/video/upload/so_0.0/v1765714564/Zendaya_Bulgari_Mediterranea_High_Jewelry_Collection_jbwa8d.jpg',
        index: 5,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Watch & Shop",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Text(
                "Video Collections",
                style: TextStyle(
                  fontSize: 28,
                  fontFamily: 'Playfair Display',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            _buildReelCarousel(
              context,
              "Featured Reels",
              allReels.sublist(0, 3),
            ),

            const SizedBox(height: 32),
            _buildReelCarousel(
              context,
              "Celebrity Picks",
              allReels.sublist(3, 6),
            ),

            const SizedBox(height: 32),
            _buildReelCarousel(context, "All Reels", allReels),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildReelCarousel(
    BuildContext context,
    String title,
    List<ReelData> reels,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: reels.length,
            itemBuilder: (context, index) {
              final reel = reels[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ReelsScreen(initialIndex: reel.index),
                    ),
                  );
                },
                child: Container(
                  width: 180,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          reel.thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: Colors.grey[300]),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 12,
                          right: 12,
                          child: Text(
                            reel.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Positioned(
                          top: 10,
                          right: 10,
                          child: Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 32,
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

class ReelData {
  final String title;
  final String thumbnail;
  final int index;

  ReelData({required this.title, required this.thumbnail, required this.index});
}
