import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/app_colors.dart';

class BlogDetailScreen extends StatelessWidget {
  final Map<String, String> blog;

  const BlogDetailScreen({super.key, required this.blog});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bookmark_border, color: Colors.white),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved to bookmarks')),
                  );
                },
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, color: Colors.white),
                ),
                onPressed: () {
                  Share.share(
                    'Check out this blog: ${blog['title']}\n\n${blog['excerpt']}',
                    subject: blog['title'],
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(
                    blog['title'] ?? '',
                    blog['image'] ?? '',
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
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      blog['category'] ?? 'General',
                      style: const TextStyle(
                        color: AppColors.primaryOrange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    blog['title'] ?? 'Blog Title',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Author Info Row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primaryOrange.withValues(
                          alpha: 0.2,
                        ),
                        child: Text(
                          (blog['author'] ?? 'A')[0],
                          style: const TextStyle(
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              blog['author'] ?? 'Author',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  blog['date'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  blog['readTime'] ?? '5 min read',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Article Content
                  Text(
                    blog['excerpt'] ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Full Content (Lorem ipsum placeholder)
                  _buildContentSection(
                    context,
                    'Understanding the Basics',
                    'Jewelry care is essential to maintain the brilliance and longevity of your precious pieces. Whether you own diamond rings, gold necklaces, or gemstone earrings, proper maintenance ensures they remain stunning for generations to come.\n\nDiamonds, while extremely hard, can still be damaged if not cared for properly. Regular cleaning and safe storage are crucial elements of jewelry maintenance.',
                  ),

                  _buildContentSection(
                    context,
                    'Daily Care Tips',
                    '1. Remove jewelry when washing hands, applying lotions, or engaging in physical activities.\n\n2. Store each piece separately to prevent scratches and tangling.\n\n3. Clean your jewelry regularly with appropriate solutions.\n\n4. Avoid exposing jewelry to harsh chemicals, including household cleaners and chlorine.',
                  ),

                  _buildContentSection(
                    context,
                    'Professional Maintenance',
                    'While home care is important, professional cleaning and inspection should be done annually. Jewelers can check for loose stones, worn prongs, and other potential issues that might not be visible to the untrained eye.\n\nInvesting in professional maintenance can save you from costly repairs or lost gemstones in the future.',
                  ),

                  const SizedBox(height: 32),

                  // Engagement Section
                  _buildEngagementBar(context),

                  const SizedBox(height: 32),

                  // Related Articles
                  Text(
                    'Related Articles',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRelatedArticle(
                    context,
                    'Top 5 Wedding Jewelry Trends',
                    'Sep 15, 2023',
                    'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=400',
                  ),
                  _buildRelatedArticle(
                    context,
                    'Guide to Gold Purity',
                    'Jul 05, 2023',
                    'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=400',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
      ),
    );
  }

  Widget _buildContentSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.7),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEngagementBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildEngagementButton(context, Icons.favorite_border, '124'),
          _buildEngagementButton(context, Icons.chat_bubble_outline, '32'),
          _buildEngagementButton(context, Icons.bookmark_border, 'Save'),
          _buildEngagementButton(context, Icons.share_outlined, 'Share'),
        ],
      ),
    );
  }

  Widget _buildEngagementButton(BuildContext context, IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildRelatedArticle(BuildContext context, String title, String date, String imageUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildImage(
              title,
              imageUrl,
              width: 80,
              height: 80,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
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
    // Always use local asset when URL is Unsplash or empty (avoids CORS on web)
    final bool useLocal = defaultUrl.isEmpty || defaultUrl.contains('unsplash.com');
    if (useLocal) {
      final asset = _localAssets[title.hashCode.abs() % _localAssets.length];
      return Image.asset(
        asset,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => Container(width: width, height: height, color: Colors.grey[200]),
      );
    }
    // Non-Unsplash URL (e.g., Cloudinary): load directly, fallback to local on error
    return Image.network(
      defaultUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) {
        final asset = _localAssets[title.hashCode.abs() % _localAssets.length];
        return Image.asset(asset, width: width, height: height, fit: fit);
      },
    );
  }
}
