import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'luxury_acquire_screen.dart';

class LuxuryProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const LuxuryProductDetailsScreen({super.key, required this.product});

  @override
  State<LuxuryProductDetailsScreen> createState() =>
      _LuxuryProductDetailsScreenState();
}

class _LuxuryProductDetailsScreenState
    extends State<LuxuryProductDetailsScreen> {
  int _currentImageIndex = 0;

  List<String> get _images {
    // If we have an array of images in the database, we'd use it here.
    // For now, our luxury products just have a single 'image' string.
    final img = widget.product['image'] as String?;
    return [img ?? "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/6_mu5hap.jpg"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            expandedHeight: 500,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: PageView.builder(
                itemCount: _images.length,
                onPageChanged: (i) => setState(() => _currentImageIndex = i),
                itemBuilder: (context, index) =>
                    Image.network(_images[index], fit: BoxFit.cover),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: AnimationLimiter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(
                      milliseconds: 600,
                    ), // Slower for luxury feel
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _images.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index
                                  ? const Color(0xFFD4AF37)
                                  : Colors.grey[800],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      Text(
                        widget.product['title'] ?? "Luxury Item",
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Playfair Display',
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.product['price']?.toString() ?? "₹ 0",
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        "Includes Taxes",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),

                      const SizedBox(height: 32),
                      const Divider(color: Colors.grey, thickness: 0.2),
                      const SizedBox(height: 32),

                      const Text(
                        "STORY",
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          letterSpacing: 2,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.product['description'] ?? "This exquisite piece is handcrafted by master artisans, featuring carefully sourced precious stones set in premium metal. A true heirloom piece designed for royalty.",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Specs
                      _buildSpecRow("Gemstone", "Colombian Emerald"),
                      _buildSpecRow("Metal", "22K Gold"),
                      _buildSpecRow("Weight", "185 Grams"),
                      _buildSpecRow("Certification", "GIA & BIS Hallmarked"),

                      // Perfect Combinations
                      const Text(
                        "PERFECT COMBINATIONS",
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          letterSpacing: 2,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const ClampingScrollPhysics(),
                          children: [
                            _buildMatchingItem(
                              "https://images.unsplash.com/photo-1599643478518-17488fbbcd75?w=300",
                              "Matching Necklace",
                              "₹ 2,75,000",
                            ),
                            _buildMatchingItem(
                              "https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=300",
                              "Solitaire Ring",
                              "₹ 1,50,000",
                            ),
                            _buildMatchingItem(
                              "https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=300",
                              "Gold Bangle",
                              "₹ 3,20,000",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Concierge CTA
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFD4AF37)),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.support_agent,
                              color: Color(0xFFD4AF37),
                              size: 32,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Private Viewing",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Playfair Display',
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Book an appointment to view this piece at our flagship boutique or request a home visit.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 24),
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("CONTACT CONCIERGE"),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100), // Space for bottom bar
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        color: Colors.black,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LuxuryAcquireScreen(product: widget.product),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          child: const Text(
            "ACQUIRE NOW",
            style: TextStyle(
              fontSize: 16,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchingItem(String image, String title, String price) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LuxuryProductDetailsScreen(
              product: {
                'title': title,
                'image': image,
                'price': price,
                'description': 'A beautiful complementary piece carefully selected by our experts.',
              },
            ),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Playfair Display',
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
