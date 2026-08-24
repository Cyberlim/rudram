import 'package:flutter/material.dart';
import '../../widgets/desktop/desktop_header.dart';
import '../../widgets/desktop/desktop_hero_section.dart';
import '../../widgets/desktop/desktop_flash_sale_section.dart';
import '../../widgets/desktop/desktop_new_arrivals_section.dart';
import '../../widgets/desktop/desktop_best_sellers_section.dart';
import '../../widgets/desktop/desktop_trending_now_section.dart';
import '../../widgets/desktop/desktop_exclusive_offers_section.dart';
import '../../widgets/desktop/desktop_shop_by_occasion_section.dart';
import '../../widgets/desktop/desktop_perfect_match_section.dart';
import '../../widgets/desktop/desktop_luxury_section.dart';
import '../../widgets/desktop/desktop_watch_shop_section.dart';
import '../../widgets/desktop/desktop_blog_section.dart';
import '../../widgets/desktop/desktop_insta_family_section.dart';
import '../../widgets/desktop/desktop_all_products_section.dart';
import '../../widgets/desktop/desktop_our_features_section.dart';
import '../../widgets/desktop/desktop_temple_jewellery_section.dart';
import '../../widgets/desktop/desktop_celebrity_style_section.dart';
import '../../widgets/desktop/desktop_categories_section.dart';
import '../../widgets/desktop/desktop_watch_and_shop_section.dart';
import '../../widgets/desktop/desktop_marquee_section.dart';
import '../../widgets/desktop/desktop_footer_section.dart';

class DesktopHomeScreen extends StatefulWidget {
  const DesktopHomeScreen({super.key});

  @override
  State<DesktopHomeScreen> createState() => _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends State<DesktopHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header (Full Width)
            const DesktopHeader(),

            // 2. Hero Section (Full Width)
            const DesktopHeroSection(),

            // 2.5 Categories Section
            const DesktopCategoriesSection(),

            const SizedBox(height: 20),

            // Other Sections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const DesktopFlashSaleSection(),
                  const SizedBox(height: 30),
                  const DesktopNewArrivalsSection(),
                  const SizedBox(height: 30),
                  const DesktopBestSellersSection(),
                  const SizedBox(height: 30),
                  const DesktopMarqueeSection(),
                  const SizedBox(height: 30),
                  const DesktopTrendingNowSection(),
                  const SizedBox(height: 10), // Reduced gap
                  const DesktopExclusiveOffersSection(),
                  const SizedBox(height: 30),
                  const DesktopShopByOccasionSection(),
                  const SizedBox(height: 30),
                  const DesktopPerfectMatchSection(),
                  const SizedBox(height: 30),
                  const DesktopLuxurySection(),
                  const SizedBox(height: 30),
                  const DesktopWatchShopSection(),
                  const SizedBox(height: 30),
                  const DesktopBlogSection(),
                  const SizedBox(height: 30),
                  const DesktopInstaFamilySection(),
                  const SizedBox(height: 30),
                  DesktopAllProductsSection(),
                  const SizedBox(height: 30),
                  const DesktopWatchAndShopSection(),
                  const SizedBox(height: 30),
                  const DesktopOurFeaturesSection(),
                  const SizedBox(height: 30),
                  const DesktopTempleJewellerySection(),
                  const SizedBox(height: 30),
                  const DesktopCelebrityStyleSection(),
                  const SizedBox(height: 30),
                  const DesktopFooterSection(),
                ],
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
