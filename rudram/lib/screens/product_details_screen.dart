import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../models/data_models.dart';
import '../widgets/product_card.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_sidebar.dart';
import 'checkout_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductItem product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with TickerProviderStateMixin {
  int _currentImageIndex = 0;
  int _selectedSizeIndex = 2;
  late TabController _tabController;
  late List<String> _images;

  final List<String> _sizes = ['6', '7', '8', '9', '10', '11'];

  // Updated Accessories with Distinct Images
  final List<ProductItem> _accessories = [
    ProductItem(
      title: "Matching Pearl Necklace",
      currentPrice: 12500,
      oldPrice: 15000,
      discount: "16%",
      image:
          "https://images.unsplash.com/photo-1599643478518-17488fbbcd75?w=300",
      bgColor: Colors.white,
    ),
    ProductItem(
      title: "Matching Pearl Earrings",
      currentPrice: 4500,
      oldPrice: 6000,
      discount: "25%",
      image:
          "https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=300",
      bgColor: Colors.white,
    ),
    ProductItem(
      title: "Gold Stackable Ring",
      currentPrice: 8500,
      oldPrice: 10000,
      discount: "15%",
      image:
          "https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=300",
      bgColor: Colors.white,
    ),
    ProductItem(
      title: "Elegant Gold Bangle",
      currentPrice: 22000,
      oldPrice: 25000,
      discount: "12%",
      image:
          "https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=300",
      bgColor: Colors.white,
    ),
    ProductItem(
      title: "Travel Pouch",
      currentPrice: 1299,
      oldPrice: 1999,
      discount: "35%",
      image:
          "https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=300",
      bgColor: Colors.white,
    ),
  ];

  final List<String> _similarImages = [
    "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/6_mu5hap.jpg",
    "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/5_lf1dgq.jpg",
    "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/7_i3yykt.jpg",
    "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/4_a7e9t3.jpg",
    "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/3_i5pjnq.jpg",
  ];

  late final List<ProductItem> _similar = List.generate(
    5,
    (i) => ProductItem(
      title: "Elegant Ring $i",
      currentPrice: 12000 + (i * 500),
      oldPrice: 15000,
      discount: "10%",
      image: _similarImages[i % _similarImages.length],
      bgColor: Colors.white,
    ),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    if (widget.product.images.isNotEmpty) {
      _images = List<String>.from(widget.product.images);
    } else {
      _images = [
        widget.product.image.isNotEmpty
            ? widget.product.image
            : "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/6_mu5hap.jpg",
        "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/1_x3dvkl.jpg",
        "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/4_a7e9t3.jpg",
        "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/3_i5pjnq.jpg",
        "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/5_lf1dgq.jpg",
      ];
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddReviewModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          32,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Write a Verify Review",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Share your experience with this product",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.star_border_rounded,
                    size: 40,
                    color: Colors.amber,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                hintText: "What did you like or dislike?",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.all(20),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Review Submitted!")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Submit Review",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.65,
            child: Image.network(
                _images[_currentImageIndex],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey[100]),
              ),
          ),

          Positioned(
            top: 40,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.share, color: Colors.black),
                onPressed: () {},
              ),
            ),
          ),

          // Draggable Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.50,
            maxChildSize: 0.92,
            snap: true,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: AnimationLimiter(
                  child: ListView(
                    scrollCacheExtent: ScrollCacheExtent.pixels(1000), controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 375),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(child: widget),
                      ),
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Gallery Thumbnails
                        SizedBox(
                          height: 70,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _images.length,
                            itemBuilder: (context, index) => GestureDetector(
                              onTap: () =>
                                  setState(() => _currentImageIndex = index),
                              child: Container(
                                width: 70,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _currentImageIndex == index
                                        ? AppColors.primaryOrange
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(_images[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Header Info
                        Text(
                          widget.product.title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Playfair Display',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              "₹${widget.product.currentPrice}",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryOrange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "₹${widget.product.oldPrice}",
                              style: TextStyle(
                                fontSize: 16,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey[400],
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              "4.8",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "(120 Reviews)",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Sizes
                        const Text(
                          "Select Size",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: List.generate(
                              _sizes.length,
                              (index) => GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedSizeIndex = index),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  width: 50,
                                  height: 50,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: _selectedSizeIndex == index
                                        ? Colors.black
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _selectedSizeIndex == index
                                          ? Colors.black
                                          : Colors.grey[300]!,
                                    ),
                                    boxShadow: _selectedSizeIndex == index
                                        ? [
                                            const BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    _sizes[index],
                                    style: TextStyle(
                                      color: _selectedSizeIndex == index
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Handcrafted with 22K Gold, this piece is a testament to timeless elegance. Each curve is designed to reflect light perfectly.",
                          style: TextStyle(color: Colors.grey, height: 1.5),
                        ),
                        const SizedBox(height: 32),

                        // Enhanced Tabs Section
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.zero,
                            indicator: BoxDecoration(
                              color: AppColors.primaryOrange,
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryOrange.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.grey[600],
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                            dividerColor: Colors.transparent,
                            indicatorSize: TabBarIndicatorSize.tab,
                            tabs: const [
                              Tab(text: "Features", height: 46),
                              Tab(text: "Reviews", height: 46),
                              Tab(text: "Seller", height: 46),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Tab Content
                        SizedBox(
                          height: 220, // Increased height for better content
                          child: TabBarView(
                            controller: _tabController,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              // Beautiful Features Grid
                              GridView.count(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 2.5,
                                physics: const BouncingScrollPhysics(),
                                children: [
                                  _buildFeatureCard(
                                    Icons.diamond_outlined,
                                    "Material",
                                    "22K Gold",
                                  ),
                                  _buildFeatureCard(
                                    Icons.scale_outlined,
                                    "Weight",
                                    "35 Grams",
                                  ),
                                  _buildFeatureCard(
                                    Icons.verified_outlined,
                                    "Certified",
                                    "BIS Hallmarked",
                                  ),
                                  _buildFeatureCard(
                                    Icons.handshake_outlined,
                                    "Warranty",
                                    "1 Year",
                                  ),
                                ],
                              ),

                              // Beautiful Reviews
                              SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.amber[50],
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          const Text(
                                            "4.8",
                                            style: TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.amber,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Excellent",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Text(
                                                  "Based on 120 verified reviews",
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: _showAddReviewModal,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor: Colors.black,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                side: BorderSide(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                            ),
                                            child: const Text("Write Review"),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildReviewItem(
                                      "Ananya P.",
                                      "Absolutely loved the finish! Looks exactly like the photos.",
                                      5,
                                    ),
                                    _buildReviewItem(
                                      "Rahul K.",
                                      "Great packaging and timely delivery.",
                                      4,
                                    ),
                                  ],
                                ),
                              ),

                              // Beautiful Seller Info
                              SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryOrange,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            "R",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Row(
                                              children: [
                                                Text(
                                                  "Rudram Official",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                SizedBox(width: 4),
                                                Icon(
                                                  Icons.verified,
                                                  size: 16,
                                                  color: Colors.blue,
                                                ),
                                              ],
                                            ),
                                            Text(
                                              "Member since 2015",
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            const Row(
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  size: 14,
                                                  color: Colors.amber,
                                                ),
                                                Text(
                                                  " 4.9 Seller Rating",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      OutlinedButton(
                                        onPressed: () {},
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: const Text("Visit"),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 48),

                        // Perfect Combinations
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Perfect Combinations",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                "View All",
                                style: TextStyle(
                                  color: AppColors.primaryOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 280,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _accessories.length,
                            itemBuilder: (context, index) => Container(
                              width: 160,
                              margin: const EdgeInsets.only(right: 16),
                              child: Stack(
                                children: [
                                  ProductCard(product: _accessories[index]),
                                  Positioned(
                                  bottom: 90,
                                  right: 20,
                                  child: Material(
                                    elevation: 4,
                                    shape: const CircleBorder(),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 18,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(
                                          Icons.add,
                                          size: 22,
                                          color: AppColors.primaryOrange,
                                        ),
                                        onPressed: () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text("Added to Bundle!"),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ),
                          ),
                        ),

                        _buildSectionHeader("Celebrity Spotted"),
                        SizedBox(
                          height: 120,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _buildCelebAvatar(
                                "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200",
                                "Deepika",
                              ),
                              _buildCelebAvatar(
                                "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200",
                                "Priyanka",
                              ),
                              _buildCelebAvatar(
                                "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=200",
                                "Alia",
                              ),
                              _buildCelebAvatar(
                                "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200",
                                "Katrina",
                              ),
                            ],
                          ),
                        ),
                        _buildSectionHeader("The Craftsmanship"),
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: const DecorationImage(
                              image: NetworkImage(
                                "https://images.unsplash.com/photo-1618401479427-c8ef9465fbe1?w=600",
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.7),
                                  Colors.transparent,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            alignment: Alignment.bottomLeft,
                            padding: const EdgeInsets.all(16),
                            child: const Text(
                              "Hand-polished by master artisans in Jaipur.",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // 4. Premium Unboxing
                        _buildSectionHeader("Premium Unboxing"),
                        Container(
                          height: 140,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(16),
                                  ),
                                  child: Image.network(
                                    "https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=300",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Signature Velvet Box",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Included with purchase",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 5. Video Showcase
                        _buildSectionHeader("Watch Product Video"),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: const DecorationImage(
                              image: NetworkImage(
                                "https://images.unsplash.com/photo-1574484284008-86d47dc7b6dc?w=600",
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Center(
                            child: CircleAvatar(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.8,
                              ),
                              radius: 30,
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.black,
                                size: 30,
                              ),
                            ),
                          ),
                        ),

                        // 6. Trusted By Badges
                        _buildSectionHeader("Trusted By Millions"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildTrustBadge(
                              Icons.verified_user,
                              "BIS Hallmarked",
                            ),
                            _buildTrustBadge(Icons.diamond, "Certified"),
                            _buildTrustBadge(
                              Icons.sync_alt,
                              "Lifetime Exchange",
                            ),
                            _buildTrustBadge(Icons.local_shipping, "Insured"),
                          ],
                        ),

                        // 7. Gold Rate Banner
                        Container(
                          margin: const EdgeInsets.only(top: 24),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.yellow[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.yellow[100]!),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Current Gold Rate (22K)",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "₹ 6,550 / gram",
                                style: TextStyle(
                                  color: AppColors.primaryOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 8. Warranty & Support
                        _buildSectionHeader("Warranty & Support"),
                        const ExpansionTile(
                          title: Text("1 Year Replacement Warranty"),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                "Covers any manufacturing defects. Stone loss covered for 6 months.",
                              ),
                            ),
                          ],
                        ),
                        const ExpansionTile(
                          title: Text("Authenticity Certificate"),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                "BIS Hallmarked 22K Gold certificate included.",
                              ),
                            ),
                          ],
                        ),

                        // 9. People Also Viewed
                        _buildSectionHeader("People Also Viewed"),
                        SizedBox(
                          height: 280,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _similar.length,
                            itemBuilder: (context, index) =>
                                ProductCard(product: _similar[index]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        final cart = Provider.of<CartProvider>(
                          context,
                          listen: false,
                        );
                        cart.addItem(widget.product);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CheckoutScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryOrange,
                        side: BorderSide(color: AppColors.primaryOrange, width: 1.5),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Buy Now",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Consumer<CartProvider>(
                      builder: (context, cart, child) {
                        final qty = cart.getQuantity(widget.product);
                        if (qty > 0) {
                          return Container(
                            height: 56,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.primaryOrange),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, color: AppColors.primaryOrange),
                                  onPressed: () => cart.updateQuantity(widget.product, qty - 1),
                                ),
                                Text(
                                  '$qty',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, color: AppColors.primaryOrange),
                                  onPressed: () => cart.updateQuantity(widget.product, qty + 1),
                                ),
                              ],
                            ),
                          );
                        }

                        return ElevatedButton(
                          onPressed: () {
                            cart.addItem(widget.product);

                            // Show sidebar with cart
                            showGeneralDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel: 'Cart',
                              barrierColor: Colors.black.withValues(alpha: 0.5),
                              transitionDuration: const Duration(milliseconds: 300),
                              pageBuilder: (context, anim1, anim2) {
                                return Material(
                                  color: Colors.transparent,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(1, 0),
                                        end: Offset.zero,
                                      ).animate(anim1),
                                      child: const CartSidebar(),
                                    ),
                                  ),
                                );
                              },
                            );

                            // Show snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${widget.product.title} added to cart!'),
                                duration: const Duration(seconds: 2),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrange,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "Add to Cart",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textGrey, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String name, String comment, int stars) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < stars ? Icons.star : Icons.star_border,
                    size: 14,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            comment,
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCelebAvatar(String url, String name) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          CircleAvatar(radius: 35, backgroundImage: NetworkImage(url)),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String title) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryOrange, size: 24),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 70,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
