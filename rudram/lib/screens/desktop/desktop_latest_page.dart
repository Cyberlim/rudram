import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../screens/blog_detail_screen.dart';
import '../../widgets/desktop/desktop_header.dart';
import '../../widgets/desktop/desktop_footer_section.dart';
import '../../utils/app_colors.dart';

class DesktopLatestPage extends StatelessWidget {
  const DesktopLatestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SingleChildScrollView(
        child: Column(
          children: [
            const DesktopHeader(),
            _buildPageContent(context),
            const DesktopFooterSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('articles')
          .where('status', isEqualTo: 'Published')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SizedBox(
            height: 400,
            child: Center(child: Text("Error: ${snapshot.error}")),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 400,
            child: Center(child: CircularProgressIndicator(color: AppColors.primaryOrange)),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        final articles = docs.map((d) => {...(d.data() as Map<String, dynamic>), 'id': d.id}).toList();
        
        // Sort locally to avoid needing a Firestore composite index
        articles.sort((a, b) {
          final t1 = a['createdAt'] as Timestamp?;
          final t2 = b['createdAt'] as Timestamp?;
          if (t1 == null && t2 == null) return 0;
          if (t1 == null) return 1;
          if (t2 == null) return -1;
          return t2.compareTo(t1);
        });

        final featured = articles.firstWhere((a) => a['featured'] == true, orElse: () => articles.isNotEmpty ? articles.first : <String, dynamic>{});
        final rest = articles.where((a) => a['id'] != featured['id']).toList();

        return Column(
          children: [
            if (featured.isNotEmpty) _buildFeaturedArticle(context, featured),
            _buildArticleGrid(context, rest, articles.isEmpty),
            _buildNewsletterBanner(),
          ],
        );
      },
    );
  }

  Widget _buildFeaturedArticle(BuildContext context, Map<String, dynamic> article) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "FEATURED",
            style: TextStyle(letterSpacing: 4, color: AppColors.primaryOrange, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            article['title'] ?? '',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _buildImage(
              article['title'] ?? '',
              article['imageUrl'] ?? '',
              width: double.infinity,
              height: 500,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  article['subtitle'] ?? '',
                  style: const TextStyle(fontSize: 20, color: Colors.black87, height: 1.6),
                ),
              ),
              const SizedBox(width: 80),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () => _navigateToArticle(context, article),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("READ FULL STORY", style: TextStyle(letterSpacing: 2)),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildArticleGrid(BuildContext context, List<Map<String, dynamic>> articles, bool isEmpty) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "LATEST UPDATES",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          if (isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: Text("No articles published yet. Click the button above to seed.", style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 40,
              mainAxisSpacing: 60,
              childAspectRatio: 0.8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: articles.map((a) => _buildArticleCard(context, a)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, Map<String, dynamic> article) {
    return GestureDetector(
      onTap: () => _navigateToArticle(context, article),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: _buildImage(
                  article['title'] ?? '',
                  article['imageUrl'] ?? '',
                  width: double.infinity,
                ),
              ),
            ),
        const SizedBox(height: 20),
        Text(
          article['tag'] ?? '',
          style: const TextStyle(fontSize: 12, letterSpacing: 2, color: AppColors.primaryOrange, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          article['title'] ?? '',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          article['subtitle'] ?? '',
          style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
        ),
          ],
        ),
      ),
    );
  }

  static const _localAssets = [
    'assets/images/royal_ruby_collection.jpg',
    'assets/images/diamond_jewelry_care.jpg',
    'assets/images/wedding_jewelry_trends.jpg',
    'assets/images/gold_purity_guide.jpg',
  ];

  Widget _buildImage(String title, String defaultUrl, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    // Always use a local asset when Unsplash URL or empty (avoids CORS on web)
    final bool useLocal = defaultUrl.isEmpty || defaultUrl.contains('unsplash.com');
    if (useLocal) {
      final asset = _localAssets[title.hashCode.abs() % _localAssets.length];
      return Image.asset(
        asset,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => Container(width: width, height: height, color: Colors.grey[200]),
      );
    }
    // Non-Unsplash URL (e.g., Cloudinary): load directly
    return Image.network(
      defaultUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) {
        // Fallback to local on any network error
        final asset = _localAssets[title.hashCode.abs() % _localAssets.length];
        return Image.asset(asset, width: width, height: height, fit: fit);
      },
    );
  }

  void _navigateToArticle(BuildContext context, Map<String, dynamic> article) {
    // Format timestamp if available
    String dateStr = '';
    if (article['createdAt'] != null && article['createdAt'] is Timestamp) {
      final dt = (article['createdAt'] as Timestamp).toDate();
      dateStr = "${dt.day}/${dt.month}/${dt.year}";
    }
    
    final blog = <String, String>{
      'title': article['title']?.toString() ?? '',
      'image': article['imageUrl']?.toString() ?? '',
      'category': article['tag']?.toString() ?? '',
      'excerpt': article['subtitle']?.toString() ?? '',
      'author': 'Rudram Team',
      'date': dateStr,
      'readTime': '5 min read',
    };
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlogDetailScreen(blog: blog),
      ),
    );
  }

  Widget _buildNewsletterBanner() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF8F9FA),
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 100),
      child: Column(
        children: [
          const Text(
            "STAY CONNECTED",
            style: TextStyle(letterSpacing: 4, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            "Subscribe to the Rudram Newsletter",
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            "Be the first to know about new collections, exclusive events, and jewelry care tips.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 400,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Enter your email address",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("SUBSCRIBE", style: TextStyle(letterSpacing: 2)),
              )
            ],
          )
        ],
      ),
    );
  }
}
