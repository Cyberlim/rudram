import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'enhanced_search_bar.dart';
import 'hero_banner.dart';
import 'category_section.dart';
import 'flash_sale_section.dart';
import 'new_arrivals_section.dart';
import 'best_sellers_section.dart';
import 'trending_now_section.dart';
import 'exclusive_offers_banner.dart';
import 'perfect_match_section.dart';
import 'deals_of_the_day_section.dart';
import 'luxury_section.dart';
import 'shop_by_occasion_section.dart';
import 'our_features_section.dart';
import 'watch_and_shop_section.dart';
import 'blog_section.dart';
import 'insta_family_section.dart';
import 'all_products_section.dart';
import 'celebrity_style_section.dart';
import 'gift_guide_section.dart';
import 'testimonials_section.dart';
import 'temple_jewellery_section.dart';
import 'gold_scheme_section.dart';
import 'designers_spotlight.dart';
import 'brand_marquee_section.dart';
import 'community_gallery_section.dart';
import 'awards_section.dart';
import 'feature_carousel_section.dart';

class HomeTab extends StatelessWidget {
  final VoidCallback? onSearchTap;
  const HomeTab({super.key, this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimationLimiter(
        child: ListView(
          scrollCacheExtent: ScrollCacheExtent.pixels(2000), physics: const BouncingScrollPhysics(),
          addAutomaticKeepAlives: true, // Pre-render more items for smoother scroll
          children: Algorithm.run([
            const FeatureCarouselSection(),
            EnhancedSearchBar(onSearchTap: onSearchTap),
            const SizedBox(height: 6),
            const HeroBanner(),
            const SizedBox(height: 8),
            const CategorySection(),
            const SizedBox(height: 4),
            FlashSaleSection(),
            const SizedBox(height: 0),
            NewArrivalsSection(),
            const SizedBox(height: 0),
            BestSellersSection(),
            const SizedBox(height: 0),
            TrendingNowSection(),
            const SizedBox(height: 0),
            const ExclusiveOffersBanner(),
            const SizedBox(height: 4),
            const ShopByOccasionSection(),
            const PerfectMatchSection(),
            const SizedBox(height: 4),
            const LuxurySection(),
            const SizedBox(height: 8),
            const WatchAndShopSection(),
            const SizedBox(height: 8),
            const BlogSection(),
            const SizedBox(height: 8),
            const InstaFamilySection(),
            const SizedBox(height: 8),
            AllProductsSection(),
            const SizedBox(height: 8),
            const OurFeaturesSection(),
            const SizedBox(height: 8),
            TempleJewellerySection(),
            const SizedBox(height: 8),
            CelebrityStyleSection(),
            const SizedBox(height: 8),
            GoldSchemeSection(),
            const SizedBox(height: 8),
            const DesignersSpotlight(),
            const SizedBox(height: 8),
            GiftGuideSection(),
            const SizedBox(height: 8),
            TestimonialsSection(),
            const SizedBox(height: 12),
            const BrandMarqueeSection(),
            const SizedBox(height: 8),
            CommunityGallerySection(),
            const SizedBox(height: 8),
            const AwardsSection(),
            const SizedBox(height: 50),
          ]),
        ),
      ),
    );
  }
}

class Algorithm {
  static List<Widget> run(List<Widget> children) {
    return AnimationConfiguration.toStaggeredList(
      duration: const Duration(milliseconds: 375),
      childAnimationBuilder: (widget) => SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(child: widget),
      ),
      children: children,
    );
  }
}
